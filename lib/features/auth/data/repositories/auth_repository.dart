import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/supabase_config.dart';
import '../../../../core/errors/app_exception.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/profile_model.dart';

/// Single auth repository used by all three portals (passenger / driver / admin).
///
/// Every method returns a typed result or throws an [AppException].
/// The repository also handles the role-gate so screens don't need to
/// re-implement the check.
class AuthRepository {
  AuthRepository({AuthRemoteDataSource? dataSource})
      : _ds = dataSource ?? AuthRemoteDataSource();

  final AuthRemoteDataSource _ds;

  // ── Passenger sign-up / sign-in ──────────────────────────────────────────

  Future<ProfileModel> signUpPassenger({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _ds.signUp(
      email: email,
      password: password,
      fullName: fullName,
      role: 'passenger',
    );
    final user = response.user;
    if (user == null) throw const ServerException('Sign-up returned no user.');
    return _fetchProfile(user.id);
  }

  Future<ProfileModel> signInPassenger({
    required String email,
    required String password,
  }) async {
    final response = await _ds.signIn(email: email, password: password);
    final user = response.user;
    if (user == null) throw const InvalidCredentialsException();

    final profile = await _fetchProfile(user.id);
    if (profile.role != 'passenger') {
      await _ds.signOut();
      throw const UnauthorizedRoleException('passenger');
    }
    return profile;
  }

  // ── Driver sign-up / sign-in ─────────────────────────────────────────────

  /// Registers a new driver account and inserts the application record.
  /// The profile starts with status = 'pending' and role = 'driver'.
  Future<ProfileModel> signUpDriver({
    required String email,
    required String password,
    required String fullName,
    required String licenseNumber,
    String? vehicleModel,
    String? platNumber,
  }) async {
    final response = await _ds.signUp(
      email: email,
      password: password,
      fullName: fullName,
      role: 'driver',
    );
    final user = response.user;
    if (user == null) throw const ServerException('Sign-up returned no user.');

    // Immediately update driver status to 'pending' (default is 'active')
    await SupabaseConfig.client
        .from('profiles')
        .update({'status': 'pending'})
        .eq('id', user.id);

    // Insert driver application record
    await SupabaseConfig.client.from('driver_applications').insert({
      'user_id':        user.id,
      'license_number': licenseNumber,
      'vehicle_model':  vehicleModel,
      'plate_number':   platNumber,
    });

    return _fetchProfile(user.id);
  }

  Future<ProfileModel> signInDriver({
    required String email,
    required String password,
  }) async {
    final response = await _ds.signIn(email: email, password: password);
    final user = response.user;
    if (user == null) throw const InvalidCredentialsException();

    final profile = await _fetchProfile(user.id);
    if (profile.role != 'driver') {
      await _ds.signOut();
      throw const UnauthorizedRoleException('driver');
    }
    if (profile.status == 'pending') {
      await _ds.signOut();
      throw const ForbiddenException(
        'Your driver account is pending admin approval.',
      );
    }
    if (profile.status == 'suspended') {
      await _ds.signOut();
      throw const ForbiddenException(
        'Your driver account has been suspended. Contact support.',
      );
    }
    return profile;
  }

  // ── Admin sign-in (no self-registration) ─────────────────────────────────

  Future<ProfileModel> signInAdmin({
    required String email,
    required String password,
  }) async {
    final response = await _ds.signIn(email: email, password: password);
    final user = response.user;
    if (user == null) throw const InvalidCredentialsException();

    final profile = await _fetchProfile(user.id);
    if (profile.role != 'admin') {
      await _ds.signOut();
      throw const UnauthorizedRoleException('admin');
    }
    return profile;
  }

  // ── Shared ───────────────────────────────────────────────────────────────

  Future<void> signOut() => _ds.signOut();

  Future<void> resetPassword(String email) => _ds.resetPassword(email);

  User? get currentUser => _ds.currentUser;
  Session? get currentSession => _ds.currentSession;
  Stream<AuthState> get authStateChanges => _ds.authStateChanges;

  /// Fetch the current user's profile if a session already exists.
  /// Returns null when no user is signed in.
  Future<ProfileModel?> fetchCurrentProfile() async {
    final user = _ds.currentUser;
    if (user == null) return null;
    return _fetchProfile(user.id);
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  Future<ProfileModel> _fetchProfile(String uid) async {
    try {
      final row = await SupabaseConfig.client
          .from('profiles')
          .select()
          .eq('id', uid)
          .single();
      return ProfileModel.fromMap(row);
    } catch (e) {
      throw mapException(e);
    }
  }
}
