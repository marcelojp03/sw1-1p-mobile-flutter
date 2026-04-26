import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sw1_p1/config/theme/app_theme.dart';
import 'package:sw1_p1/features/auth/providers/auth_provider.dart';
import 'package:sw1_p1/features/procedures/entities/procedure_models.dart';
import 'package:sw1_p1/features/procedures/providers/procedures_provider.dart';
import 'package:sw1_p1/shared/utils/responsive.dart';
import 'package:sw1_p1/shared/widgets/custom_filled_button.dart';
import 'package:sw1_p1/shared/widgets/loading_widget.dart';
import 'package:sw1_p1/shared/widgets/modern_toast.dart';

class ProcedureNewScreen extends ConsumerStatefulWidget {
  const ProcedureNewScreen({super.key});

  @override
  ConsumerState<ProcedureNewScreen> createState() => _ProcedureNewScreenState();
}

class _ProcedureNewScreenState extends ConsumerState<ProcedureNewScreen> {
  WorkflowPolicy? _selectedPolicy;

  @override
  Widget build(BuildContext context) {
    final res = context.responsive;
    final policiesAsync = ref.watch(availablePoliciesProvider);
    final startState = ref.watch(startProcedureProvider);

    ref.listen<StartProcedureState>(startProcedureProvider, (prev, next) {
      if (!next.isLoading) {
        if (next.result != null && (prev?.result != next.result)) {
          showModernToast(
            context,
            message: 'Trámite iniciado con éxito',
            type: ToastType.success,
          );
          ref.invalidate(proceduresSummaryProvider);
          ref.read(startProcedureProvider.notifier).reset();
          context.go('/tramites/${next.result!.id}');
        } else if (next.error != null && (prev?.error != next.error)) {
          showModernToast(context, message: next.error!, type: ToastType.error);
        }
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Trámite')),
      body: policiesAsync.when(
        loading:
            () => const LoadingWidget(useShimmer: true, shimmerItemCount: 4),
        error:
            (e, _) => Center(
              child: Text(
                'Error: ${e.toString().replaceFirst('Exception: ', '')}',
              ),
            ),
        data: (policies) {
          final available = policies.where((p) => p.mobileAllowed).toList();
          if (available.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(res.spacing(24)),
                child: Text(
                  'No hay trámites disponibles para iniciar desde la app móvil.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: res.fontSize(14)),
                ),
              ),
            );
          }
          return _buildPolicyList(context, res, available, startState);
        },
      ),
    );
  }

  Widget _buildPolicyList(
    BuildContext context,
    Responsive res,
    List<WorkflowPolicy> policies,
    StartProcedureState startState,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(res.spacing(16)),
            itemCount: policies.length,
            itemBuilder: (_, index) {
              final policy = policies[index];
              final isSelected = _selectedPolicy?.id == policy.id;
              return GestureDetector(
                onTap: () => setState(() => _selectedPolicy = policy),
                child: AnimatedContainer(
                  duration: 200.ms,
                  margin: EdgeInsets.only(bottom: res.spacing(10)),
                  padding: EdgeInsets.all(res.spacing(14)),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? AppTheme.primaryColor.withOpacity(0.08)
                            : (isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.white),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color:
                          isSelected
                              ? AppTheme.primaryColor
                              : (isDark
                                  ? Colors.white.withOpacity(0.06)
                                  : Colors.black.withOpacity(0.06)),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(res.spacing(10)),
                        decoration: BoxDecoration(
                          color: (isSelected
                                  ? AppTheme.primaryColor
                                  : AppTheme.grey1)
                              .withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.assignment_outlined,
                          color:
                              isSelected
                                  ? AppTheme.primaryColor
                                  : AppTheme.grey1,
                          size: res.iconSize(20),
                        ),
                      ),
                      SizedBox(width: res.spacing(12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              policy.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: res.fontSize(14),
                                color:
                                    isSelected ? AppTheme.primaryColor : null,
                              ),
                            ),
                            if ((policy.description ?? '').isNotEmpty) ...[
                              SizedBox(height: res.spacing(3)),
                              Text(
                                policy.description!,
                                style: TextStyle(
                                  fontSize: res.fontSize(12),
                                  color: AppTheme.grey1,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle_rounded,
                          color: AppTheme.primaryColor,
                          size: res.iconSize(20),
                        ),
                    ],
                  ),
                ),
              ).animate().fadeIn(
                delay: Duration(milliseconds: index * 60),
                duration: 300.ms,
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.all(res.spacing(16)),
            child: CustomFilledButton(
              text: 'Iniciar trámite',
              onPressed:
                  _selectedPolicy == null ? null : () => _handleStart(context),
              isLoading: startState.isLoading,
              isEnabled: _selectedPolicy != null,
              icon: Icons.play_arrow_rounded,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleStart(BuildContext context) async {
    final user = ref.read(authProvider).user;
    if (user == null || _selectedPolicy == null) return;
    await ref
        .read(startProcedureProvider.notifier)
        .start(
          StartProcedureRequest(
            policyId: _selectedPolicy!.id,
            clientId: user.clientId ?? user.id,
            organizationId: user.organizationId ?? '',
          ),
        );
  }
}
