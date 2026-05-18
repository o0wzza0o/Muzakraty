import 'package:equatable/equatable.dart';

/// User roles enum
enum UserRole {
  student,
  assistant,
  doctor,
  admin,
  superAdmin,
}

/// User status enum
enum UserStatus {
  active,
  pending,
  suspended,
  banned,
}

/// User model matching database schema (extends auth.users)
class User extends Equatable {
  final String id;
  final String? email;
  final String? phone;
  final String? fullName;
  final String? avatarUrl;
  final UserRole role;
  final UserStatus status;
  final String? universityId;
  final String? facultyId;
  final String? academicYearId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    this.email,
    this.phone,
    this.fullName,
    this.avatarUrl,
    this.role = UserRole.student,
    this.status = UserStatus.pending,
    this.universityId,
    this.facultyId,
    this.academicYearId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: _parseRole(json['role'] as String? ?? 'student'),
      status: _parseStatus(json['status'] as String? ?? 'pending'),
      universityId: json['university_id'] as String?,
      facultyId: json['faculty_id'] as String?,
      academicYearId: json['academic_year_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'role': role.name,
      'status': status.name,
      'university_id': universityId,
      'faculty_id': facultyId,
      'academic_year_id': academicYearId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isStudent => role == UserRole.student;
  bool get isDoctor => role == UserRole.doctor;
  bool get isAssistant => role == UserRole.assistant;
  bool get isAdmin => role == UserRole.admin || role == UserRole.superAdmin;
  bool get isActive => status == UserStatus.active;

  static UserRole _parseRole(String role) {
    switch (role) {
      case 'student':
        return UserRole.student;
      case 'assistant':
        return UserRole.assistant;
      case 'doctor':
        return UserRole.doctor;
      case 'admin':
        return UserRole.admin;
      case 'super_admin':
        return UserRole.superAdmin;
      default:
        return UserRole.student;
    }
  }

  static UserStatus _parseStatus(String status) {
    switch (status) {
      case 'active':
        return UserStatus.active;
      case 'pending':
        return UserStatus.pending;
      case 'suspended':
        return UserStatus.suspended;
      case 'banned':
        return UserStatus.banned;
      default:
        return UserStatus.pending;
    }
  }

  User copyWith({
    String? fullName,
    String? avatarUrl,
    UserRole? role,
    UserStatus? status,
    String? universityId,
    String? facultyId,
    String? academicYearId,
  }) {
    return User(
      id: id,
      email: email,
      phone: phone,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      universityId: universityId ?? this.universityId,
      facultyId: facultyId ?? this.facultyId,
      academicYearId: academicYearId ?? this.academicYearId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        phone,
        fullName,
        avatarUrl,
        role,
        status,
        universityId,
        facultyId,
        academicYearId,
      ];
}
