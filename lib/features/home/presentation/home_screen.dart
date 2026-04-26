import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sw1_p1/config/theme/app_theme.dart';
import 'package:sw1_p1/features/auth/providers/auth_provider.dart';
import 'package:sw1_p1/features/procedures/providers/procedures_provider.dart';
import 'package:sw1_p1/shared/utils/responsive.dart';
import 'package:sw1_p1/shared/widgets/loading_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = context.responsive;
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final proceduresAsync = ref.watch(proceduresSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(proceduresSummaryProvider),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(res.spacing(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Saludo
              _buildGreetingCard(context, res, user?.fullName ?? 'Cliente'),
              SizedBox(height: res.spacing(20)),

              // Quick actions
              _buildQuickActions(context, res),
              SizedBox(height: res.spacing(20)),

              // Trámites recientes
              Text(
                'Trámites recientes',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: res.spacing(12)),
              proceduresAsync.when(
                loading:
                    () => const LoadingWidget(
                      useShimmer: true,
                      shimmerItemCount: 3,
                    ),
                error:
                    (_, __) => const Text('No se pudieron cargar los trámites'),
                data: (page) {
                  final items = page.content.take(4).toList();
                  if (items.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: res.spacing(24),
                        ),
                        child: const Text('No tienes trámites aún'),
                      ),
                    );
                  }
                  return Column(
                    children:
                        items
                            .map(
                              (p) => _ProcedureSummaryTile(
                                procedure: p,
                                onTap: () => context.push('/tramites/${p.id}'),
                              ),
                            )
                            .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingCard(BuildContext context, Responsive res, String name) {
    return Container(
          padding: EdgeInsets.all(res.spacing(18)),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenido,',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: res.fontSize(13),
                      ),
                    ),
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: res.fontSize(20),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(res.spacing(10)),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: res.iconSize(26),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.fastOutSlowIn);
  }

  Widget _buildQuickActions(BuildContext context, Responsive res) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.add_circle_outline_rounded,
            label: 'Nuevo trámite',
            color: AppTheme.primaryColor,
            onTap: () => context.push('/tramites/nuevo'),
          ),
        ),
        SizedBox(width: res.spacing(12)),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.assignment_outlined,
            label: 'Mis tareas',
            color: AppTheme.warningColor,
            onTap: () => context.go('/tramites'),
          ),
        ),
        SizedBox(width: res.spacing(12)),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.notifications_outlined,
            label: 'Notificaciones',
            color: AppTheme.secondaryColor,
            onTap: () => context.go('/notificaciones'),
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final res = context.responsive;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: res.spacing(14),
          horizontal: res.spacing(8),
        ),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.black.withOpacity(0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.15 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(res.spacing(8)),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: res.iconSize(20)),
            ),
            SizedBox(height: res.spacing(6)),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: res.fontSize(11),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProcedureSummaryTile extends StatelessWidget {
  final dynamic procedure;
  final VoidCallback onTap;

  const _ProcedureSummaryTile({required this.procedure, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final res = context.responsive;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _statusColor(procedure.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: res.spacing(10)),
        padding: EdgeInsets.all(res.spacing(14)),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: res.dp(0.5),
              height: res.spacing(40),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(width: res.spacing(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    procedure.policyName ?? 'Trámite',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: res.fontSize(13),
                    ),
                  ),
                  Text(
                    procedure.currentStepName ?? '',
                    style: TextStyle(
                      fontSize: res.fontSize(11),
                      color: AppTheme.grey1,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: res.spacing(8),
                vertical: res.spacing(4),
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _statusLabel(procedure.status),
                style: TextStyle(
                  color: color,
                  fontSize: res.fontSize(10),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String? status) {
    return switch (status) {
      'CREATED' => const Color(0xFF64748B),
      'IN_PROGRESS' => AppTheme.primaryColor,
      'WAITING_CLIENT' => AppTheme.warningColor,
      'OBSERVED' => const Color(0xFFF97316),
      'APPROVED' => AppTheme.successColor,
      'COMPLETED' => const Color(0xFF16A34A),
      'REJECTED' => AppTheme.errorColor,
      'CANCELLED' => const Color(0xFF94A3B8),
      _ => AppTheme.grey1,
    };
  }

  String _statusLabel(String? status) {
    return switch (status) {
      'CREATED' => 'Creado',
      'IN_PROGRESS' => 'En proceso',
      'WAITING_CLIENT' => 'Esperando',
      'OBSERVED' => 'Observado',
      'APPROVED' => 'Aprobado',
      'COMPLETED' => 'Completado',
      'REJECTED' => 'Rechazado',
      'CANCELLED' => 'Cancelado',
      _ => status ?? '',
    };
  }
}
