import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final VoidCallback? onTap;
  final BorderRadiusGeometry? borderRadius;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final cardTheme = Theme.of(context).cardTheme;

    return Card(
      elevation: elevation ?? cardTheme.elevation ?? 2.0,
      color: color ?? cardTheme.color ?? Theme.of(context).colorScheme.surface,
      margin: margin ?? cardTheme.margin ?? const EdgeInsets.all(4.0),
      shape: borderRadius != null
          ? RoundedRectangleBorder(borderRadius: borderRadius!)
          : cardTheme.shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? (cardTheme.shape is RoundedRectangleBorder
            ? (cardTheme.shape as RoundedRectangleBorder).borderRadius
            : BorderRadius.circular(12.0)),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}

// Example Usage:
// CustomCard(
//   onTap: () => print("Card tapped!"),
//   child: Column(
//     mainAxisSize: MainAxisSize.min,
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text("Service Title", style: Theme.of(context).textTheme.headlineSmall),
//       SizedBox(height: 8),
//       Text("This is a description of the service offered."),
//       SizedBox(height: 8),
//       Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           Icon(Icons.star, color: Colors.amber, size: 16),
//           Text("4.5 (120 reviews)"),
//         ],
//       )
//     ],
//   ),
// )
