import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sw1_p1/features/auth/repository/auth_repository.dart';

enum SplashStatus { loading, navigateToLogin, navigateToHome }

class SplashState {
  final SplashStatus status;
  const SplashState({this.status = SplashStatus.loading});
}

class SplashNotifier extends StateNotifier<SplashState> {
  final AuthRepository _repository;

  SplashNotifier(this._repository) : super(const SplashState()) {
    checkAuthentication();
  }

  Future<void> checkAuthentication() async {
    await Future.delayed(const Duration(milliseconds: 1600));
    try {
      final isLoggedIn = await _repository.isLoggedIn();
      state = SplashState(
        status:
            isLoggedIn
                ? SplashStatus.navigateToHome
                : SplashStatus.navigateToLogin,
      );
    } catch (_) {
      state = const SplashState(status: SplashStatus.navigateToLogin);
    }
  }
}

final splashProvider = StateNotifierProvider<SplashNotifier, SplashState>(
  (ref) => SplashNotifier(AuthRepository()),
);
