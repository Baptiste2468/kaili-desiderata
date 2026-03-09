// Defines interfaces for remote data sources. In the MVP we will
// provide mock implementations that simulate network calls, but the
// repository layer depends only on these abstract contracts so they can
// be replaced with real HTTP clients later.

import 'dart:async';

abstract class AuthRemoteDataSource {
  /// Attempts to log in a user and returns a JSON-like map containing at
  /// least a `user` key when successful.
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  });
}

abstract class PlanningRemoteDataSource {
  /// Retrieves a list of shifts belonging to the current user.
  ///
  /// The returned value is expected to be a `List<Map<String, dynamic>>`
  /// where each map represents a shift JSON object.
  Future<List<Map<String, dynamic>>> getShifts({
    DateTime? from,
    DateTime? to,
  });
}

abstract class DesiderataRemoteDataSource {
  Future<List<Map<String, dynamic>>> getDesiderata();
  Future<Map<String, dynamic>> submitDesiderata(Map<String, dynamic> payload);
  Future<void> cancelDesiderata(String id);
  Future<Map<String, dynamic>> getLeaveBalance();
}

abstract class KailiExportRemoteDataSource {
  /// Envoie au backend les informations nécessaires à la construction
  /// du planning dans Kaili pour un soignant donné.
  ///
  /// Le payload contient typiquement :
  /// - les informations de l'agent (id, nom, service, rôle…)
  /// - la liste des désidératas structurés (dates, type, commentaire…)
  Future<void> exportDesiderataForPlanning(Map<String, dynamic> payload);
}