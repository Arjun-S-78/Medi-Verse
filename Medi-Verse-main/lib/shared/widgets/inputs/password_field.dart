import 'package:flutter/material.dart';
import 'custom_text_field.dart';

/// Reusable Specialized Password Input Widget
class PasswordField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String hintText;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final bool enabled;

  const PasswordField({
    super.key,
    this.controller,
    this.label = 'Password',
    this.hintText = 'Enter your password',
    this.validator,
    this.textInputAction = TextInputAction.done,
    this.onChanged,
    this.onFieldSubmitted,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: label,
      hintText: hintText,
      prefixIcon: Icons.lock_outline_rounded,
      isPassword: true,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: textInputAction,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      enabled: enabled,
    );
  }
}
