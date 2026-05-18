import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/supabase_client.dart';
import '../../data/repositories/repositories.dart';
import '../../shared/widgets/course_card.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event_state.dart' as app_auth;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _courseRepository = CourseRepository();
  
  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _recommendedCourses = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Get userId from AuthBloc
      final authBloc = context.read<AuthBloc>();
      final userId = authBloc.currentUserId;
      
      if (userId == null) {
        setState(() {
          _errorMessage = 'المستخدم غير مسجل الدخول';
          _isLoading = false;
        });
        return;
      }
      
      // Load courses for the student
      final courses = await _courseRepository.getCoursesForStudent(userId);
      
      // Load recommended courses
      final recommended = await _courseRepository.getRecommendedCourses(userId, limit: 10);
      
      if (mounted) {
        setState(() {
          _courses = courses;
          _recommendedCourses = recommended;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'حدث خطأ أثناء تحميل البيانات: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? _buildErrorWidget()
                : CustomScrollView(
                    slivers: [
                      // Welcome header
                      _buildWelcomeHeader(),

                      // Continue watching
                      if (_courses.where((c) => c['progress_percentage'] > 0).isNotEmpty) ...[
                        _buildSectionHeader(AppStrings.continueWatching, AppStrings.seeAll),
                        _buildCoursesList(
                          _courses.where((c) => c['progress_percentage'] > 0).toList(),
                        ),
                      ],

                      // Recommended
                      _buildSectionHeader(AppStrings.recommended, AppStrings.seeAll),
                      _buildCoursesList(_recommendedCourses),

                      // Popular
                      _buildSectionHeader(AppStrings.popularInFaculty, AppStrings.seeAll),
                      _buildCoursesList(_courses.take(10).toList()),
                      
                      const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
                    ],
                  ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(_errorMessage),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  String _facultyName = '';

  Future<void> _loadFacultyName(String? facultyId) async {
    if (facultyId == null || _facultyName.isNotEmpty) return;
    try {
      final response = await SupabaseService.client
          .from('faculties')
          .select('name_ar')
          .eq('id', facultyId)
          .maybeSingle();
      if (mounted && response != null) {
        setState(() => _facultyName = 'طالب في ${response['name_ar'] ?? ''}');
      }
    } catch (e) {
      // Silently handle error
    }
  }

  Widget _buildWelcomeHeader() {
    return BlocBuilder<AuthBloc, app_auth.AuthState>(
      builder: (context, state) {
        String firstName = 'طالب';
        
        if (state is app_auth.Authenticated) {
          firstName = state.user.fullName?.split(' ').first ?? 'طالب';
          if (_facultyName.isEmpty && state.user.facultyId != null) {
            _loadFacultyName(state.user.facultyId);
          }
        }
        
        return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, Color(0xFF283593)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.school_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${AppStrings.welcomeBack}، $firstName 👋',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (_facultyName.isNotEmpty)
                        Text(
                          _facultyName,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'استمر في التعلم وحقق أهدافك الأكاديمية',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
        );
      },
    );
  }

  Widget _buildCoursesList(List<Map<String, dynamic>> courses) {
    if (courses.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('لا توجد كورسات متاحة حالياً'),
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 300,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(right: 16),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return CourseCard(
              course: course,
              onTap: () => context.push('/course/${course['course_id']}'),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String action) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/search'),
              child: Text(
                action,
                style: const TextStyle(color: AppColors.accent, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
