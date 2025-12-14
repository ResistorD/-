import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final FocusNode? focusNode;

  const CustomTextField({
    Key? key,
    this.labelText,
    this.hintText,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onEditingComplete,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      obscureText: obscureText,
      enabled: enabled,
      maxLines: maxLines,
      minLines: minLines,
      expands: expands,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      style: TextStyle(
        fontSize: 16,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}