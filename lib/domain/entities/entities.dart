import 'package:equatable/equatable.dart';

// ─── User Entity ───────────────────────────────────────────────────────────────
class User extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String service;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.service,
    this.avatarUrl,
  });

  String get fullName => '$firstName $lastName';
  String get initials =>
      '${firstName[0]}${lastName[0]}'.toUpperCase();

  @override
  List<Object?> get props =>
      [id, firstName, lastName, email, role, service, avatarUrl];
}

// ─── Shift Entity ──────────────────────────────────────────────────────────────
enum ShiftType {
  matin,
  soir,
  nuit,
  garde24h,
  gardeNuit,
  gardeJour,
  conge,
  repos,
  formation,
  autre;

  String get label => switch (this) {
        matin => 'Matin',
        soir => 'Soir',
        nuit => 'Nuit',
        garde24h => 'Garde 24h',
        gardeNuit => 'Garde de nuit',
        gardeJour => 'Garde de jour',
        conge => 'Congé',
        repos => 'Repos',
        formation => 'Formation',
        autre => 'Autre',
      };

  static ShiftType fromString(String value) {
    // Le .trim() est la sécurité ultime : il enlève les espaces invisibles !
    return switch (value.trim().toLowerCase()) {
      'matin' => matin,
      'soir' => soir,
      'nuit' => nuit,
      'garde 24h' || 'garde24h' => garde24h,
      'garde de nuit' || 'gardenuit' => gardeNuit,
      'garde de jour' || 'gardejour' => gardeJour,
      'congé' || 'conge' => conge,
      'repos' => repos,
      'formation' => formation,
      _ => autre,
    };
  }
}

class Shift extends Equatable {
  final String id;
  final DateTime date;
  final ShiftType type;
  final String service;
  final String? note;
  final String? startTime;
  final String? endTime;

  const Shift({
    required this.id,
    required this.date,
    required this.type,
    required this.service,
    this.note,
    this.startTime,
    this.endTime,
  });

  @override
  List<Object?> get props =>
      [id, date, type, service, note, startTime, endTime];
}

// ─── Desiderata Entity ─────────────────────────────────────────────────────────
enum DesiderataType {
  conge,
  rtt,
  preference,
  indisponibilite;

  String get label => switch (this) {
        conge => 'Congé',
        rtt => 'RTT',
        preference => 'Préférence',
        indisponibilite => 'Indisponibilité',
      };
}

enum DesiderataStatus {
  enAttente,
  accepte,
  refuse,
  enEtude;

  String get label => switch (this) {
        enAttente => 'En attente',
        accepte => 'Accepté',
        refuse => 'Refusé',
        enEtude => 'En étude',
      };
}

class Desiderata extends Equatable {
  final String id;
  final DesiderataType type;
  final DateTime startDate;
  final DateTime? endDate;
  final String? comment;
  final DesiderataStatus status;
  final DateTime submittedAt;

  const Desiderata({
    required this.id,
    required this.type,
    required this.startDate,
    this.endDate,
    this.comment,
    required this.status,
    required this.submittedAt,
  });

  int get durationDays {
    if (endDate == null) return 1;
    return endDate!.difference(startDate).inDays + 1;
  }

  @override
  List<Object?> get props =>
      [id, type, startDate, endDate, comment, status, submittedAt];
}

// ─── Leave Balance Entity ──────────────────────────────────────────────────────
class LeaveBalance extends Equatable {
  final int congesTotal;
  final int congesUsed;
  final int rttTotal;
  final int rttUsed;
  final int recupTotal;
  final int recupUsed;

  const LeaveBalance({
    required this.congesTotal,
    required this.congesUsed,
    required this.rttTotal,
    required this.rttUsed,
    required this.recupTotal,
    required this.recupUsed,
  });

  int get congesRemaining => congesTotal - congesUsed;
  int get rttRemaining => rttTotal - rttUsed;
  int get recupRemaining => recupTotal - recupUsed;

  @override
  List<Object?> get props => [
        congesTotal,
        congesUsed,
        rttTotal,
        rttUsed,
        recupTotal,
        recupUsed,
      ];
}
