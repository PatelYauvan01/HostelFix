import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Sign in with username (or email) and password
  Future<AuthResponse> signInWithUsernameOrEmail(String identifier, String password) async {
    String email = identifier;

    // 1. Check if identifier is NOT an email (simple check)
    if (!identifier.contains('@')) {
      // 2. Query profiles to find the email for this username
      final response = await _supabase
          .from('profiles')
          .select('email')
          .eq('username', identifier)
          .maybeSingle();

      if (response == null) {
        throw const AuthException('Username not found');
      }
      email = response['email'];
    }

    // 3. Sign in with the resolved email
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String fullName,
    required String phoneNumber,
    required String roomNumber,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'username': username,
      },
    );

    if (response.user != null) {
      await _supabase.from('profiles').upsert({
        'id': response.user!.id,
        'username': username,
        'full_name': fullName,
        'email': email, // Save email for lookup
        'phone_number': phoneNumber,
        'room_number': roomNumber,
        'role': 'student', // Default role
        'updated_at': DateTime.now().toIso8601String(),
      });
    }

    return response;
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Get profile data (if you have a profiles table)
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();
      return data;
    } catch (e) {
      // Profile might not exist yet or error fetchings
      return null;
    }
  }
}
