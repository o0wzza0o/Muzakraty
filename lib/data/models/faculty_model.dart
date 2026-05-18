import 'package:equatable/equatable.dart';

/// Faculty model matching database schema
class Faculty extends Equatable {
  final String id;
  final String universityId;
  final String nameAr;
  final String? nameEn;
  final int yearsCount;
  final bool isPrimary;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Faculty({
    required this.id,
    required this.universityId,
    required this.nameAr,
    this.nameEn,
    required this.yearsCount,
    this.isPrimary = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Faculty.fromJson(Map<String, dynamic> json) {
    return Faculty(
      id: json['id'] as String,
      universityId: json['university_id'] as String,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String?,
      yearsCount: json['years_count'] as int,
      isPrimary: json['is_primary'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'university_id': universityId,
      'name_ar': nameAr,
      'name_en': nameEn,
      'years_count': yearsCount,
      'is_primary': isPrimary,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, universityId, nameAr, nameEn, yearsCount, isPrimary];
}
