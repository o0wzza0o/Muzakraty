import 'package:equatable/equatable.dart';

/// Lesson model matching database schema
class Lesson extends Equatable {
  final String id;
  final String sectionId;
  final String title;
  final String? videoUrl;
  final int? duration; // in seconds
  final bool isFree;
  final int orderNumber;
  final DateTime createdAt;

  const Lesson({
    required this.id,
    required this.sectionId,
    required this.title,
    this.videoUrl,
    this.duration,
    this.isFree = false,
    this.orderNumber = 0,
    required this.createdAt,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      sectionId: json['section_id'] as String,
      title: json['title'] as String,
      videoUrl: json['video_url'] as String?,
      duration: json['duration'] as int?,
      isFree: json['is_free'] as bool? ?? false,
      orderNumber: json['order_number'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'section_id': sectionId,
      'title': title,
      'video_url': videoUrl,
      'duration': duration,
      'is_free': isFree,
      'order_number': orderNumber,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Format duration as HH:MM:SS or MM:SS
  String get formattedDuration {
    if (duration == null) return '--:--';
    
    final hours = duration! ~/ 3600;
    final minutes = (duration! % 3600) ~/ 60;
    final seconds = duration! % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  List<Object?> get props => [id, sectionId, title, videoUrl, duration, isFree, orderNumber];
}
