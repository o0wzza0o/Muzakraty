import '../../core/services/supabase_client.dart';
import '../models/models.dart';

/// Repository for course-related operations
class CourseRepository {
  final _client = SupabaseService.client;

  /// Get courses for current student (based on user's faculty)
  Future<List<Map<String, dynamic>>> getCoursesForStudent(String userId) async {
    // Get all approved & active courses
    var query = _client
        .from('courses')
        .select('*, users!courses_instructor_id_fkey(full_name), subjects(name_ar, faculty_id)')
        .eq('is_active', true)
        .eq('approval_status', 'approved');
    
    final response = await query.order('created_at', ascending: false);
    
    // Map results to include instructor name and course_id
    return (response as List).map((course) {
      return {
        'course_id': course['id'],
        'course_title': course['title'],
        'description': course['description'],
        'thumbnail_url': course['thumbnail_url'],
        'instructor_name': course['users']?['full_name'] ?? 'غير معروف',
        'is_paid': course['is_paid'] ?? false,
        'price': course['price'] ?? 0,
        'subject_name': course['subjects']?['name_ar'] ?? '',
        'progress_percentage': 0,
      };
    }).toList();
  }

  /// Get recommended courses for student
  Future<List<Map<String, dynamic>>> getRecommendedCourses(String userId, {int limit = 10}) async {
    final response = await _client
        .from('courses')
        .select('*, users!courses_instructor_id_fkey(full_name), subjects(name_ar)')
        .eq('is_active', true)
        .eq('approval_status', 'approved')
        .order('created_at', ascending: false)
        .limit(limit);
    
    return (response as List).map((course) {
      return {
        'course_id': course['id'],
        'course_title': course['title'],
        'description': course['description'],
        'thumbnail_url': course['thumbnail_url'],
        'instructor_name': course['users']?['full_name'] ?? 'غير معروف',
        'is_paid': course['is_paid'] ?? false,
        'price': course['price'] ?? 0,
        'subject_name': course['subjects']?['name_ar'] ?? '',
        'progress_percentage': 0,
      };
    }).toList();
  }

  /// Get course details with sections and lessons
  Future<Map<String, dynamic>?> getCourseDetails(String courseId, String userId) async {
    final response = await _client
        .from('courses')
        .select('*, users!courses_instructor_id_fkey(full_name), subjects(name_ar), course_sections(*, lessons(*))')
        .eq('id', courseId)
        .maybeSingle();

    if (response == null) return null;
    
    return {
      'course_id': response['id'],
      'course_title': response['title'],
      'description': response['description'],
      'thumbnail_url': response['thumbnail_url'],
      'instructor_name': response['users']?['full_name'] ?? 'غير معروف',
      'is_paid': response['is_paid'] ?? false,
      'price': response['price'] ?? 0,
      'subject_name': response['subjects']?['name_ar'] ?? '',
      'sections': response['course_sections'] ?? [],
    };
  }

  /// Get courses by instructor (for doctor dashboard)
  Future<List<Map<String, dynamic>>> getInstructorCourses(String instructorId) async {
    final response = await _client
        .from('courses')
        .select('*, subjects(name_ar)')
        .eq('instructor_id', instructorId)
        .order('created_at', ascending: false);

    return (response as List).map((course) {
      return {
        'course_id': course['id'],
        'course_title': course['title'],
        'description': course['description'],
        'thumbnail_url': course['thumbnail_url'],
        'is_paid': course['is_paid'] ?? false,
        'price': course['price'] ?? 0,
        'subject_name': course['subjects']?['name_ar'] ?? '',
        'approval_status': course['approval_status'],
      };
    }).toList();
  }

  /// Search courses
  Future<List<Map<String, dynamic>>> searchCourses(String query) async {
    final response = await _client
        .from('courses')
        .select('*, users!courses_instructor_id_fkey(full_name), subjects(name_ar)')
        .eq('is_active', true)
        .eq('approval_status', 'approved')
        .ilike('title', '%$query%')
        .order('created_at', ascending: false)
        .limit(20);

    return (response as List).map((course) {
      return {
        'course_id': course['id'],
        'course_title': course['title'],
        'description': course['description'],
        'thumbnail_url': course['thumbnail_url'],
        'instructor_name': course['users']?['full_name'] ?? 'غير معروف',
        'is_paid': course['is_paid'] ?? false,
        'price': course['price'] ?? 0,
        'subject_name': course['subjects']?['name_ar'] ?? '',
        'rating': 0.0,
      };
    }).toList();
  }

  /// Create new course (for instructors)
  Future<Course> createCourse({
    required String instructorId,
    required String subjectId,
    required String title,
    String? description,
    String? thumbnailUrl,
    bool isPaid = false,
    double price = 0.0,
  }) async {
    final response = await _client
        .from('courses')
        .insert({
          'subject_id': subjectId,
          'instructor_id': instructorId,
          'title': title,
          'description': description,
          'thumbnail_url': thumbnailUrl,
          'is_paid': isPaid,
          'price': price,
          'approval_status': 'pending',
        })
        .select()
        .single();

    return Course.fromJson(response);
  }

  /// Update course
  Future<Course> updateCourse(
    String courseId, {
    String? title,
    String? description,
    String? thumbnailUrl,
    bool? isPaid,
    double? price,
    bool? isActive,
  }) async {
    final updates = <String, dynamic>{};
    if (title != null) updates['title'] = title;
    if (description != null) updates['description'] = description;
    if (thumbnailUrl != null) updates['thumbnail_url'] = thumbnailUrl;
    if (isPaid != null) updates['is_paid'] = isPaid;
    if (price != null) updates['price'] = price;
    if (isActive != null) updates['is_active'] = isActive;

    final response = await _client
        .from('courses')
        .update(updates)
        .eq('id', courseId)
        .select()
        .single();

    return Course.fromJson(response);
  }

  /// Enroll student in course
  Future<bool> enrollInCourse(String courseId, String studentId) async {
    final result = await _client.rpc(
      'enroll_student',
      params: {
        'student_uuid': studentId,
        'course_uuid': courseId,
      },
    );

    return result as bool;
  }

  /// Check if user is enrolled in course
  Future<bool> isEnrolled(String courseId, String userId) async {
    final response = await _client
        .from('enrollments')
        .select()
        .eq('user_id', userId)
        .eq('course_id', courseId)
        .maybeSingle();

    return response != null;
  }

  /// Get course progress percentage
  Future<int> getCourseProgress(String courseId, String userId) async {
    final result = await _client.rpc(
      'get_course_progress',
      params: {
        'student_uuid': userId,
        'course_uuid': courseId,
      },
    );

    return result as int? ?? 0;
  }

  /// Create course section
  Future<CourseSection> createSection({
    required String courseId,
    required String title,
    int orderNumber = 0,
  }) async {
    final response = await _client
        .from('course_sections')
        .insert({
          'course_id': courseId,
          'title': title,
          'order_number': orderNumber,
        })
        .select()
        .single();

    return CourseSection.fromJson(response);
  }

  /// Create lesson
  Future<Lesson> createLesson({
    required String sectionId,
    required String title,
    String? videoUrl,
    int? duration,
    bool isFree = false,
    int orderNumber = 0,
  }) async {
    final response = await _client
        .from('lessons')
        .insert({
          'section_id': sectionId,
          'title': title,
          'video_url': videoUrl,
          'duration': duration,
          'is_free': isFree,
          'order_number': orderNumber,
        })
        .select()
        .single();

    return Lesson.fromJson(response);
  }

  /// Update lesson progress
  Future<bool> updateLessonProgress(
    String lessonId,
    String userId, {
    required int watchedSeconds,
    bool markCompleted = false,
  }) async {
    final result = await _client.rpc(
      'update_lesson_progress',
      params: {
        'student_uuid': userId,
        'lesson_uuid': lessonId,
        'watched_seconds': watchedSeconds,
        'mark_completed': markCompleted,
      },
    );

    return result as bool;
  }

  /// Check if user can access lesson
  Future<bool> canAccessLesson(String lessonId, String userId) async {
    final result = await _client.rpc(
      'can_access_lesson',
      params: {
        'student_uuid': userId,
        'lesson_uuid': lessonId,
      },
    );

    return result as bool;
  }
}
