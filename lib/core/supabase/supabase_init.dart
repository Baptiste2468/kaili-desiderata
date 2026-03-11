import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseInit {
  static bool get enabled =>
      const bool.fromEnvironment('USE_SUPABASE', defaultValue: false);

  static Future<void> initialize() async {
    if (!enabled) return;

    const url = String.fromEnvironment('SUPABASE_URL');
    const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

    if (url.isEmpty || anonKey.isEmpty) {
      throw Exception(
        'Supabase non configuré. Lancez avec --dart-define SUPABASE_URL=... '
        'et --dart-define SUPABASE_ANON_KEY=... (et USE_SUPABASE=true).',
      );
    }

    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}

