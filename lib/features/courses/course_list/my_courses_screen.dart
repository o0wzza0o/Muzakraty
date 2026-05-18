import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/repositories/repositories.dart';
import '../../auth/bloc/auth_bloc.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  final _courseRepo = CourseRepository();
  bool _isLoading = true;
  List<Map<String, dynamic>> _courses = [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final userId = context.read<AuthBloc>().currentUserId;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }
    
    try {
      final courses = await _courseRepo.getCoursesForStudent(userId);
      if (mounted) {
        setState(() {
          _courses = courses;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.myCourses)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _courses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_circle_outline, size: 80, color: AppColors.textHint.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text('لم تسجل في أي كورس بعد', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => context.go('/home'),
                        child: const Text('تصفح الكورسات', style: TextStyle(color: AppColors.accent)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _courses.length,
                  itemBuilder: (context, index) {
                    final course = _courses[index];
                    return GestureDetector(
                      onTap: () => context.push('/course/${course['id']}'),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            // Thumbnail
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      course['thumbnail_url'] ?? _getDefaultImage(),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        decoration: BoxDecoration(
                                          gradient: AppColors.primaryGradient,
                                        ),
                                        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
                                      ),
                                    ),
                                    Container(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      child: const Center(
                                        child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course['title'] ?? 'بدون عنوان',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    course['instructor_name'] ?? 'غير معروف',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                                  ),
                                  const SizedBox(height: 8),
                                  // Progress bar
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: (course['progress_percentage'] ?? 0) / 100,
                                      minHeight: 4,
                                      backgroundColor: AppColors.surfaceLight,
                                      valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${course['progress_percentage'] ?? 0}% مكتمل',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  String _getDefaultImage() {
    return 'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?q=80&w=600&auto=format&fit=crop';
  }
}
