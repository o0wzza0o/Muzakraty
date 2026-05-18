import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase client configuration and instance
class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Get the Supabase client instance
  static SupabaseClient get client => _client;

  /// Get the current authenticated user
  static User? get currentUser => _client.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Get current user ID
  static String? get currentUserId => currentUser?.id;

  /// Initialize Supabase (call in main.dart before runApp)
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://wzpbceicdrneseedjhit.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind6cGJjZWljZHJuZXNlZWRqaGl0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkwMTU3MzcsImV4cCI6MjA5NDU5MTczN30.oHVm-ChRCsQBhv0SRsG8ltHrYusrLmLRbUe7mkdG2W4',
      debug: true, // Enable debug logging in development
    );
  }

  /// Auth operations
  static GoTrueClient get auth => _client.auth;

  /// Database operations
  static SupabaseQueryBuilder from(String table) => _client.from(table);

  /// Real-time subscriptions
  static SupabaseStreamBuilder stream(String table) => _client.from(table).stream(primaryKey: ['id']);

  /// RPC (Remote Procedure Call) for database functions
  static Future<dynamic> rpc(String function, {Map<String, dynamic>? params}) async {
    return await _client.rpc(function, params: params);
  }
}
