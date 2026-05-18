import 'package:equatable/equatable.dart';
import '../../../data/models/models.dart';

/// Auth events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

/// Check auth status on app start (auto-login with saved session)
class CheckAuthStatus extends AuthEvent {}

/// Send OTP to phone number
class SendOtpRequested extends AuthEvent {
  final String phoneNumber;
  const SendOtpRequested(this.phoneNumber);
  @override
  List<Object?> get props => [phoneNumber];
}

/// Verify OTP code
class VerifyOtpRequested extends AuthEvent {
  final String otp;
  const VerifyOtpRequested(this.otp);
  @override
  List<Object?> get props => [otp];
}

/// User needs to complete onboarding
class CompleteOnboardingRequested extends AuthEvent {
  final String fullName;
  final String gender;
  final String universityId;
  final String facultyId;
  final String academicYearId;
  
  const CompleteOnboardingRequested({
    required this.fullName,
    required this.gender,
    required this.universityId,
    required this.facultyId,
    required this.academicYearId,
  });
  
  @override
  List<Object?> get props => [fullName, gender, universityId, facultyId, academicYearId];
}

/// Logout user
class LogoutRequested extends AuthEvent {}

/// Auth states
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

/// Initial state
class AuthInitial extends AuthState {}

/// Loading state
class AuthLoading extends AuthState {}

/// OTP sent to phone
class OtpSent extends AuthState {
  final String phoneNumber;
  const OtpSent(this.phoneNumber);
  @override
  List<Object?> get props => [phoneNumber];
}

/// User authenticated but needs to complete profile
class AuthenticatedNeedsOnboarding extends AuthState {
  final String userId;
  const AuthenticatedNeedsOnboarding(this.userId);
  @override
  List<Object?> get props => [userId];
}

/// User fully authenticated with complete profile
class Authenticated extends AuthState {
  final User user;
  const Authenticated(this.user);
  @override
  List<Object?> get props => [user];
}

/// User not authenticated
class Unauthenticated extends AuthState {}

/// Auth error
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}
