import 'package:flutter/material.dart';
import 'package:sw1_p1/config/theme/app_theme.dart';
import 'package:sw1_p1/shared/utils/responsive.dart';

class CustomInputField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool obscureText;
  final bool readOnly;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final IconData? prefixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final String? errorText;
  final String? initialValue;
  final bool enabled;
  final AutovalidateMode autovalidateMode;
  final Color? fillColor;

  const CustomInputField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.obscureText = false,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onTap,
    this.validator,
    this.prefixIcon,
    this.prefix,
    this.suffix,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.errorText,
    this.initialValue,
    this.enabled = true,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final res = context.responsive;

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      readOnly: readOnly,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onTap: onTap,
      validator: validator,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      initialValue: initialValue,
      enabled: enabled,
      autovalidateMode: autovalidateMode,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontSize: res.fontSize(14),
        color: isDark ? Colors.white : AppTheme.bodyFontColor,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        hintStyle: TextStyle(color: AppTheme.grey1, fontSize: res.fontSize(14)),
        labelStyle: TextStyle(
          color: isDark ? AppTheme.grey1 : AppTheme.grey1,
          fontSize: res.fontSize(14),
        ),
        filled: true,
        fillColor:
            fillColor ??
            (isDark
                ? Colors.white.withValues(alpha: 0.06)
                : AppTheme.greyInputBg),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color:
                isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppTheme.primaryColor,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.errorColor, width: 1.5),
        ),
        prefixIcon:
            prefix ??
            (prefixIcon != null
                ? Icon(
                  prefixIcon,
                  size: res.iconSize(18),
                  color: AppTheme.grey1,
                )
                : null),
        suffixIcon: suffix,
        contentPadding: EdgeInsets.symmetric(
          horizontal: res.spacing(14),
          vertical: res.spacing(12),
        ),
      ),
    );
  }
}
