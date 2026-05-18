import 'package:equatable/equatable.dart';

/// Subject model matching database schema
class Subject extends Equatable {
  final String id;
  final String? universityId;
  final String? facultyId;
  final String? academicYearId;
  final String nameAr;
  final String? nameEn;
  final String? code;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Subject({
    required this.id,
    this.universityId,
    this.facultyId,
    this.academicYearId,
    required this.nameAr,
    this.nameEn,
    this.code,
    this.description,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String,
      universityId: json['university_id'] as String?,
      facultyId: json['faculty_id'] as String?,
      academicYearId: json['academic_year_id'] as String?,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String?,
      code: json['code'] as String?,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'university_id': universityId,
      'faculty_id': facultyId,
      'academic_year_id': academicYearId,
      'name_ar': nameAr,
      'name_en': nameEn,
      'code': code,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        universityId,
        facultyId,
        academicYearId,
        nameAr,
        nameEn,
        code,
        description,
        isActive,
      ];
}
