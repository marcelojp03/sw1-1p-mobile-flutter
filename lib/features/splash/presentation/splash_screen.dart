import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sw1_p1/features/splash/providers/splash_provider.dart';
import 'package:sw1_p1/shared/utils/responsive.dart';
import 'package:sw1_p1/shared/widgets/animated_background.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = context.responsive;

    ref.listen<SplashState>(splashProvider, (_, next) {
      switch (next.status) {
        case SplashStatus.navigateToHome:
          context.go('/home');
        case SplashStatus.navigateToLogin:
          context.go('/login');
        case SplashStatus.loading:
          break;
      }
    });

    return Scaffold(
      body: AnimatedBackground(
        style: BackgroundStyle.aurora,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Banner WorkflowAI
              Image.asset(
                    'assets/images/workflow-ai-banner.png',
                    width: res.wp(65),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, curve: Curves.fastOutSlowIn)
                  .scale(
                    begin: const Offset(0.85, 0.85),
                    end: const Offset(1.0, 1.0),
                    duration: 700.ms,
                    curve: Curves.elasticOut,
                  ),

              SizedBox(height: res.spacing(12)),

              Text(
                'Gestiona tus trámites',
                style: TextStyle(
                  fontSize: res.fontSize(14),
                  color: Colors.white70,
                ),
              ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

              SizedBox(height: res.hp(6)),

              SizedBox(
                width: res.dp(2),
                height: res.dp(2),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ).animate().fadeIn(delay: 800.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
