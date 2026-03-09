import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import '../datasources/remote_datasource.dart';
import '../models/models.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<User> login({
    required String identifier,
    required String password,
  }) async {
    final data = await _dataSource.login(
      identifier: identifier,
      password: password,
    );
    return UserModel.fromJson(data['user'] as Map<String, dynamic>).toEntity();
  }

  @override
  Future<void> logout() async {
    // Clear token from secure storage
  }

  @override
  Future<User?> getCurrentUser() async {
    // Read from secure storage / cache
    return null;
  }

  @override
  Future<bool> isAuthenticated() async {
    return false;
  }
}

class PlanningRepositoryImpl implements PlanningRepository {
  final PlanningRemoteDataSource _dataSource;

  PlanningRepositoryImpl(this._dataSource);

  @override
  Future<List<Shift>> getShifts({DateTime? from, DateTime? to}) async {
    final data = await _dataSource.getShifts(from: from, to: to);
    return data
        .map((json) => ShiftModel.fromJson(json).toEntity())
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Future<Shift> getShiftById(String id) async {
    final data = await _dataSource.getShifts();
    final json = data.firstWhere((d) => d['id'] == id);
    return ShiftModel.fromJson(json).toEntity();
  }
}

class DesiderataRepositoryImpl implements DesiderataRepository {
  final DesiderataRemoteDataSource _dataSource;

  DesiderataRepositoryImpl(this._dataSource);

  @override
  Future<List<Desiderata>> getDesiderata() async {
    final data = await _dataSource.getDesiderata();
    return data.map((json) => DesiderataModel.fromJson(json).toEntity()).toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
  }

  @override
  Future<Desiderata> submitDesiderata(Desiderata desiderata) async {
    final json = await _dataSource.submitDesiderata({
      'type': desiderata.type.label,
      'startDate': _formatDate(desiderata.startDate),
      'endDate':
          desiderata.endDate != null ? _formatDate(desiderata.endDate!) : null,
      'comment': desiderata.comment,
    });
    return DesiderataModel.fromJson(json).toEntity();
  }

  @override
  Future<void> cancelDesiderata(String id) async {
    await _dataSource.cancelDesiderata(id);
  }

  @override
  Future<LeaveBalance> getLeaveBalance() async {
    final json = await _dataSource.getLeaveBalance();
    return LeaveBalanceModel.fromJson(json).toEntity();
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class KailiExportRepositoryImpl implements KailiExportRepository {
  final KailiExportRemoteDataSource _dataSource;

  KailiExportRepositoryImpl(this._dataSource);

  @override
  Future<void> exportDesiderataForPlanning({
    required User user,
    required List<Desiderata> desiderata,
  }) async {
    final payload = <String, dynamic>{
      'agent': {
        'id': user.id,
        'firstName': user.firstName,
        'lastName': user.lastName,
        'email': user.email,
        'role': user.role,
        'service': user.service,
      },
      'desiderata': desiderata
          .map(
            (d) => <String, dynamic>{
              'id': d.id,
              'type': d.type.label,
              'startDate': _formatDate(d.startDate),
              'endDate': d.endDate != null ? _formatDate(d.endDate!) : null,
              'comment': d.comment,
              'status': d.status.label,
              'submittedAt': d.submittedAt.toIso8601String(),
            },
          )
          .toList(),
    };

    await _dataSource.exportDesiderataForPlanning(payload);
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
