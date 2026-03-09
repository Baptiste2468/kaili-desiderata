import '../../domain/entities/entities.dart';

// ─── User Model ────────────────────────────────────────────────────────────────
class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String service;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.service,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        firstName: json['firstName'] as String? ?? json['first_name'] as String,
        lastName: json['lastName'] as String? ?? json['last_name'] as String,
        email: json['email'] as String,
        role: json['role'] as String? ?? 'Soignant',
        service: json['service'] as String? ?? '',
        avatarUrl: json['avatarUrl'] as String? ?? json['avatar_url'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'role': role,
        'service': service,
        'avatarUrl': avatarUrl,
      };

  User toEntity() => User(
        id: id,
        firstName: firstName,
        lastName: lastName,
        email: email,
        role: role,
        service: service,
        avatarUrl: avatarUrl,
      );
}

// ─── Shift Model ───────────────────────────────────────────────────────────────
/// Maps JSON type: [{date: "2026-03-05", type: "Garde 24h", service: "Urgences"}]
class ShiftModel {
  final String? id;
  final String date;
  final String type;
  final String service;
  final String? note;
  final String? startTime;
  final String? endTime;

  const ShiftModel({
    this.id,
    required this.date,
    required this.type,
    required this.service,
    this.note,
    this.startTime,
    this.endTime,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) => ShiftModel(
        id: json['id'] as String?,
        date: json['date'] as String,
        type: json['type'] as String,
        service: json['service'] as String,
        note: json['note'] as String?,
        startTime: json['startTime'] as String? ?? json['start_time'] as String?,
        endTime: json['endTime'] as String? ?? json['end_time'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'type': type,
        'service': service,
        'note': note,
        'startTime': startTime,
        'endTime': endTime,
      };

  Shift toEntity() => Shift(
        id: id ?? '${date}_${type.hashCode}',
        date: DateTime.parse(date),
        type: ShiftType.fromString(type),
        service: service,
        note: note,
        startTime: startTime,
        endTime: endTime,
      );
}

// ─── Desiderata Model ──────────────────────────────────────────────────────────
class DesiderataModel {
  final String id;
  final String type;
  final String startDate;
  final String? endDate;
  final String? comment;
  final String status;
  final String submittedAt;

  const DesiderataModel({
    required this.id,
    required this.type,
    required this.startDate,
    this.endDate,
    this.comment,
    required this.status,
    required this.submittedAt,
  });

  factory DesiderataModel.fromJson(Map<String, dynamic> json) =>
      DesiderataModel(
        id: json['id'] as String,
        type: json['type'] as String,
        startDate: json['startDate'] as String? ?? json['start_date'] as String,
        endDate: json['endDate'] as String? ?? json['end_date'] as String?,
        comment: json['comment'] as String?,
        status: json['status'] as String? ?? 'en_attente',
        submittedAt: json['submittedAt'] as String? ??
            json['submitted_at'] as String? ??
            DateTime.now().toIso8601String(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'startDate': startDate,
        'endDate': endDate,
        'comment': comment,
        'status': status,
        'submittedAt': submittedAt,
      };

  Desiderata toEntity() {
    final typeEnum = switch (type.toLowerCase()) {
      'congé' || 'conge' => DesiderataType.conge,
      'rtt' => DesiderataType.rtt,
      'préférence' || 'preference' => DesiderataType.preference,
      'indisponibilité' || 'indisponibilite' => DesiderataType.indisponibilite,
      _ => DesiderataType.conge,
    };

    final statusEnum = switch (status.toLowerCase()) {
      'accepté' || 'accepte' || 'accepted' => DesiderataStatus.accepte,
      'refusé' || 'refuse' || 'rejected' => DesiderataStatus.refuse,
      'en_etude' || 'en étude' || 'in_review' => DesiderataStatus.enEtude,
      _ => DesiderataStatus.enAttente,
    };

    return Desiderata(
      id: id,
      type: typeEnum,
      startDate: DateTime.parse(startDate),
      endDate: endDate != null ? DateTime.parse(endDate!) : null,
      comment: comment,
      status: statusEnum,
      submittedAt: DateTime.parse(submittedAt),
    );
  }
}

// ─── Leave Balance Model ───────────────────────────────────────────────────────
class LeaveBalanceModel {
  final int congesTotal;
  final int congesUsed;
  final int rttTotal;
  final int rttUsed;
  final int recupTotal;
  final int recupUsed;

  const LeaveBalanceModel({
    required this.congesTotal,
    required this.congesUsed,
    required this.rttTotal,
    required this.rttUsed,
    required this.recupTotal,
    required this.recupUsed,
  });

  factory LeaveBalanceModel.fromJson(Map<String, dynamic> json) =>
      LeaveBalanceModel(
        congesTotal: json['congesTotal'] as int? ?? json['conges_total'] as int? ?? 25,
        congesUsed: json['congesUsed'] as int? ?? json['conges_used'] as int? ?? 0,
        rttTotal: json['rttTotal'] as int? ?? json['rtt_total'] as int? ?? 12,
        rttUsed: json['rttUsed'] as int? ?? json['rtt_used'] as int? ?? 0,
        recupTotal: json['recupTotal'] as int? ?? json['recup_total'] as int? ?? 0,
        recupUsed: json['recupUsed'] as int? ?? json['recup_used'] as int? ?? 0,
      );

  LeaveBalance toEntity() => LeaveBalance(
        congesTotal: congesTotal,
        congesUsed: congesUsed,
        rttTotal: rttTotal,
        rttUsed: rttUsed,
        recupTotal: recupTotal,
        recupUsed: recupUsed,
      );
}
