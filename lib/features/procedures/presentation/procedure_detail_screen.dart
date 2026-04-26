import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sw1_p1/config/theme/app_theme.dart';
import 'package:sw1_p1/features/procedures/providers/procedures_provider.dart';
import 'package:sw1_p1/shared/utils/responsive.dart';
import 'package:sw1_p1/shared/widgets/loading_widget.dart';

class ProcedureDetailScreen extends ConsumerWidget {
  final String procedureId;
  const ProcedureDetailScreen({super.key, required this.procedureId});

  Color _statusColor(String status) {
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

  String _statusLabel(String status) {
    return switch (status) {
      'CREATED' => 'Creado',
      'IN_PROGRESS' => 'En proceso',
      'WAITING_CLIENT' => 'Esperando cliente',
      'OBSERVED' => 'Observado',
      'APPROVED' => 'Aprobado',
      'COMPLETED' => 'Completado',
      'REJECTED' => 'Rechazado',
      'CANCELLED' => 'Cancelado',
      _ => status,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = context.responsive;
    final detailAsync = ref.watch(procedureDetailProvider(procedureId));
    final historyAsync = ref.watch(procedureHistoryProvider(procedureId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Trámite'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(procedureDetailProvider(procedureId));
              ref.invalidate(procedureHistoryProvider(procedureId));
            },
          ),
        ],
      ),
      body: detailAsync.when(
        loading:
            () => const LoadingWidget(useShimmer: true, shimmerItemCount: 4),
        error:
            (e, _) => Center(
              child: Text(
                'Error: ${e.toString().replaceFirst('Exception: ', '')}',
              ),
            ),
        data: (detail) {
          final color = _statusColor(detail.status);

          return SingleChildScrollView(
            padding: EdgeInsets.all(res.spacing(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status card
                _StatusCard(
                      detail: detail,
                      color: color,
                      label: _statusLabel(detail.status),
                      res: res,
                    )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.1, end: 0, curve: Curves.fastOutSlowIn),

                SizedBox(height: res.spacing(16)),

                // Tareas activas del trámite
                if (detail.tasks.isNotEmpty) ...[
                  Text(
                    'Tareas pendientes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: res.spacing(10)),
                  ...detail.tasks
                      .where((t) => t['status'] == 'PENDING')
                      .map(
                        (t) => _TaskTile(
                          task: t,
                          res: res,
                          onTap: () => context.push('/tasks/${t['id']}'),
                        ),
                      ),
                  SizedBox(height: res.spacing(16)),
                ],

                // Historial
                Text(
                  'Historial',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: res.spacing(10)),
                historyAsync.when(
                  loading:
                      () => const LoadingWidget(
                        useShimmer: true,
                        shimmerItemCount: 3,
                      ),
                  error:
                      (_, __) => const Text('No se pudo cargar el historial'),
                  data: (history) {
                    if (history.isEmpty) {
                      return Text(
                        'Sin eventos registrados aún',
                        style: TextStyle(
                          fontSize: res.fontSize(13),
                          color: AppTheme.grey1,
                        ),
                      );
                    }
                    return Column(
                      children:
                          history
                              .asMap()
                              .entries
                              .map(
                                (entry) => _HistoryTile(
                                  entry: entry.value,
                                  res: res,
                                  isLast: entry.key == history.length - 1,
                                ),
                              )
                              .toList(),
                    );
                  },
                ),

                SizedBox(height: res.spacing(24)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final dynamic detail;
  final Color color;
  final String label;
  final Responsive res;

  const _StatusCard({
    required this.detail,
    required this.color,
    required this.label,
    required this.res,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(res.spacing(16)),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  detail.policyName ?? 'Trámite',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: res.fontSize(16),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: res.spacing(10),
                  vertical: res.spacing(5),
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: res.fontSize(11),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if ((detail.currentStepName ?? '').isNotEmpty) ...[
            SizedBox(height: res.spacing(8)),
            Row(
              children: [
                Icon(
                  Icons.radio_button_checked_rounded,
                  color: color,
                  size: res.iconSize(14),
                ),
                SizedBox(width: res.spacing(6)),
                Text(
                  'Paso actual: ${detail.currentStepName}',
                  style: TextStyle(
                    fontSize: res.fontSize(12),
                    color: AppTheme.grey1,
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: res.spacing(8)),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: res.iconSize(12),
                color: AppTheme.grey1,
              ),
              SizedBox(width: res.spacing(6)),
              Text(
                'Iniciado: ${detail.formattedDate}',
                style: TextStyle(
                  fontSize: res.fontSize(11),
                  color: AppTheme.grey1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final Map<String, dynamic> task;
  final Responsive res;
  final VoidCallback onTap;

  const _TaskTile({required this.task, required this.res, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: res.spacing(8)),
        padding: EdgeInsets.all(res.spacing(12)),
        decoration: BoxDecoration(
          color: AppTheme.warningColor.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.warningColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.assignment_late_outlined,
              color: AppTheme.warningColor,
              size: res.iconSize(20),
            ),
            SizedBox(width: res.spacing(10)),
            Expanded(
              child: Text(
                task['stepName'] as String? ??
                    task['title'] as String? ??
                    'Tarea pendiente',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: res.fontSize(13),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: res.iconSize(12),
              color: AppTheme.grey1,
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final dynamic entry;
  final Responsive res;
  final bool isLast;

  const _HistoryTile({
    required this.entry,
    required this.res,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: res.dp(0.8),
                height: res.dp(0.8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Container(
                  width: 1.5,
                  color: AppTheme.primaryColor.withOpacity(0.25),
                  height: double.infinity,
                ),
            ],
          ),
          SizedBox(width: res.spacing(10)),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: res.spacing(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.eventType ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: res.fontSize(13),
                    ),
                  ),
                  if ((entry.description ?? '').isNotEmpty)
                    Text(
                      entry.description!,
                      style: TextStyle(
                        fontSize: res.fontSize(12),
                        color: AppTheme.grey1,
                      ),
                    ),
                  Text(
                    entry.formattedDate ?? '',
                    style: TextStyle(
                      fontSize: res.fontSize(11),
                      color: AppTheme.grey1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
