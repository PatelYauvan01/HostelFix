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

  // Fetch all complaints for authenticated users (requires select policy)
  Future<List<Map<String, dynamic>>> getAllComplaints() async {
    try {
      final data = await _supabase
          .from('complaints')
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      return [];
    }
  }

  // Fetch profile names for a given list of user ids
  Future<Map<String, String>> getProfileNamesByIds(List<String> userIds) async {
    if (userIds.isEmpty) return {};
    try {
      final data = await _supabase
          .from('profiles')
          .select('id, full_name')
          .inFilter('id', userIds);

      final rows = List<Map<String, dynamic>>.from(data);
      return {
        for (final row in rows)
          row['id'].toString():
              (row['full_name']?.toString().trim().isNotEmpty == true)
                  ? row['full_name'].toString()
                  : 'Student',
      };
    } catch (e) {
      return {};
    }
  }

  // Fetch all students for warden student listing
  Future<List<Map<String, dynamic>>> getAllStudents() async {
    try {
      final Map<String, Map<String, dynamic>> byId = {};

      final studentProfileRows = await _supabase
          .from('student_profiles')
          .select('id, username, full_name, email, phone_number, room_number')
          .order('full_name', ascending: true);

      for (final row in List<Map<String, dynamic>>.from(studentProfileRows)) {
        final id = row['id']?.toString();
        if (id == null || id.isEmpty) continue;
        byId[id] = row;
      }

      // Legacy fallback source for old records not yet copied to student_profiles.
      final data = await _supabase
          .from('profiles')
          .select('id, username, full_name, email, phone_number, room_number, role')
          .or('role.eq.student,role.eq.Student,role.eq.STUDENT')
          .order('full_name', ascending: true);

      for (final row in List<Map<String, dynamic>>.from(data)) {
        final id = row['id']?.toString();
        if (id == null || id.isEmpty) continue;
        byId.putIfAbsent(id, () => row);
      }

      final merged = byId.values.toList();
      merged.sort((a, b) {
        final aName = (a['full_name'] ?? '').toString().toLowerCase();
        final bName = (b['full_name'] ?? '').toString().toLowerCase();
        return aName.compareTo(bName);
      });
      return merged;
    } on PostgrestException catch (e) {
      // Some schemas may not include student_profiles/email in old setups.
      if (e.code == 'PGRST204') {
        final data = await _supabase
            .from('profiles')
            .select('id, username, full_name, phone_number, room_number, role')
          .or('role.eq.student,role.eq.Student,role.eq.STUDENT')
            .order('full_name', ascending: true);
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // Create a new complaint for the current user
  Future<void> createComplaint({
    required String title,
    required String description,
    required String category,
    required String priority,
    String? photoUrl,
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not signed in');
    }

    final payload = <String, dynamic>{
      'user_id': userId,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'status': 'PENDING',
    };

    if (photoUrl != null && photoUrl.isNotEmpty) {
      payload['photo_url'] = photoUrl;
    }

    await _supabase.from('complaints').insert(payload);
  }

  // Update complaint status for warden actions
  Future<void> updateComplaintStatus({
    required String complaintId,
    required String status,
  }) async {
    await _supabase
        .from('complaints')
        .update({'status': status})
        .eq('id', complaintId);
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
