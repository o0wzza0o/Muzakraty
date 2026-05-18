import 'package:equatable/equatable.dart';

/// University model matching database schema
class University extends Equatable {
  final String id;
  final String nameAr;
  final String? nameEn;
  final String type; // public, private, azhar, ahly, International
  final String? logoUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const University({
    required this.id,
    required this.nameAr,
    this.nameEn,
    required this.type,
    this.logoUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      id: json['id'] as String,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String?,
      type: json['type'] as String,
      logoUrl: json['logo_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_ar': nameAr,
      'name_en': nameEn,
      'type': type,
      'logo_url': logoUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, nameAr, nameEn, type, logoUrl, isActive];
}
