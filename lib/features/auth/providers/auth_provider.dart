import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sw1_p1/features/auth/entities/auth_models.dart';
import 'package:sw1_p1/features/auth/repository/auth_repository.dart';

// ===== Estado =====
enum AuthStatus { checking, authenticated, notAuthenticated }

class AuthState {
  final AuthStatus status;
  final CurrentUser? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.checking,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    CurrentUser? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

// ===== Notifier =====
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState()) {
    _checkSavedAuth();
  }

  Future<void> _checkSavedAuth() async {
    try {
      final user = await _repository.getSavedUser();
      if (user != null) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } else {
        state = const AuthState(status: AuthStatus.notAuthenticated);
      }
    } catch (_) {
      state = const AuthState(status: AuthStatus.notAuthenticated);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AuthState(status: AuthStatus.checking);
    try {
      final user = await _repository.login(email, password);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.notAuthenticated,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(status: AuthStatus.notAuthenticated);
  }

  void clearError() {
    state = state.copyWith(status: state.status, errorMessage: null);
  }
}

// ===== Provider =====
final authRepositoryProvider = Provider<AuthRepository>(
  (_) => AuthRepository(),
);

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.read(authRepositoryProvider)),
);
