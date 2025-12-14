import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? elevation;
  final ShapeBorder? shape;
  final VoidCallback? onPressed;
  final bool enabled;

  const CustomCard({
    Key? key,
    required this.child,
    this.margin,
    this.padding,
    this.color,
    this.elevation = 2,
    this.shape,
    this.onPressed,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );

    if (onPressed != null) {
      return Card(
        margin: margin,
        color: color,
        elevation: elevation,
        shape: shape ?? defaultShape,
        child: InkWell(
          borderRadius: (shape ?? defaultShape).borderRadius,
          onTap: enabled ? onPressed : null,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      );
    } else {
      return Card(
        margin: margin,
        color: color,
        elevation: elevation,
        shape: shape ?? defaultShape,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      );
    }
  }
}