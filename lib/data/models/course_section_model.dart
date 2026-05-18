import 'package:equatable/equatable.dart';

/// Course Section model matching database schema
class CourseSection extends Equatable {
  final String id;
  final String courseId;
  final String title;
  final int orderNumber;
  final DateTime createdAt;

  const CourseSection({
    required this.id,
    required this.courseId,
    required this.title,
    this.orderNumber = 0,
    required this.createdAt,
  });

  factory CourseSection.fromJson(Map<String, dynamic> json) {
    return CourseSection(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      title: json['title'] as String,
      orderNumber: json['order_number'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'order_number': orderNumber,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, courseId, title, orderNumber];
}
