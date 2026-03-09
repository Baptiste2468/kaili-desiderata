import 'dart:convert';
import 'package:flutter/services.dart';

void main() async {
  // Simuler le chargement des données comme dans mock_datasource.dart
  final String jsonString = await rootBundle.loadString('assets/data/medopti_export.json');
  final Map<String, dynamic> dataComplete = json.decode(jsonString);

  print('Données chargées:');
  print('Agents disponibles: ${dataComplete.keys.join(', ')}');

  // Tester avec "Jean Dupont"
  if (dataComplete.containsKey('Jean Dupont')) {
    final agentData = dataComplete['Jean Dupont'] as Map<String, dynamic>;
    final planning = (agentData['planning'] as List<dynamic>?)
        ?.cast<Map<String, dynamic>>() ??
        [];

    print('Planning de Jean Dupont:');
    for (var shift in planning) {
      print('  Date: ${shift['date']}, Type: ${shift['type']}');
    }

    // Mapper comme dans le datasource
    final mappedShifts = planning.map((shift) => {
      'date': shift['date'],
      'type': shift['type'],
      'service': 'Urgences',
    }).toList();

    print('Shifts mappés:');
    for (var shift in mappedShifts) {
      print('  ${shift['date']}: ${shift['type']} (${shift['service']})');
    }
  } else {
    print('Agent "Jean Dupont" non trouvé');
  }
}