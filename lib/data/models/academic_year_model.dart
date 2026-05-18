import 'package:equatable/equatable.dart';

/// Academic Year model matching database schema
class AcademicYear extends Equatable {
  final String id;
  final String facultyId;
  final int yearNumber;
  final String nameAr;
  final DateTime createdAt;

  const AcademicYear({
    required this.id,
    required this.facultyId,
    required this.yearNumber,
    required this.nameAr,
    required this.createdAt,
  });

  factory AcademicYear.fromJson(Map<String, dynamic> json) {
    return AcademicYear(
      id: json['id'] as String,
      facultyId: json['faculty_id'] as String,
      yearNumber: json['year_number'] as int,
      nameAr: json['name_ar'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'faculty_id': facultyId,
      'year_number': yearNumber,
      'name_ar': nameAr,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, facultyId, yearNumber, nameAr];
}
