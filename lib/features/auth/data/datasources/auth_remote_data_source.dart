import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/supabase_config.dart';
import '../../../../core/errors/app_exception.dart';

/// All direct Supabase Auth calls live here.
/// Throws typed [AppException]s — never raw Supabase exceptions.
class AuthRemoteDataSource {
  final SupabaseClient _client;

  AuthRemoteDataSource({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  // ── Sign up ──────────────────────────────────────────────────────────────

  /// Creates a new auth user and seeds the profile row via DB trigger.
  /// [role] is embedded in user_metadata so the trigger picks it up.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String role = 'passenger',
  }) async {
    try {
      return await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'role': role},
      );
    } catch (e) {
      throw mapException(e);
    }
  }

  // ── Sign in ──────────────────────────────────────────────────────────────

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw mapException(e);
    }
  }

  // ── Sign out ─────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw mapException(e);
    }
  }

  // ── Password reset ───────────────────────────────────────────────────────

  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw mapException(e);
    }
  }

  // ── Session helpers ──────────────────────────────────────────────────────

  User? get currentUser => _client.auth.currentUser;

  Session? get currentSession => _client.auth.currentSession;

  /// Stream of auth state changes — used by the router guard.
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ── Profile role lookup ───────────────────────────────────────────────────

  /// Returns the 'role' field from the profiles table for the current user.
  /// Throws [NotAuthenticatedException] if no user is signed in.
  /// Throws [ForbiddenException] if the role does not match [expectedRole].
  Future<String> fetchUserRole() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw const NotAuthenticatedException();

    try {
      final response = await _client
          .from('profiles')
          .select('role')
          .eq('id', uid)
          .single();
      return response['role'] as String;
    } catch (e) {
      throw mapException(e);
    }
  }
}
