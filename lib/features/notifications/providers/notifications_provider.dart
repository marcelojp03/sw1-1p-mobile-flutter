import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sw1_p1/features/notifications/entities/notification_models.dart';
import 'package:sw1_p1/features/notifications/repository/notifications_repository.dart';
import 'package:sw1_p1/features/procedures/entities/procedure_models.dart';

// ===== Repository =====
final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (_) => NotificationsRepository(),
);

// ===== Lista de notificaciones =====
final notificationsProvider =
    FutureProvider<PageResponse<NotificationResponse>>((ref) async {
      return ref.read(notificationsRepositoryProvider).getNotifications();
    });

// ===== Contador de no leídas (para badge en AppShell) =====
final unreadCountProvider = FutureProvider<int>((ref) async {
  final page = await ref
      .read(notificationsRepositoryProvider)
      .getNotifications(unreadOnly: true);
  return page.totalElements;
});

// ===== Estado para marcar como leída =====
class MarkReadState {
  final bool isLoading;
  final String? error;

  const MarkReadState({this.isLoading = false, this.error});

  MarkReadState copyWith({bool? isLoading, String? error}) =>
      MarkReadState(isLoading: isLoading ?? this.isLoading, error: error);
}

class MarkReadNotifier extends StateNotifier<MarkReadState> {
  final NotificationsRepository _repo;
  final Ref _ref;

  MarkReadNotifier(this._repo, this._ref) : super(const MarkReadState());

  Future<void> markRead(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.markAsRead(id);
      state = state.copyWith(isLoading: false);
      _ref.invalidate(notificationsProvider);
      _ref.invalidate(unreadCountProvider);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}

final markReadProvider =
    StateNotifierProvider.autoDispose<MarkReadNotifier, MarkReadState>(
      (ref) => MarkReadNotifier(ref.read(notificationsRepositoryProvider), ref),
    );
