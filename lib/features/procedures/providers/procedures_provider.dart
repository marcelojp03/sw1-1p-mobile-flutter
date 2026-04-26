import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sw1_p1/features/auth/providers/auth_provider.dart';
import 'package:sw1_p1/features/procedures/entities/procedure_models.dart';
import 'package:sw1_p1/features/procedures/repository/procedures_repository.dart';

// ===== Repository provider =====
final proceduresRepositoryProvider = Provider<ProceduresRepository>(
  (_) => ProceduresRepository(),
);

// ===== Lista de mis trámites =====
final proceduresSummaryProvider =
    FutureProvider<PageResponse<ProcedureSummary>>((ref) async {
      final repo = ref.read(proceduresRepositoryProvider);
      return repo.getMyProcedures();
    });

// ===== Detalle =====
final procedureDetailProvider = FutureProvider.family<ProcedureDetail, String>((
  ref,
  id,
) async {
  final repo = ref.read(proceduresRepositoryProvider);
  return repo.getProcedureById(id);
});

// ===== Historial =====
final procedureHistoryProvider =
    FutureProvider.family<List<ProcedureHistoryEntry>, String>((ref, id) async {
      final repo = ref.read(proceduresRepositoryProvider);
      return repo.getProcedureHistory(id);
    });

// ===== Políticas disponibles =====
final availablePoliciesProvider = FutureProvider<List<WorkflowPolicy>>((
  ref,
) async {
  final user = ref.watch(authProvider).user;
  final orgId = user?.organizationId ?? '';
  if (orgId.isEmpty) return [];
  final repo = ref.read(proceduresRepositoryProvider);
  return repo.getAvailablePolicies(orgId);
});

// ===== Estado para inicio de trámite =====
class StartProcedureState {
  final bool isLoading;
  final String? error;
  final ProcedureDetail? result;

  const StartProcedureState({this.isLoading = false, this.error, this.result});

  StartProcedureState copyWith({
    bool? isLoading,
    String? error,
    ProcedureDetail? result,
  }) => StartProcedureState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    result: result ?? this.result,
  );
}

class StartProcedureNotifier extends StateNotifier<StartProcedureState> {
  final ProceduresRepository _repo;

  StartProcedureNotifier(this._repo) : super(const StartProcedureState());

  Future<void> start(StartProcedureRequest req) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repo.startProcedure(req);
      state = state.copyWith(isLoading: false, result: result);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void reset() => state = const StartProcedureState();
}

final startProcedureProvider =
    StateNotifierProvider<StartProcedureNotifier, StartProcedureState>(
      (ref) => StartProcedureNotifier(ref.read(proceduresRepositoryProvider)),
    );
