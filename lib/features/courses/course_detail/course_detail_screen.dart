import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/repositories/repositories.dart';
import '../../auth/bloc/auth_bloc.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final _courseRepo = CourseRepository();
  Map<String, dynamic>? _course;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourse();
  }

  Future<void> _loadCourse() async {
    final userId = context.read<AuthBloc>().currentUserId;
    if (userId == null) return;

    try {
      final course = await _courseRepo.getCourseDetails(widget.courseId, userId);
      if (mounted) setState(() { _course = course; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_course == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('الكورس غير موجود')),
      );
    }

    final course = _course!;
    final sections = course['sections'] as List? ?? [];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with gradient
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    course['thumbnail_url'] ?? _getDefaultImage(),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.primary, AppColors.primaryDark],
                          ),
                        ),
                        child: Icon(Icons.school, size: 80, color: Colors.white.withValues(alpha: 0.2)),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.background.withValues(alpha: 0.1),
                          AppColors.background.withValues(alpha: 0.6),
                          AppColors.background,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.4), blurRadius: 12)],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.play_arrow_rounded, color: Colors.white),
                              SizedBox(width: 6),
                              Text(AppStrings.previewLesson, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course['course_title'] ?? 'بدون عنوان', style: Theme.of(context).textTheme.headlineLarge),
                  if (course['subject_name'] != null && (course['subject_name'] as String).isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(course['subject_name'], style: Theme.of(context).textTheme.bodySmall),
                  ],
                  const SizedBox(height: 20),

                  // Instructor
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: 0.3)),
                          child: const Icon(Icons.person, color: AppColors.accent),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppStrings.instructor, style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                            Text(course['instructor_name'] ?? 'غير معروف', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  if (course['description'] != null) ...[
                    Text(course['description'], style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.8)),
                    const SizedBox(height: 24),
                  ],

                  // Curriculum
                  if (sections.isNotEmpty) ...[
                    Text(AppStrings.curriculum, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 12),
                    ...sections.map<Widget>((section) {
                      final lessons = section['lessons'] as List? ?? [];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(section['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 15)),
                          const SizedBox(height: 8),
                          ...lessons.map<Widget>((lesson) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    (lesson['is_free'] == true) ? Icons.play_circle_filled : Icons.lock_outline,
                                    color: (lesson['is_free'] == true) ? AppColors.accent : AppColors.textHint,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(lesson['title'] ?? '', style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                                  ),
                                  if (lesson['is_free'] == true)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                                      child: const Text(AppStrings.free, style: TextStyle(fontSize: 10, color: AppColors.success)),
                                    ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 12),
                        ],
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),

          // Enroll button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  (course['is_paid'] == true) ? '${AppStrings.enroll} - ${course['price']} جنيه' : '${AppStrings.enroll} - ${AppStrings.free}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
        ],
      ),
    );
  }

  String _getDefaultImage() {
    return 'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?q=80&w=1000&auto=format&fit=crop';
  }
}
