import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Typed access to environment variables loaded from .env
/// Call [Env.load()] once at app startup before accessing any values.
class Env {
  Env._();

  static Future<void> load() => dotenv.load(fileName: '.env');

  static String get supabaseUrl {
    final v = dotenv.env['SUPABASE_URL'] ?? '';
    assert(v.isNotEmpty, 'SUPABASE_URL is missing from .env');
    return v;
  }

  static String get supabaseAnonKey {
    final v = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    assert(v.isNotEmpty, 'SUPABASE_ANON_KEY is missing from .env');
    return v;
  }
  // NOTE: GOOGLE_MAPS_API_KEY has been removed.
  // This app uses flutter_map + OpenStreetMap tiles which require no API key.
}
