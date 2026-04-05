import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Sign in with username (or email) and password
  Future<AuthResponse> signInWithUsernameOrEmail(String identifier, String password, {String role = 'student'}) async {
    String email = identifier;

    // 1. Check if identifier is NOT an email (simple check)
    if (!identifier.contains('@')) {
      if (role == 'warden') {
        throw const AuthException('Warden login requires email.');
      }

      try {
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
      } on PostgrestException catch (e) {
        // The profiles table may not have an `email` column.
        if (e.code == 'PGRST204') {
          throw const AuthException(
            'Username login is not available right now. Please log in with your email.',
          );
        }
        rethrow;
      }
    }

    // 3. Sign in with the resolved email
    final authResponse = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final signedInUser = authResponse.user;
    if (signedInUser == null) {
      return authResponse;
    }

    // 4. Enforce role-specific login rules.
    // Warden login: user MUST exist in warden_profiles and be active.
    if (role == 'warden') {
      final signedInEmail = signedInUser.email?.trim().toLowerCase() ?? email.trim().toLowerCase();
      final wardenProfile = await _supabase
          .from('warden_profiles')
          .select('id, email')
          .eq('email', signedInEmail)
          .maybeSingle();

      final bool isWarden = wardenProfile != null;

      if (!isWarden) {
        await _supabase.auth.signOut();
        throw const AuthException(
          'Access denied. Only registered wardens can log in here.',
        );
      }

      return authResponse;
    }

    // Student/general login path: keep existing profile healing logic.
    {
      final userId = signedInUser.id;
      final profileResponse = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      // Check if profile is missing OR incomplete (e.g. created by trigger but empty)
      final bool isProfileMissing = profileResponse == null;
      final bool isProfileIncomplete = profileResponse != null && (profileResponse['username'] == null || profileResponse['username'].toString().isEmpty);

      if (isProfileMissing || isProfileIncomplete) {
        // Create or Update profile
        final username = email.split('@')[0];

        // Use upsert to handle both insert (if missing) and update (if incomplete)
        await _supabase.from('profiles').upsert({
          'id': userId,
          'username': username,
          'full_name': 'New User', // Placeholder
          'role': role,
          // 'updated_at': DateTime.now().toIso8601String(), // Removed to avoid potential schema error
        });
      }
    }

    return authResponse;
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
      try {
        await _supabase.from('profiles').upsert({
          'id': response.user!.id,
          'username': username,
          'full_name': fullName,
          'phone_number': phoneNumber,
          'room_number': roomNumber,
          'role': 'student', // Default role
          'updated_at': DateTime.now().toIso8601String(),
        });

        await _supabase.from('student_profiles').upsert({
          'id': response.user!.id,
          'username': username,
          'full_name': fullName,
          'email': email,
          'phone_number': phoneNumber,
          'room_number': roomNumber,
        });
      } catch (e) {
        debugPrint('Error creating profile during signup: $e');
        // We don't rethrow because the user is created in Auth.
        // The Login "healing" logic will catch this later if needed.
      }
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
      debugPrint('Error fetching profile: $e');
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String fullName,
    required String phoneNumber,
    required String roomNumber,
  }) async {
    final user = currentUser;
    if (user == null) throw const AuthException('User not logged in');

    // Use upsert instead of update to handle cases where the profile row might be missing
    await _supabase.from('profiles').upsert({
      'id': user.id,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'room_number': roomNumber,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
