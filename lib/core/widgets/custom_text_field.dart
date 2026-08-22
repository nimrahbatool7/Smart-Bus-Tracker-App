import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Glassmorphism text field that supports both plain use and Form validation.
/// When [validator] is provided, wraps the input in [TextFormField].
class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.enabled = true,
  });

  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    final inputDecoration = InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: isLight ? Colors.grey.shade500 : Colors.white.withOpacity(0.5),
      ),
      prefixIcon: Icon(prefixIcon, color: AppTheme.primaryColor),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      errorStyle: const TextStyle(color: AppTheme.errorColor, fontSize: 12),
    );

    final textStyle = TextStyle(
      color: isLight ? Colors.black87 : Colors.white,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isLight
                ? Colors.white.withOpacity(0.8)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isLight
                  ? Colors.grey.shade300
                  : Colors.white.withOpacity(0.1),
            ),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            style: textStyle,
            enabled: enabled,
            validator: validator,
            onChanged: onChanged,
            autovalidateMode: validator != null
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            decoration: inputDecoration,
          ),
        ),
      ),
    );
  }
}
