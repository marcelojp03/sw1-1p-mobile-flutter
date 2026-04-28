import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sw1_p1/config/theme/app_theme.dart';
import 'package:sw1_p1/features/procedures/entities/procedure_models.dart';
import 'package:sw1_p1/features/procedures/providers/procedures_provider.dart';
import 'package:sw1_p1/shared/utils/responsive.dart';
import 'package:sw1_p1/shared/widgets/loading_widget.dart';

class ProceduresScreen extends ConsumerWidget {
  const ProceduresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = context.responsive;
    final proceduresAsync = ref.watch(proceduresSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Trámites')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tramites/nuevo'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nuevo'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(proceduresSummaryProvider);
          await ref.read(proceduresSummaryProvider.future).catchError((_) {});
        },
        child: proceduresAsync.when(
          loading:
              () => const LoadingWidget(useShimmer: true, shimmerItemCount: 6),
          error:
              (e, _) => Center(
                child: Text(
                  'Error: ${e.toString().replaceFirst('Exception: ', '')}',
                ),
              ),
          data: (page) {
            if (page.content.isEmpty) {
              return _buildEmpty(context, res);
            }
            return ListView.builder(
              padding: EdgeInsets.fromLTRB(
                res.spacing(16),
                res.spacing(12),
                res.spacing(16),
                res.spacing(100),
              ),
              itemCount: page.content.length,
              itemBuilder: (_, index) {
                final p = page.content[index];
                return _ProcedureCard(
                  procedure: p,
                  onTap: () => context.push('/tramites/${p.id}'),
                ).animate().fadeIn(
                  delay: Duration(milliseconds: index * 50),
                  duration: 300.ms,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, Responsive res) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_rounded,
            size: res.dp(5),
            color: AppTheme.grey1,
          ),
          SizedBox(height: res.spacing(16)),
          Text(
            'No tienes trámites',
            style: TextStyle(
              fontSize: res.fontSize(16),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: res.spacing(8)),
          Text(
            'Inicia un nuevo trámite desde el botón +',
            style: TextStyle(fontSize: res.fontSize(13), color: AppTheme.grey1),
          ),
        ],
      ),
    );
  }
}

class _ProcedureCard extends StatelessWidget {
  final ProcedureSummary procedure;
  final VoidCallback onTap;

  const _ProcedureCard({required this.procedure, required this.onTap});

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
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: res.dp(0.45),
              height: res.spacing(52),
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
                      fontSize: res.fontSize(14),
                    ),
                  ),
                  if ((procedure.currentStepName ?? '').isNotEmpty) ...[
                    SizedBox(height: res.spacing(3)),
                    Text(
                      procedure.currentStepName!,
                      style: TextStyle(
                        fontSize: res.fontSize(12),
                        color: AppTheme.grey1,
                      ),
                    ),
                  ],
                  SizedBox(height: res.spacing(5)),
                  Text(
                    procedure.formattedDate,
                    style: TextStyle(
                      fontSize: res.fontSize(11),
                      color: AppTheme.grey1,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: res.spacing(8),
                    vertical: res.spacing(4),
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
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
                SizedBox(height: res.spacing(6)),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: res.iconSize(12),
                  color: AppTheme.grey1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
