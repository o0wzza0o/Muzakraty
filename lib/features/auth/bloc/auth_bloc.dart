import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/secure_session_manager.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/user_repository.dart';
import 'auth_event_state.dart' as app_auth;

/// AuthBloc using Node.js OTP server ONLY (no Supabase Auth)
/// Session stored in encrypted secure storage with 90-day expiry
class AuthBloc extends Bloc<app_auth.AuthEvent, app_auth.AuthState> {
  final UserRepository _userRepository = UserRepository();
  static const String _otpServerUrl = 'https://otp-server-production-5eef.up.railway.app';
  String? _currentPhone;
  String? _currentUserId;

  AuthBloc() : super(app_auth.AuthInitial()) {
    on<app_auth.CheckAuthStatus>(_onCheckAuthStatus);
    on<app_auth.SendOtpRequested>(_onSendOtp);
    on<app_auth.VerifyOtpRequested>(_onVerifyOtp);
    on<app_auth.CompleteOnboardingRequested>(_onCompleteOnboarding);
    on<app_auth.LogoutRequested>(_onLogout);
  }

  void _log(String message, {String tag = 'AuthBloc'}) {
    developer.log(message, name: tag);
    print('[$tag] $message');
  }

  /// Check auth status on app start
  /// 1. Try cached user data first (instant)
  /// 2. Then refresh from database in background
  Future<void> _onCheckAuthStatus(app_auth.CheckAuthStatus event, Emitter<app_auth.AuthState> emit) async {
    _log('🔍 Checking auth status...');
    
    try {
      // Check if valid session exists (encrypted + 90-day expiry)
      final session = await SecureSessionManager.getSession();
      
      if (session == null) {
        _log('❌ No valid session (expired or missing)');
        emit(app_auth.Unauthenticated());
        return;
      }

      _currentPhone = session.phone;
      _currentUserId = session.userId;
      _log('📱 Session found: phone=${session.phone}, userId=${session.userId}');

      // Try cached data first for INSTANT loading
      final cachedData = await SecureSessionManager.getCachedUserData();
      if (cachedData != null) {
        _log('⚡ Using cached user data for instant load');
        final cachedUser = User.fromJson(cachedData);

        if (cachedUser.universityId == null || cachedUser.facultyId == null || cachedUser.academicYearId == null) {
          emit(app_auth.AuthenticatedNeedsOnboarding(session.userId));
        } else {
          emit(app_auth.Authenticated(cachedUser));
        }

        // Refresh from DB in background (silent update)
        _refreshProfileInBackground(session.userId);
        return;
      }

      // No cache - load from database
      _log('📡 No cache, loading from database...');
      emit(app_auth.AuthLoading());
      await _loadUserProfile(userId: session.userId, emit: emit);
    } catch (e, stackTrace) {
      _log('💥 Error checking auth status: $e');
      _log('Stack trace: $stackTrace');
      emit(app_auth.Unauthenticated());
    }
  }

  /// Refresh user profile from DB without blocking UI
  Future<void> _refreshProfileInBackground(String userId) async {
    try {
      final user = await _userRepository.getUserById(userId);
      if (user != null) {
        await SecureSessionManager.cacheUserData(user.toJson());
        // Extend session on each app open
        await SecureSessionManager.refreshExpiry();
        _log('🔄 Background profile refresh complete');
      }
    } catch (e) {
      _log('⚠️ Background refresh failed (non-blocking): $e');
    }
  }

  /// Send OTP using Node.js server
  Future<void> _onSendOtp(app_auth.SendOtpRequested event, Emitter<app_auth.AuthState> emit) async {
    _log('📤 Sending OTP request...');
    emit(app_auth.AuthLoading());
    
    try {
      // Format phone number (remove + for Node.js server)
      final formattedPhone = event.phoneNumber.replaceAll('+', '');
      _currentPhone = formattedPhone;
      
      _log('📱 Formatted phone: $formattedPhone');
      _log('🌐 OTP Server URL: $_otpServerUrl/send-otp');

      final response = await http.post(
        Uri.parse('$_otpServerUrl/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': formattedPhone}),
      );

      _log('📥 Response status: ${response.statusCode}');
      _log('📥 Response body: ${response.body}');

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _log('✅ OTP sent successfully');
        emit(app_auth.OtpSent(event.phoneNumber));
      } else {
        _log('❌ Failed to send OTP: ${data['message'] ?? 'Unknown error'}');
        emit(const app_auth.AuthError('فشل إرسال رمز التحقق، تأكد من تشغيل السيرفر'));
      }
    } catch (e, stackTrace) {
      _log('💥 Error sending OTP: $e');
      _log('Stack trace: $stackTrace');
      emit(const app_auth.AuthError('تعذر الاتصال بخادم رمز التحقق'));
    }
  }

  /// Verify OTP using Node.js server
  /// If verified: create/find user in database and login
  Future<void> _onVerifyOtp(app_auth.VerifyOtpRequested event, Emitter<app_auth.AuthState> emit) async {
    _log('🔐 Verifying OTP: ${event.otp}');
    emit(app_auth.AuthLoading());
    
    try {
      if (_currentPhone == null) {
        _log('❌ Current phone is null!');
        emit(const app_auth.AuthError('انتهت صلاحية الجلسة، الرجاء إعادة إدخال رقم الهاتف'));
        return;
      }

      _log('📱 Current phone: $_currentPhone');
      _log('🌐 Verifying at: $_otpServerUrl/verify-otp');

      // Verify OTP with Node.js server
      final response = await http.post(
        Uri.parse('$_otpServerUrl/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': _currentPhone,
          'otp': event.otp,
        }),
      );

      _log('📥 Response status: ${response.statusCode}');
      _log('📥 Response body: ${response.body}');

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _log('✅ OTP verified! Proceeding to find/create user...');
        // OTP verified! Now find or create user in database
        await _findOrCreateUser(_currentPhone!, emit);
      } else {
        _log('❌ OTP verification failed: ${data['message'] ?? 'Invalid OTP'}');
        emit(const app_auth.AuthError('رمز التحقق غير صحيح'));
      }
    } catch (e, stackTrace) {
      _log('💥 Error verifying OTP: $e');
      _log('Stack trace: $stackTrace');
      emit(const app_auth.AuthError('حدث خطأ أثناء التحقق من الرمز'));
    }
  }

  /// Find existing user by phone or create new one
  Future<void> _findOrCreateUser(String phone, Emitter<app_auth.AuthState> emit) async {
    _log('🔍 Finding or creating user for phone: $phone');
    try {
      // Try to find user by phone
      _log('📡 Querying database for user with phone: $phone');
      final existingUser = await _userRepository.getUserByPhone(phone);
      
      if (existingUser != null) {
        _log('✅ Found existing user: ${existingUser.id}');
        _log('👤 User name: ${existingUser.fullName}');
        _log('🏫 University: ${existingUser.universityId}, Faculty: ${existingUser.facultyId}, Year: ${existingUser.academicYearId}');
        
        // User exists - save session securely (90 days)
        _currentUserId = existingUser.id;
        await SecureSessionManager.saveSession(
          phone: phone,
          userId: existingUser.id,
          userData: existingUser.toJson(),
        );
        
        // Check if profile complete
        if (existingUser.universityId == null || existingUser.facultyId == null || existingUser.academicYearId == null) {
          _log('⚠️ Profile incomplete, needs onboarding');
          emit(app_auth.AuthenticatedNeedsOnboarding(existingUser.id));
        } else {
          _log('✅ Profile complete, authenticated!');
          emit(app_auth.Authenticated(existingUser));
        }
      } else {
        _log('🆕 User not found, creating new user...');
        // New user - create in database
        try {
          final newUserId = await _userRepository.createUser(
            phone: phone,
            fullName: null,
            universityId: null,
            facultyId: null,
            academicYearId: null,
          );
          
          _log('✅ New user created with ID: $newUserId');
          
          _currentUserId = newUserId;
          await SecureSessionManager.saveSession(
            phone: phone,
            userId: newUserId,
          );
          
          // New user needs onboarding
          _log('⚠️ New user needs onboarding');
          emit(app_auth.AuthenticatedNeedsOnboarding(newUserId));
        } catch (createError, createStackTrace) {
          _log('💥 Error creating user: $createError');
          _log('Stack trace: $createStackTrace');
          rethrow;
        }
      }
    } catch (e, stackTrace) {
      _log('💥 Error in findOrCreateUser: $e');
      _log('Stack trace: $stackTrace');
      emit(const app_auth.AuthError('حدث خطأ أثناء تسجيل الدخول'));
    }
  }

  /// Complete onboarding and save user profile
  Future<void> _onCompleteOnboarding(app_auth.CompleteOnboardingRequested event, Emitter<app_auth.AuthState> emit) async {
    _log('📝 Completing onboarding...');
    emit(app_auth.AuthLoading());
    
    try {
      final userId = _currentUserId;
      if (userId == null) {
        _log('❌ Cannot complete onboarding: userId is null');
        emit(const app_auth.AuthError('المستخدم غير مسجل الدخول'));
        return;
      }

      _log('📝 Updating profile for user: $userId');
      _log('📋 Data: name=${event.fullName}, uni=${event.universityId}, fac=${event.facultyId}, year=${event.academicYearId}');

      // Update user profile in database
      final user = await _userRepository.updateProfile(
        userId: userId,
        fullName: event.fullName,
        universityId: event.universityId,
        facultyId: event.facultyId,
        academicYearId: event.academicYearId,
      );

      // Cache updated profile for instant load next time
      await SecureSessionManager.cacheUserData(user.toJson());

      _log('✅ Profile updated and cached');
      emit(app_auth.Authenticated(user));
    } catch (e, stackTrace) {
      _log('💥 Error completing onboarding: $e');
      _log('Stack trace: $stackTrace');
      emit(const app_auth.AuthError('حدث خطأ أثناء حفظ الملف الشخصي'));
    }
  }

  /// Logout user - clear all secure session data
  Future<void> _onLogout(app_auth.LogoutRequested event, Emitter<app_auth.AuthState> emit) async {
    _log('🚪 Logging out...');
    emit(app_auth.AuthLoading());
    
    try {
      // Clear ALL secure session data
      await SecureSessionManager.clearSession();
      
      _currentPhone = null;
      _currentUserId = null;
      
      _log('✅ Logged out - all session data cleared');
      emit(app_auth.Unauthenticated());
    } catch (e, stackTrace) {
      _log('💥 Error during logout: $e');
      _log('Stack trace: $stackTrace');
      emit(const app_auth.AuthError('حدث خطأ أثناء تسجيل الخروج'));
    }
  }

  /// Load user profile from database
  Future<void> _loadUserProfile({required String userId, required Emitter<app_auth.AuthState> emit}) async {
    _log('📡 Loading user profile for: $userId');
    try {
      final user = await _userRepository.getUserById(userId);
      
      if (user == null) {
        _log('❌ User not found in database: $userId');
        // User not found in database
        emit(app_auth.Unauthenticated());
        return;
      }

      _log('✅ User found: ${user.id}');
      _log('👤 Name: ${user.fullName}');
      _log('🏫 Uni: ${user.universityId}, Fac: ${user.facultyId}, Year: ${user.academicYearId}');

      // Cache for instant load next time
      await SecureSessionManager.cacheUserData(user.toJson());

      // Check if profile is complete
      if (user.universityId == null || user.facultyId == null || user.academicYearId == null) {
        _log('⚠️ Profile incomplete, needs onboarding');
        emit(app_auth.AuthenticatedNeedsOnboarding(userId));
      } else {
        _log('✅ Profile complete, authenticated!');
        // Profile complete
        emit(app_auth.Authenticated(user));
      }
    } catch (e, stackTrace) {
      _log('💥 Error loading profile: $e');
      _log('Stack trace: $stackTrace');
      emit(const app_auth.AuthError('حدث خطأ أثناء تحميل الملف الشخصي'));
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _currentUserId != null;

  /// Get current user ID
  String? get currentUserId => _currentUserId;

  /// Get current user phone
  String? get currentPhone => _currentPhone;
}
