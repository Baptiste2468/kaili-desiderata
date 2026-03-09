import '../entities/entities.dart';

abstract class AuthRepository {
  Future<User> login({required String identifier, required String password});
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<bool> isAuthenticated();
}

abstract class PlanningRepository {
  Future<List<Shift>> getShifts({DateTime? from, DateTime? to});
  Future<Shift> getShiftById(String id);
}

abstract class DesiderataRepository {
  Future<List<Desiderata>> getDesiderata();
  Future<Desiderata> submitDesiderata(Desiderata desiderata);
  Future<void> cancelDesiderata(String id);
  Future<LeaveBalance> getLeaveBalance();
}

abstract class KailiExportRepository {
  Future<void> exportDesiderataForPlanning({
    required User user,
    required List<Desiderata> desiderata,
  });
}
