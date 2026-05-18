import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final VoidCallback? onTap;
  final double width;

  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
    this.width = 260,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        margin: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Container(
              height: 140,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image
                    Image.network(
                      course['thumbnail_url'] ?? _getDefaultImage(),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary.withValues(alpha: 0.8),
                                AppColors.primaryDark,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.school,
                              size: 48,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                        );
                      },
                    ),
                    // Subtle gradient overlay for the top badge
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.5),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5],
                        ),
                      ),
                    ),
                  // Premium/Free badge
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (course['is_paid'] as bool? ?? false)
                            ? AppColors.warning.withValues(alpha: 0.9)
                            : AppColors.success.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            (course['is_paid'] as bool? ?? false) ? Icons.lock : Icons.play_circle_fill,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            (course['is_paid'] as bool? ?? false) ? 'مدفوع' : 'مجاني',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Info
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course['course_title'] ?? 'بدون عنوان',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    course['instructor_name'] ?? 'غير معروف',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Rating
                  Row(
                    children: [
                      ...List.generate(5, (i) {
                        final rating = (course['rating'] as num?)?.toDouble() ?? 0.0;
                        return Icon(
                          i < rating.floor()
                              ? Icons.star_rounded
                              : (i < rating
                                  ? Icons.star_half_rounded
                                  : Icons.star_border_rounded),
                          size: 16,
                          color: AppColors.starFilled,
                        );
                      }),
                      const SizedBox(width: 4),
                      Text(
                        ((course['rating'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Students count
                  Row(
                    children: [
                      const Icon(Icons.people_outline, size: 14, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        '${course['students_count'] ?? 0} طالب',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                      const Spacer(),
                      // Progress indicator if enrolled
                      if ((course['progress_percentage'] as int? ?? 0) > 0) ...[
                        Icon(
                          Icons.play_circle_outline,
                          size: 14,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${course['progress_percentage']}%',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDefaultImage() {
    return 'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?q=80&w=600&auto=format&fit=crop';
  }
}
