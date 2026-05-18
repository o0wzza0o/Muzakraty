import '../../core/services/supabase_client.dart';
import '../models/models.dart';

/// Repository for faculty-related operations
class FacultyRepository {
  final _client = SupabaseService.client;

  /// Get all faculties for a university
  Future<List<Faculty>> getFacultiesByUniversity(String universityId) async {
    final response = await _client
        .from('faculties')
        .select()
        .eq('university_id', universityId)
        .order('name_ar');

    return (response as List)
        .map((json) => Faculty.fromJson(json))
        .toList();
  }

  /// Get faculty by ID
  Future<Faculty?> getFacultyById(String id) async {
    final response = await _client
        .from('faculties')
        .select()
        .eq('id', id)
        .maybeSingle();

    return response != null ? Faculty.fromJson(response) : null;
  }

  /// Get faculties with academic years included
  Future<List<Map<String, dynamic>>> getFacultiesWithYears(String universityId) async {
    final response = await _client
        .from('faculties')
        .select('*, academic_years(*)')
        .eq('university_id', universityId)
        .order('name_ar');

    return (response as List).map((e) => e as Map<String, dynamic>).toList();
  }
}
