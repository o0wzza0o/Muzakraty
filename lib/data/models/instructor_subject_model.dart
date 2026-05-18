import 'package:equatable/equatable.dart';

/// Instructor Subject model (many-to-many relationship)
class InstructorSubject extends Equatable {
  final String id;
  final String instructorId;
  final String subjectId;
  final bool isPrimary;
  final DateTime assignedAt;

  const InstructorSubject({
    required this.id,
    required this.instructorId,
    required this.subjectId,
    this.isPrimary = false,
    required this.assignedAt,
  });

  factory InstructorSubject.fromJson(Map<String, dynamic> json) {
    return InstructorSubject(
      id: json['id'] as String,
      instructorId: json['instructor_id'] as String,
      subjectId: json['subject_id'] as String,
      isPrimary: json['is_primary'] as bool? ?? false,
      assignedAt: DateTime.parse(json['assigned_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'instructor_id': instructorId,
      'subject_id': subjectId,
      'is_primary': isPrimary,
      'assigned_at': assignedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, instructorId, subjectId, isPrimary];
}
