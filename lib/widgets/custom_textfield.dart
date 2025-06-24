import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final bool obscureText;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int maxLines;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.enabled = true,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputDecorationTheme = theme.inputDecorationTheme;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon),
                onPressed: onSuffixIconTap,
              )
            : null,
        border: inputDecorationTheme.border ?? const OutlineInputBorder(),
        enabledBorder: inputDecorationTheme.enabledBorder ?? inputDecorationTheme.border,
        focusedBorder: inputDecorationTheme.focusedBorder ?? inputDecorationTheme.border?.copyWith(
          borderSide: BorderSide(color: theme.primaryColor, width: 2.0)
        ),
        errorBorder: inputDecorationTheme.errorBorder ?? inputDecorationTheme.border?.copyWith(
          borderSide: BorderSide(color: theme.colorScheme.error)
        ),
        focusedErrorBorder: inputDecorationTheme.focusedErrorBorder ?? inputDecorationTheme.border?.copyWith(
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2.0)
        ),
        disabledBorder: inputDecorationTheme.disabledBorder,
        filled: inputDecorationTheme.filled,
        fillColor: inputDecorationTheme.fillColor,
        labelStyle: inputDecorationTheme.labelStyle,
        hintStyle: inputDecorationTheme.hintStyle,
        counterText: maxLength != null ? '' : null, // Hide default counter if maxLength is used with custom one
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      maxLines: maxLines,
      enabled: enabled,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}

// Example Usage:
// bool _obscurePassword = true;
// final _emailController = TextEditingController();
// final _passwordController = TextEditingController();

// CustomTextField(
//   controller: _emailController,
//   labelText: 'Email Address',
//   prefixIcon: Icons.email,
//   keyboardType: TextInputType.emailAddress,
//   validator: (value) {
//     if (value == null || value.isEmpty || !value.contains('@')) {
//       return 'Please enter a valid email';
//     }
//     return null;
//   },
// ),
// SizedBox(height: 16),
// CustomTextField(
//   controller: _passwordController,
//   labelText: 'Password',
//   prefixIcon: Icons.lock,
//   obscureText: _obscurePassword,
//   suffixIcon: _obscurePassword ? Icons.visibility_off : Icons.visibility,
//   onSuffixIconTap: () {
//     setState(() {
//       _obscurePassword = !_obscurePassword;
//     });
//   },
//   validator: (value) {
//     if (value == null || value.isEmpty || value.length < 6) {
//       return 'Password must be at least 6 characters';
//     }
//     return null;
//   },
// ),
