import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sw1_p1/config/theme/app_theme.dart';
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
              // Ícono principal
              Container(
                    width: res.dp(7),
                    height: res.dp(7),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(res.dp(1.8)),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.4),
                          blurRadius: 32,
                          spreadRadius: 4,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.account_tree_rounded,
                      color: Colors.white,
                      size: res.dp(3),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, curve: Curves.fastOutSlowIn)
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                    duration: 700.ms,
                    curve: Curves.elasticOut,
                  ),

              SizedBox(height: res.spacing(24)),

              Text(
                    'Workflow System',
                    style: TextStyle(
                      fontSize: res.fontSize(24),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 400.ms)
                  .slideY(begin: 0.2, end: 0, curve: Curves.fastOutSlowIn),

              SizedBox(height: res.spacing(8)),

              Text(
                'Gestiona tus trámites',
                style: TextStyle(
                  fontSize: res.fontSize(14),
                  color: Colors.white60,
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 400.ms),

              SizedBox(height: res.hp(6)),

              SizedBox(
                width: res.dp(2),
                height: res.dp(2),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white.withOpacity(0.8),
                ),
              ).animate().fadeIn(delay: 800.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
