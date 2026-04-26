import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sw1_p1/config/theme/app_theme.dart';
import 'package:sw1_p1/shared/utils/responsive.dart';

class CustomFilledButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final EdgeInsets? padding;
  final bool useGradient;

  const CustomFilledButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.padding,
    this.useGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    final res = context.responsive;
    final isActive = isEnabled && !isLoading && onPressed != null;

    if (useGradient && backgroundColor == null) {
      return SizedBox(
            width: width ?? double.infinity,
            height: height ?? res.spacing(50),
            child: Material(
              borderRadius: BorderRadius.circular(12),
              color: Colors.transparent,
              child: InkWell(
                onTap: isActive ? onPressed : null,
                borderRadius: BorderRadius.circular(12),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient:
                        isActive
                            ? AppTheme.primaryGradient
                            : LinearGradient(
                              colors: [
                                AppTheme.primaryColor.withValues(alpha: 0.5),
                                AppTheme.secondaryColor.withValues(alpha: 0.5),
                              ],
                            ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _buildContent(context, res),
                ),
              ),
            ),
          )
          .animate()
          .fadeIn(duration: 300.ms)
          .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0));
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? res.spacing(50),
      child: FilledButton(
        onPressed: isActive ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor ?? AppTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: padding,
        ),
        child: _buildContent(context, res),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Responsive res) {
    if (isLoading) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: res.dp(1.6),
            height: res.dp(1.6),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: textColor ?? Colors.white,
            ),
          ),
          SizedBox(width: res.spacing(8)),
          Text(
            'Cargando...',
            style: TextStyle(
              color: textColor ?? Colors.white,
              fontSize: fontSize ?? res.fontSize(15),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: res.iconSize(18), color: textColor ?? Colors.white),
          SizedBox(width: res.spacing(8)),
          Text(
            text,
            style: TextStyle(
              color: textColor ?? Colors.white,
              fontSize: fontSize ?? res.fontSize(15),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        color: textColor ?? Colors.white,
        fontSize: fontSize ?? res.fontSize(15),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
