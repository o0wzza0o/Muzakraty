import '../../core/services/supabase_client.dart';
import '../models/models.dart';

/// Repository for university-related operations
class UniversityRepository {
  final _client = SupabaseService.client;

  /// Get all active universities
  Future<List<University>> getAllUniversities() async {
    final response = await _client
        .from('universities')
        .select()
        .eq('is_active', true)
        .order('name_ar');

    return (response as List)
        .map((json) => University.fromJson(json))
        .toList();
  }

  /// Get university by ID
  Future<University?> getUniversityById(String id) async {
    final response = await _client
        .from('universities')
        .select()
        .eq('id', id)
        .maybeSingle();

    return response != null ? University.fromJson(response) : null;
  }

  /// Get universities by type (public, private, etc.)
  Future<List<University>> getUniversitiesByType(String type) async {
    final response = await _client
        .from('universities')
        .select()
        .eq('type', type)
        .eq('is_active', true)
        .order('name_ar');

    return (response as List)
        .map((json) => University.fromJson(json))
        .toList();
  }

  /// Search universities by name
  Future<List<University>> searchUniversities(String query) async {
    final response = await _client
        .from('universities')
        .select()
        .or('name_ar.ilike.%$query%,name_en.ilike.%$query%')
        .eq('is_active', true)
        .order('name_ar');

    return (response as List)
        .map((json) => University.fromJson(json))
        .toList();
  }
}
