import 'package:equatable/equatable.dart';

/// Lesson Progress model matching database schema
class LessonProgress extends Equatable {
  final String id;
  final String userId;
  final String lessonId;
  final int watchedDuration; // in seconds
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime lastWatchedAt;

  const LessonProgress({
    required this.id,
    required this.userId,
    required this.lessonId,
    this.watchedDuration = 0,
    this.isCompleted = false,
    this.completedAt,
    required this.lastWatchedAt,
  });

  factory LessonProgress.fromJson(Map<String, dynamic> json) {
    return LessonProgress(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      lessonId: json['lesson_id'] as String,
      watchedDuration: json['watched_duration'] as int? ?? 0,
      isCompleted: json['is_completed'] as bool? ?? false,
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'] as String) 
          : null,
      lastWatchedAt: DateTime.parse(json['last_watched_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'lesson_id': lessonId,
      'watched_duration': watchedDuration,
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'last_watched_at': lastWatchedAt.toIso8601String(),
    };
  }

  /// Calculate progress percentage for this lesson
  double getProgressPercentage(int lessonTotalDuration) {
    if (lessonTotalDuration == 0) return 0.0;
    return (watchedDuration / lessonTotalDuration).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        lessonId,
        watchedDuration,
        isCompleted,
        completedAt,
        lastWatchedAt,
      ];
}
