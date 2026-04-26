import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sw1_p1/config/theme/app_theme.dart';
import 'package:sw1_p1/shared/utils/responsive.dart';

enum DialogType { info, success, warning, error, confirm }

Future<T?> showModernDialog<T>({
  required BuildContext context,
  required String title,
  required String message,
  DialogType type = DialogType.info,
  String confirmText = 'Aceptar',
  String? cancelText,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder:
        (ctx) => ModernDialog(
          title: title,
          message: message,
          type: type,
          confirmText: confirmText,
          cancelText: cancelText,
          onConfirm: onConfirm,
          onCancel: onCancel,
        ),
  );
}

class ModernDialog extends StatelessWidget {
  final String title;
  final String message;
  final DialogType type;
  final String confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const ModernDialog({
    super.key,
    required this.title,
    required this.message,
    this.type = DialogType.info,
    this.confirmText = 'Aceptar',
    this.cancelText,
    this.onConfirm,
    this.onCancel,
  });

  Color _getColor() {
    return switch (type) {
      DialogType.success => AppTheme.successColor,
      DialogType.warning => AppTheme.warningColor,
      DialogType.error => AppTheme.errorColor,
      DialogType.confirm => AppTheme.primaryColor,
      DialogType.info => AppTheme.primaryColor,
    };
  }

  IconData _getIcon() {
    return switch (type) {
      DialogType.success => Icons.check_circle_rounded,
      DialogType.warning => Icons.warning_amber_rounded,
      DialogType.error => Icons.error_rounded,
      DialogType.confirm => Icons.help_rounded,
      DialogType.info => Icons.info_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = _getColor();
    final icon = _getIcon();
    final res = context.responsive;

    return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: res.wp(8)),
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          child: Padding(
            padding: EdgeInsets.all(res.spacing(24)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(res.spacing(14)),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: res.iconSize(32)),
                ),
                SizedBox(height: res.spacing(16)),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: res.fontSize(18),
                  ),
                ),
                SizedBox(height: res.spacing(8)),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontSize: res.fontSize(14),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: res.spacing(24)),
                Row(
                  children: [
                    if (cancelText != null) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            onCancel?.call();
                          },
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: res.spacing(12),
                            ),
                          ),
                          child: Text(
                            cancelText!,
                            style: TextStyle(fontSize: res.fontSize(14)),
                          ),
                        ),
                      ),
                      SizedBox(width: res.spacing(12)),
                    ],
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onConfirm?.call();
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: res.spacing(12),
                          ),
                        ),
                        child: Text(
                          confirmText,
                          style: TextStyle(
                            fontSize: res.fontSize(14),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 200.ms)
        .scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1.0, 1.0),
          duration: 220.ms,
          curve: Curves.fastOutSlowIn,
        );
  }
}
