import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sw1_p1/features/procedures/entities/procedure_models.dart';
import 'package:sw1_p1/features/tasks/entities/task_models.dart';
import 'package:sw1_p1/features/tasks/repository/tasks_repository.dart';

// ===== Repository =====
final tasksRepositoryProvider = Provider<TasksRepository>(
  (_) => TasksRepository(),
);

// ===== Lista de mis tareas =====
final myTasksProvider = FutureProvider<PageResponse<TaskResponse>>((ref) async {
  return ref.read(tasksRepositoryProvider).getMyTasks();
});

// ===== Detalle de tarea =====
final taskDetailProvider = FutureProvider.family<TaskResponse, String>((
  ref,
  id,
) async {
  return ref.read(tasksRepositoryProvider).getTaskById(id);
});

// ===== Estado completar tarea =====
class CompleteTaskState {
  final bool isLoading;
  final String? error;
  final bool success;
  final TaskResponse? result;

  const CompleteTaskState({
    this.isLoading = false,
    this.error,
    this.success = false,
    this.result,
  });

  CompleteTaskState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
    TaskResponse? result,
  }) => CompleteTaskState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    success: success ?? this.success,
    result: result ?? this.result,
  );
}

class CompleteTaskNotifier extends StateNotifier<CompleteTaskState> {
  final TasksRepository _repo;

  CompleteTaskNotifier(this._repo) : super(const CompleteTaskState());

  Future<void> complete(
    String taskId,
    Map<String, dynamic> formResponse, {
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      final result = await _repo.completeTask(
        taskId,
        formResponse,
        notes: notes,
      );
      state = state.copyWith(isLoading: false, success: true, result: result);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void reset() => state = const CompleteTaskState();
}

final completeTaskProvider =
    StateNotifierProvider.autoDispose<CompleteTaskNotifier, CompleteTaskState>(
      (ref) => CompleteTaskNotifier(ref.read(tasksRepositoryProvider)),
    );

// ===== Estado upload attachments =====
class UploadAttachmentsState {
  final bool isLoading;
  final String? error;
  final bool success;

  const UploadAttachmentsState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  UploadAttachmentsState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
  }) => UploadAttachmentsState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    success: success ?? this.success,
  );
}

class UploadAttachmentsNotifier extends StateNotifier<UploadAttachmentsState> {
  final TasksRepository _repo;

  UploadAttachmentsNotifier(this._repo) : super(const UploadAttachmentsState());

  Future<TaskResponse?> upload(
    String taskId,
    List<dynamic> files, // MultipartFile list
  ) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      final result = await _repo.uploadAttachments(taskId, files.cast());
      state = state.copyWith(isLoading: false, success: true);
      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return null;
    }
  }

  void reset() => state = const UploadAttachmentsState();
}

final uploadAttachmentsProvider = StateNotifierProvider.autoDispose<
  UploadAttachmentsNotifier,
  UploadAttachmentsState
>((ref) => UploadAttachmentsNotifier(ref.read(tasksRepositoryProvider)));
