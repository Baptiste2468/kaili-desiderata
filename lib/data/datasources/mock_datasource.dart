import 'dart:convert';
import 'package:flutter/services.dart';

import 'remote_datasource.dart';

// -------------------------------------------------------------
// Mock implementations of the remote data source interfaces used
// throughout the repositories.  These classes live alongside the
// abstract definitions in `remote_datasource.dart` to keep the
// project compiling while we work with a local JSON file as a stub.
// -------------------------------------------------------------

class AuthMockDataSource implements AuthRemoteDataSource {
  @override
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    // Return a dummy user object regardless of credentials.
    return {
      'user': {
        'id': identifier,
        'firstName': 'Jean',
        'lastName': 'Dupont',
        'email': '$identifier@example.com',
        'role': 'Soignant',
        'service': 'Urgences',
      }
    };
  }
}

class PlanningMockDataSource implements PlanningRemoteDataSource {
  Future<Map<String, dynamic>> _loadAgentData(String nomAgent) async {
    final String jsonString =
        await rootBundle.loadString('assets/data/medopti_export.json');
    final Map<String, dynamic> dataComplete = json.decode(jsonString);
    if (dataComplete.containsKey(nomAgent)) {
      return dataComplete[nomAgent] as Map<String, dynamic>;
    }
    throw Exception('Agent introuvable');
  }

  @override
  Future<List<Map<String, dynamic>>> getShifts({
    DateTime? from,
    DateTime? to,
  }) async {
    // Pour l'instant, on utilise "Jean Dupont" comme agent par défaut
    final agentData = await _loadAgentData('Jean Dupont');
    final planning = (agentData['planning'] as List<dynamic>?)
        ?.cast<Map<String, dynamic>>() ??
        [];

    // Mapper les données du JSON vers le format attendu par ShiftModel
    return planning.map((shift) => {
      'date': shift['date'],
      'type': shift['type'],
      'service': 'Urgences', // Valeur par défaut car non présente dans le JSON
    }).toList();
  }
}

class DesiderataMockDataSource implements DesiderataRemoteDataSource {
  final List<Map<String, dynamic>> _store = [];

  @override
  Future<List<Map<String, dynamic>>> getDesiderata() async {
    return _store;
  }

  @override
  Future<Map<String, dynamic>> submitDesiderata(
      Map<String, dynamic> payload) async {
    final record = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      ...payload,
      'status': 'en_attente',
      'submittedAt': DateTime.now().toIso8601String(),
    };
    _store.add(record);
    return record;
  }

  @override
  Future<void> cancelDesiderata(String id) async {
    _store.removeWhere((e) => e['id'] == id);
  }

  @override
  Future<Map<String, dynamic>> getLeaveBalance() async {
    return {
      'congesTotal': 25,
      'congesUsed': 0,
      'rttTotal': 12,
      'rttUsed': 0,
      'recupTotal': 0,
      'recupUsed': 0,
    };
  }
}

class KailiExportMockDataSource implements KailiExportRemoteDataSource {
  @override
  Future<void> exportDesiderataForPlanning(
    Map<String, dynamic> payload,
  ) async {
    // Simulation d'un appel réseau : dans l'implémentation réelle,
    // on enverra ce payload à l'API Kaili.
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }
}
