import 'package:equatable/equatable.dart';

/// Course approval status enum
enum CourseApprovalStatus {
  pending,
  approved,
  rejected,
}

/// Course model matching database schema
class Course extends Equatable {
  final String id;
  final String subjectId;
  final String? instructorId;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final bool isPaid;
  final double price;
  final CourseApprovalStatus approvalStatus;
  final bool isActive;
  final int studentsCount;
  final double rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Course({
    required this.id,
    required this.subjectId,
    this.instructorId,
    required this.title,
    this.description,
    this.thumbnailUrl,
    this.isPaid = false,
    this.price = 0.0,
    this.approvalStatus = CourseApprovalStatus.pending,
    this.isActive = true,
    this.studentsCount = 0,
    this.rating = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      subjectId: json['subject_id'] as String,
      instructorId: json['instructor_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      isPaid: json['is_paid'] as bool? ?? false,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      approvalStatus: _parseApprovalStatus(json['approval_status'] as String? ?? 'pending'),
      isActive: json['is_active'] as bool? ?? true,
      studentsCount: json['students_count'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject_id': subjectId,
      'instructor_id': instructorId,
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'is_paid': isPaid,
      'price': price,
      'approval_status': _approvalStatusToString(approvalStatus),
      'is_active': isActive,
      'students_count': studentsCount,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isApproved => approvalStatus == CourseApprovalStatus.approved;
  bool get isPending => approvalStatus == CourseApprovalStatus.pending;
  bool get isRejected => approvalStatus == CourseApprovalStatus.rejected;

  static CourseApprovalStatus _parseApprovalStatus(String status) {
    switch (status) {
      case 'pending':
        return CourseApprovalStatus.pending;
      case 'approved':
        return CourseApprovalStatus.approved;
      case 'rejected':
        return CourseApprovalStatus.rejected;
      default:
        return CourseApprovalStatus.pending;
    }
  }

  static String _approvalStatusToString(CourseApprovalStatus status) {
    switch (status) {
      case CourseApprovalStatus.pending:
        return 'pending';
      case CourseApprovalStatus.approved:
        return 'approved';
      case CourseApprovalStatus.rejected:
        return 'rejected';
    }
  }

  Course copyWith({
    String? title,
    String? description,
    String? thumbnailUrl,
    bool? isPaid,
    double? price,
    CourseApprovalStatus? approvalStatus,
    bool? isActive,
    int? studentsCount,
    double? rating,
  }) {
    return Course(
      id: id,
      subjectId: subjectId,
      instructorId: instructorId,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isPaid: isPaid ?? this.isPaid,
      price: price ?? this.price,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      isActive: isActive ?? this.isActive,
      studentsCount: studentsCount ?? this.studentsCount,
      rating: rating ?? this.rating,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        subjectId,
        instructorId,
        title,
        description,
        thumbnailUrl,
        isPaid,
        price,
        approvalStatus,
        isActive,
        studentsCount,
        rating,
      ];
}
