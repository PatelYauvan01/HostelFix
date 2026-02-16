import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user ID
  String? get currentUserId => _supabase.auth.currentUser?.id;

  // Fetch complaints for the current user
  Future<List<Map<String, dynamic>>> getUserComplaints() async {
    final userId = currentUserId;
    if (userId == null) return [];

    try {
      final data = await _supabase
          .from('complaints')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      // Handle error or return empty list
      return [];
    }
  }

  // Get active complaint count
  Future<int> getActiveComplaintCount() async {
    final userId = currentUserId;
    if (userId == null) return 0;
    try {
      final response = await _supabase
          .from('complaints')
          .count()
          .eq('user_id', userId)
          .neq('status', 'RESOLVED'); // Count anything not resolved as active
      return response;
    } catch (e) {
      return 0;
    }
  }

  // Get resolved complaint count
  Future<int> getResolvedComplaintCount() async {
    final userId = currentUserId;
    if (userId == null) return 0;
    try {
      final response = await _supabase
          .from('complaints')
          .count()
          .eq('user_id', userId)
          .eq('status', 'RESOLVED');
      return response;
    } catch (e) {
      return 0;
    }
  }
}
