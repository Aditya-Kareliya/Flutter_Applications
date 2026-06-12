import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlatformTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final String? label; // Material only
  final IconData? prefixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const PlatformTextField({
    super.key,
    this.controller,
    this.placeholder,
    this.label,
    this.prefixIcon,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // CupertinoTextField doesn't have a label built-in like Material
          // We can just rely on placeholder or show a text above if needed.
          // For now, let's just use the field.
          CupertinoTextField(
            controller: controller,
            placeholder: placeholder ?? label,
            obscureText: obscureText,
            keyboardType: keyboardType,
            onChanged: onChanged,
            prefix: prefix ?? (prefixIcon != null 
                ? Padding(
                    padding: const EdgeInsets.only(left: 12, right: 4),
                    child: Icon(prefixIcon, color: CupertinoColors.systemGrey),
                  ) 
                : null),
            suffix: suffix,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(12),
            ),
            style: const TextStyle(color: CupertinoColors.label),
          ),
          // Simple validation error display could be added here if needed
          // as CupertinoTextField doesn't have 'validator' built-in like TextFormField
        ],
      );
    } else {
      return TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          hintText: placeholder,
          prefixIcon: prefix ?? (prefixIcon != null ? Icon(prefixIcon) : null),
          suffixIcon: suffix,
          // Decoration handling depends on Theme, assuming AppTheme takes care of borders
        ),
      );
    }
  }
}
