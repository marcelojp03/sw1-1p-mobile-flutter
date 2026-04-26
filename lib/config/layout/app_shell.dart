import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sw1_p1/config/theme/app_theme.dart';
import 'package:sw1_p1/features/notifications/providers/notifications_provider.dart';
import 'package:sw1_p1/shared/utils/responsive.dart';

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = context.responsive;
    final location = GoRouterState.of(context).matchedLocation;
    final unreadAsync = ref.watch(unreadCountProvider);

    int currentIndex = 0;
    if (location.startsWith('/tramites')) {
      currentIndex = 1;
    } else if (location.startsWith('/notificaciones')) {
      currentIndex = 2;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/home');
            case 1:
              context.go('/tramites');
            case 2:
              context.go('/notificaciones');
          }
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          const NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment_rounded),
            label: 'Trámites',
          ),
          NavigationDestination(
            icon: _BadgedIcon(
              icon: const Icon(Icons.notifications_outlined),
              count: unreadAsync.value ?? 0,
              res: res,
            ),
            selectedIcon: _BadgedIcon(
              icon: const Icon(Icons.notifications_rounded),
              count: unreadAsync.value ?? 0,
              res: res,
            ),
            label: 'Notificaciones',
          ),
        ],
      ),
    );
  }
}

class _BadgedIcon extends StatelessWidget {
  final Widget icon;
  final int count;
  final Responsive res;

  const _BadgedIcon({
    required this.icon,
    required this.count,
    required this.res,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) return icon;
    return Badge(
      label: Text(
        count > 99 ? '99+' : '$count',
        style: TextStyle(fontSize: res.fontSize(9)),
      ),
      backgroundColor: AppTheme.errorColor,
      child: icon,
    );
  }
}
