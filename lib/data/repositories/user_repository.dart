import 'package:uuid/uuid.dart';
import '../../core/services/supabase_client.dart';
import '../models/models.dart';

/// Repository for user-related operations
class UserRepository {
  final _client = SupabaseService.client;

  /// Get current user profile by userId
  Future<User?> getCurrentUser(String userId) async {
    final response = await _client
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();

    return response != null ? User.fromJson(response) : null;
  }

  /// Get user by ID
  Future<User?> getUserById(String userId) async {
    final response = await _client
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();

    return response != null ? User.fromJson(response) : null;
  }

  /// Get user by phone number
  Future<User?> getUserByPhone(String phone) async {
    final response = await _client
        .from('users')
        .select()
        .eq('phone', phone)
        .maybeSingle();

    return response != null ? User.fromJson(response) : null;
  }

  /// Create new user (used when OTP verified for first time)
  Future<String> createUser({
    required String phone,
    String? fullName,
    String? universityId,
    String? facultyId,
    String? academicYearId,
    UserRole role = UserRole.student,
  }) async {
    // Generate a UUID for the user
    const uuid = Uuid();
    final userId = uuid.v4();
    
    await _client.from('users').insert({
      'id': userId,
      'phone': phone,
      'full_name': fullName,
      'university_id': universityId,
      'faculty_id': facultyId,
      'academic_year_id': academicYearId,
      'role': role.name,
      'status': UserStatus.active.name,
      'created_at': DateTime.now().toIso8601String(),
    });

    return userId;
  }

  /// Update user profile by userId
  Future<User> updateProfile({
    required String userId,
    String? fullName,
    String? avatarUrl,
    String? universityId,
    String? facultyId,
    String? academicYearId,
  }) async {
    final updates = <String, dynamic>{};
    if (fullName != null) updates['full_name'] = fullName;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (universityId != null) updates['university_id'] = universityId;
    if (facultyId != null) updates['faculty_id'] = facultyId;
    if (academicYearId != null) updates['academic_year_id'] = academicYearId;

    final response = await _client
        .from('users')
        .update(updates)
        .eq('id', userId)
        .select()
        .single();

    return User.fromJson(response);
  }

  /// Update current user profile (legacy - requires stored userId)
  Future<User> updateCurrentProfile({
    required String userId,
    String? fullName,
    String? avatarUrl,
    String? universityId,
    String? facultyId,
    String? academicYearId,
  }) async {
    return updateProfile(
      userId: userId,
      fullName: fullName,
      avatarUrl: avatarUrl,
      universityId: universityId,
      facultyId: facultyId,
      academicYearId: academicYearId,
    );
  }

  /// Get subjects taught by instructor
  Future<List<Subject>> getInstructorSubjects(String instructorId) async {
    final response = await _client
        .from('instructor_subjects')
        .select('subjects(*)')
        .eq('instructor_id', instructorId);

    return (response as List)
        .map((json) => Subject.fromJson(json['subjects'] as Map<String, dynamic>))
        .toList();
  }

  /// Assign subject to instructor
  Future<void> assignSubject(String instructorId, String subjectId, {bool isPrimary = false}) async {
    await _client.from('instructor_subjects').insert({
      'instructor_id': instructorId,
      'subject_id': subjectId,
      'is_primary': isPrimary,
    });
  }

  /// Get all students (admin only)
  Future<List<User>> getAllStudents() async {
    final response = await _client
        .from('users')
        .select()
        .eq('role', 'student')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => User.fromJson(json))
        .toList();
  }

  /// Get all instructors (admin only)
  Future<List<User>> getAllInstructors() async {
    final response = await _client
        .from('users')
        .select()
        .or('role.eq.doctor,role.eq.assistant')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => User.fromJson(json))
        .toList();
  }

  /// Update user status (admin only)
  Future<User> updateUserStatus(String userId, UserStatus status) async {
    final response = await _client
        .from('users')
        .update({'status': status.name})
        .eq('id', userId)
        .select()
        .single();

    return User.fromJson(response);
  }

  /// Update user role (admin only)
  Future<User> updateUserRole(String userId, UserRole role) async {
    final response = await _client
        .from('users')
        .update({'role': role.name})
        .eq('id', userId)
        .select()
        .single();

    return User.fromJson(response);
  }
}
