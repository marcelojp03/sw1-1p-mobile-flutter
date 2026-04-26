import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sw1_p1/config/theme/app_theme.dart';
import 'package:sw1_p1/shared/utils/responsive.dart';

enum ToastType { success, warning, error, info }

void showModernToast(
  BuildContext context, {
  required String message,
  ToastType type = ToastType.info,
  Duration duration = const Duration(seconds: 3),
}) {
  Color color;
  IconData icon;

  switch (type) {
    case ToastType.success:
      color = AppTheme.successColor;
      icon = Icons.check_circle_rounded;
    case ToastType.warning:
      color = AppTheme.warningColor;
      icon = Icons.warning_amber_rounded;
    case ToastType.error:
      color = AppTheme.errorColor;
      icon = Icons.error_rounded;
    case ToastType.info:
      color = AppTheme.primaryColor;
      icon = Icons.info_rounded;
  }

  final overlay = Overlay.of(context);
  late final OverlayEntry entry;

  entry = OverlayEntry(
    builder:
        (ctx) => _ToastWidget(
          message: message,
          color: color,
          icon: icon,
          duration: duration,
          onDismiss: () => entry.remove(),
        ),
  );

  overlay.insert(entry);
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final Color color;
  final IconData icon;
  final Duration duration;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.color,
    required this.icon,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> {
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.duration, () {
      if (mounted) {
        setState(() => _visible = false);
        Future.delayed(const Duration(milliseconds: 300), widget.onDismiss);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final res = context.responsive;

    return Positioned(
      top: MediaQuery.of(context).viewPadding.top + res.spacing(16),
      left: res.spacing(16),
      right: res.spacing(16),
      child: Material(
            color: Colors.transparent,
            child: AnimatedOpacity(
              opacity: _visible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: res.spacing(16),
                  vertical: res.spacing(12),
                ),
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.icon,
                      color: Colors.white,
                      size: res.iconSize(20),
                    ),
                    SizedBox(width: res.spacing(10)),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: res.fontSize(13),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() => _visible = false);
                        Future.delayed(
                          const Duration(milliseconds: 300),
                          widget.onDismiss,
                        );
                      },
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                        size: res.iconSize(16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .animate()
          .slideY(
            begin: -0.3,
            end: 0,
            duration: 300.ms,
            curve: Curves.fastOutSlowIn,
          )
          .fadeIn(duration: 300.ms),
    );
  }
}
