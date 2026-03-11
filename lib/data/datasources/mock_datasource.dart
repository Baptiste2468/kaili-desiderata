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
  static String? currentPlanningKey;

  // "Base de données" en mémoire pour l'exemple.
  //
  // Dans la vraie vie, cette partie serait remplacée par un backend
  // qui stocke les mots de passe hachés dans une base de données.
  final Map<String, Map<String, dynamic>> _users = {
    // Compte de démonstration : Sacha Layani
    // Identifiants acceptés :
    // - identifiant : "sacha"
    // - email      : "sacha.layani@kaili.fr"
    'sacha': {
      'password': 'KailiDemo2024!',
      'user': {
        'id': 'sacha',
        'firstName': 'Sacha',
        'lastName': 'Layani',
        'email': 'sacha.layani@kaili.fr',
        'role': 'Soignant',
        'service': 'Urgences',
      },
    },
    'sacha.layani@kaili.fr': {
      'password': 'KailiDemo2024!',
      'user': {
        'id': 'sacha',
        'firstName': 'Sacha',
        'lastName': 'Layani',
        'email': 'sacha.layani@kaili.fr',
        'role': 'Soignant',
        'service': 'Urgences',
      },
    },

    // Compte de démonstration : Jean Dupont – Stépagne
    // Identifiants acceptés :
    // - identifiant : "jean.dupont"
    // - email      : "jean.dupont@stepagne.fr"
    'jean.dupont': {
      'password': 'KailiDemo2024!',
      'user': {
        'id': 'jean.dupont',
        'firstName': 'Jean',
        'lastName': 'Dupont',
        'email': 'jean.dupont@stepagne.fr',
        'role': 'Soignant',
        'service': 'Stépagne',
      },
    },
    'jean.dupont@stepagne.fr': {
      'password': 'KailiDemo2024!',
      'user': {
        'id': 'jean.dupont',
        'firstName': 'Jean',
        'lastName': 'Dupont',
        'email': 'jean.dupont@stepagne.fr',
        'role': 'Soignant',
        'service': 'Stépagne',
      },
    },
    // Compte de démonstration : Stéphane – Stépagne
    // Identifiants acceptés :
    // - identifiant : "stephane"
    // - email      : "stephane@stepagne.fr"
    'stephane': {
      'password': 'KailiDemo2024!',
      'user': {
        'id': 'stephane',
        'firstName': 'Stéphane',
        'lastName': '',
        'email': 'stephane@stepagne.fr',
        'role': 'Soignant',
        'service': 'Stépagne',
      },
    },
    'stephane@stepagne.fr': {
      'password': 'KailiDemo2024!',
      'user': {
        'id': 'stephane',
        'firstName': 'Stéphane',
        'lastName': '',
        'email': 'stephane@stepagne.fr',
        'role': 'Soignant',
        'service': 'Stépagne',
      },
    },
  };

  @override
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final trimmedId = identifier.trim();
    final record = _users[trimmedId];

    if (record == null || record['password'] != password) {
      throw Exception('Identifiant ou mot de passe incorrect.');
    }

    final user = record['user'] as Map<String, dynamic>;
    final firstName = (user['firstName'] as String?)?.trim() ?? '';
    final lastName = (user['lastName'] as String?)?.trim() ?? '';
    final candidateKey =
        [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
    currentPlanningKey = candidateKey.isNotEmpty ? candidateKey : trimmedId;

    return {
      'user': user,
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
    final agentKey = AuthMockDataSource.currentPlanningKey ?? 'Jean Dupont';
    final agentData = await _loadAgentData(agentKey);
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
