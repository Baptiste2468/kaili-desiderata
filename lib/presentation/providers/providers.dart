import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote_datasource.dart';
import '../../data/datasources/mock_datasource.dart';
import '../../data/datasources/supabase_datasource.dart';
import '../../data/repositories/repositories_impl.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import '../../core/supabase/supabase_init.dart';

// ── Datasources ────────────────────────────────────────────────────────────────
final authDataSourceProvider = Provider<AuthRemoteDataSource>((_) {
  if (SupabaseInit.enabled) return SupabaseAuthDataSource();
  return AuthMockDataSource();
});

// on utilise le mock qui lit `assets/data/medopti_export.json`
final planningDataSourceProvider = Provider<PlanningRemoteDataSource>((_) => PlanningMockDataSource());

final desiderataDataSourceProvider = Provider<DesiderataRemoteDataSource>((_) => DesiderataMockDataSource());
final kailiExportDataSourceProvider = Provider<KailiExportRemoteDataSource>((_) {
  if (SupabaseInit.enabled) return SupabaseKailiExportDataSource();
  return KailiExportMockDataSource();
});
// ── Repositories ───────────────────────────────────────────────────────────────
final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepositoryImpl(ref.read(authDataSourceProvider)));
final planningRepositoryProvider = Provider<PlanningRepository>((ref) => PlanningRepositoryImpl(ref.read(planningDataSourceProvider)));
final desiderataRepositoryProvider = Provider<DesiderataRepository>((ref) => DesiderataRepositoryImpl(ref.read(desiderataDataSourceProvider)));
final kailiExportRepositoryProvider = Provider<KailiExportRepository>(
  (ref) => KailiExportRepositoryImpl(ref.read(kailiExportDataSourceProvider)),
);

// ── Auth ───────────────────────────────────────────────────────────────────────
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  const AuthState({this.user, this.isLoading = false, this.error});
  bool get isAuthenticated => user != null;
  AuthState copyWith({User? user, bool? isLoading, String? error, bool clearError = false, bool clearUser = false}) => AuthState(
    user: clearUser ? null : (user ?? this.user),
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
  );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  AuthNotifier(this._repo) : super(const AuthState());

  Future<bool> login({required String identifier, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repo.login(identifier: identifier, password: password);
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(ref.read(authRepositoryProvider)));

// ── Planning ───────────────────────────────────────────────────────────────────
final shiftsProvider = FutureProvider<List<Shift>>((ref) => ref.read(planningRepositoryProvider).getShifts());

// ── Desiderata ─────────────────────────────────────────────────────────────────
class DesiderataNotifier extends StateNotifier<AsyncValue<List<Desiderata>>> {
  final DesiderataRepository _repo;
  DesiderataNotifier(this._repo) : super(const AsyncLoading()) { _load(); }

  Future<void> _load() async {
    try { 
      final data = await _repo.getDesiderata();
      state = AsyncData(data); 
    } catch (e, s) { 
      state = AsyncError(e, s); 
    }
  }

  // CETTE MÉTHODE PERMET L'AFFICHAGE IMMÉDIAT ET LE STOCKAGE
  Future<bool> submit(Desiderata d) async {
    try {
      // 1. On l'envoie au repo (pour simulation/stockage distant)
      await _repo.submitDesiderata(d);
      
      // 2. On met à jour l'état localement pour que ça apparaisse tout de suite
      state.whenData((currentList) {
        state = AsyncData([...currentList, d]);
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> cancel(String id) async {
    await _repo.cancelDesiderata(id);
    await _load();
  }
}

final desiderataProvider = StateNotifierProvider<DesiderataNotifier, AsyncValue<List<Desiderata>>>(
  (ref) => DesiderataNotifier(ref.read(desiderataRepositoryProvider)),
);

// ── Leave Balance ──────────────────────────────────────────────────────────────
final leaveBalanceProvider = FutureProvider<LeaveBalance>((ref) async {
  final json = await ref.read(desiderataDataSourceProvider).getLeaveBalance();
  return LeaveBalance(
    congesTotal: json['congesTotal'] as int? ?? 25,
    congesUsed:  json['congesUsed']  as int? ?? 0,
    rttTotal:    json['rttTotal']    as int? ?? 12,
    rttUsed:     json['rttUsed']     as int? ?? 0,
    recupTotal:  json['recupTotal']  as int? ?? 0,
    recupUsed:   json['recupUsed']   as int? ?? 0,
  );
});
