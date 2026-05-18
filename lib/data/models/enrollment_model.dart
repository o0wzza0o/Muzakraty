import 'package:equatable/equatable.dart';

/// Enrollment model matching database schema
class Enrollment extends Equatable {
  final String id;
  final String userId;
  final String courseId;
  final DateTime enrolledAt;
  final DateTime? completedAt;
  final bool isActive;

  const Enrollment({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.enrolledAt,
    this.completedAt,
    this.isActive = true,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      courseId: json['course_id'] as String,
      enrolledAt: DateTime.parse(json['enrolled_at'] as String),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'] as String) 
          : null,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'enrolled_at': enrolledAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'is_active': isActive,
    };
  }

  bool get isCompleted => completedAt != null;

  @override
  List<Object?> get props => [id, userId, courseId, enrolledAt, completedAt, isActive];
}
