import 'package:supabase_flutter/supabase_flutter.dart';

/// Single access point for the Supabase client.
/// Initialization happens once in main.dart via [SupabaseConfig.initialize()].
class SupabaseConfig {
  SupabaseConfig._();

  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }

  static SupabaseClient get client  => Supabase.instance.client;
  static User?          get currentUser  => client.auth.currentUser;
  static bool           get isAuthenticated => currentUser != null;
}
