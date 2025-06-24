import 'package:flutter/material.dart';

enum ButtonType { primary, secondary, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 48.0, // Default height
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == ButtonType.primary || type == ButtonType.secondary
                    ? colorScheme.onPrimary // Assuming onPrimary for primary/secondary buttons
                    : colorScheme.primary,  // Assuming primary for text buttons
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 18,
                  color: type == ButtonType.primary || type == ButtonType.secondary
                      ? colorScheme.onPrimary // Or specific color from theme
                      : colorScheme.primary, // Or specific color from theme
                ),
                const SizedBox(width: 8),
              ],
              Text(text),
            ],
          );

    switch (type) {
      case ButtonType.primary:
        return SizedBox(
          width: width,
          height: height,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: theme.elevatedButtonTheme.style?.copyWith(
              backgroundColor: MaterialStateProperty.all(colorScheme.primary),
              foregroundColor: MaterialStateProperty.all(colorScheme.onPrimary),
            ),
            child: child,
          ),
        );
      case ButtonType.secondary:
        return SizedBox(
          width: width,
          height: height,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: theme.elevatedButtonTheme.style?.copyWith(
              backgroundColor: MaterialStateProperty.all(colorScheme.secondary),
              foregroundColor: MaterialStateProperty.all(colorScheme.onSecondary), // Ensure onSecondary is defined
            ),
            child: child,
          ),
        );
      case ButtonType.text:
        return SizedBox(
          width: width,
          height: height,
          child: TextButton(
            onPressed: isLoading ? null : onPressed,
            style: theme.textButtonTheme.style?.copyWith(
               foregroundColor: MaterialStateProperty.all(colorScheme.primary),
            ),
            child: child,
          ),
        );
    }
  }
}

// Example Usage (in some other widget):
// CustomButton(
//   text: 'Submit',
//   onPressed: () { print('Primary button pressed'); },
//   type: ButtonType.primary,
//   icon: Icons.send,
//   isLoading: false,
// ),
// CustomButton(
//   text: 'Cancel',
//   onPressed: () { print('Secondary button pressed'); },
//   type: ButtonType.secondary,
// ),
// CustomButton(
//   text: 'Learn More',
//   onPressed: () { print('Text button pressed'); },
//   type: ButtonType.text,
//   icon: Icons.info_outline,
// ),
