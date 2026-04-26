import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sw1_p1/config/layout/app_shell.dart';
import 'package:sw1_p1/features/auth/presentation/login_screen.dart';
import 'package:sw1_p1/features/home/presentation/home_screen.dart';
import 'package:sw1_p1/features/notifications/presentation/notifications_screen.dart';
import 'package:sw1_p1/features/procedures/presentation/procedure_detail_screen.dart';
import 'package:sw1_p1/features/procedures/presentation/procedure_new_screen.dart';
import 'package:sw1_p1/features/procedures/presentation/procedures_screen.dart';
import 'package:sw1_p1/features/splash/presentation/splash_screen.dart';
import 'package:sw1_p1/features/tasks/presentation/client_task_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  debugLogDiagnostics: false,
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(
          path: '/tramites',
          builder: (_, __) => const ProceduresScreen(),
          routes: [
            GoRoute(
              path: 'nuevo',
              builder: (_, __) => const ProcedureNewScreen(),
            ),
            GoRoute(
              path: ':id',
              builder:
                  (context, state) => ProcedureDetailScreen(
                    procedureId: state.pathParameters['id']!,
                  ),
            ),
          ],
        ),
        GoRoute(
          path: '/tasks/:id',
          builder:
              (context, state) =>
                  ClientTaskScreen(taskId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/notificaciones',
          builder: (_, __) => const NotificationsScreen(),
        ),
      ],
    ),
  ],
  errorBuilder:
      (context, state) => Scaffold(
        body: Center(child: Text('Página no encontrada: ${state.error}')),
      ),
);
