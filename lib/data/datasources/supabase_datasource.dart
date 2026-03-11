import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase/supabase_init.dart';
import 'remote_datasource.dart';

class SupabaseAuthDataSource implements AuthRemoteDataSource {
  @override
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    // On accepte email / identifiant mais Supabase Auth nécessite un email.
    // Si tu veux un identifiant non-email, il faut une table "profiles"
    // et faire la résolution identifiant -> email côté backend.
    final email = identifier.trim();

    final res = await SupabaseInit.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = res.user;
    if (user == null) {
      throw Exception('Identifiant ou mot de passe incorrect.');
    }

    // Profil minimal; le reste (service/role) doit venir d'une table "profiles".
    return {
      'user': {
        'id': user.id,
        'firstName': user.userMetadata?['firstName'] as String? ?? '',
        'lastName': user.userMetadata?['lastName'] as String? ?? '',
        'email': user.email ?? email,
        'role': user.userMetadata?['role'] as String? ?? 'Soignant',
        'service': user.userMetadata?['service'] as String? ?? '',
      },
    };
  }
}

class SupabasePlanningDataSource implements PlanningRemoteDataSource {
  @override
  Future<List<Map<String, dynamic>>> getShifts({
    DateTime? from,
    DateTime? to,
  }) async {
    // Placeholder : à brancher sur une table (ex: shifts) ou sur une fonction RPC.
    // Ici on renvoie une liste vide pour ne pas casser le build.
    return [];
  }
}

class SupabaseKailiExportDataSource implements KailiExportRemoteDataSource {
  @override
  Future<void> exportDesiderataForPlanning(Map<String, dynamic> payload) async {
    // Option simple scalable : on insère une "demande d'export" en base,
    // consommée ensuite par un worker / edge function.
    await SupabaseInit.client.from('kaili_exports').insert({
      'payload': payload,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}

