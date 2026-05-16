import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> signUpMember({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    final existingProfile = await _client
        .from('members')
        .select()
        .eq('email', normalizedEmail)
        .maybeSingle();

    if (existingProfile == null) {
      throw Exception(
        'No member profile found for this email. Please contact admin first.',
      );
    }

    final existingAuthUserId = existingProfile['auth_user_id'];
    if (existingAuthUserId != null &&
        existingAuthUserId.toString().trim().isNotEmpty) {
      throw Exception('This member account is already linked. Please login.');
    }

    final authResponse = await _client.auth.signUp(
      email: normalizedEmail,
      password: password,
    );

    final user = authResponse.user;
    if (user == null) {
      throw Exception('Signup failed. User account was not created.');
    }

    try {
      final updatedRows = await _client
          .from('members')
          .update({
            'auth_user_id': user.id,
            'email': normalizedEmail,
          })
          .eq('email', normalizedEmail)
          .select();

      if (updatedRows.isEmpty) {
        throw Exception(
          'Account created, but member profile could not be linked.',
        );
      }
    } catch (e) {
      throw Exception(
        'Account created, but linking member profile failed: $e',
      );
    }
  }

  Future<Map<String, dynamic>?> getCurrentProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final data = await _client
        .from('members')
        .select()
        .eq('auth_user_id', user.id)
        .maybeSingle();

    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }
}