/// Guidelines for optimizing code according to Figma designs
/// 
/// This file contains best practices for implementing UI components
/// that match Figma designs precisely.

import 'package:flutter/material.dart';

/// A utility class for implementing Figma-based design specifications
class FigmaDesignSystem {
  /// Convert Figma measurements to Flutter values
  /// 
  /// Figma typically uses specific spacing and sizing standards
  static const double baseSpacingUnit = 8.0;

  /// Standard spacing multipliers based on Figma design systems
  static const Map<String, double> spacings = {
    'xxs': baseSpacingUnit * 0.25, // 2dp
    'xs': baseSpacingUnit * 0.5,   // 4dp
    'sm': baseSpacingUnit * 1,     // 8dp
    'md': baseSpacingUnit * 1.5,   // 12dp
    'lg': baseSpacingUnit * 2,     // 16dp
    'xl': baseSpacingUnit * 2.5,   // 20dp
    'xxl': baseSpacingUnit * 3,    // 24dp
    'xxxl': baseSpacingUnit * 4,   // 32dp
  };

  /// Common border radius values from Figma designs
  static const Map<String, BorderRadius> borderRadius = {
    'small': BorderRadius.all(Radius.circular(4)),
    'medium': BorderRadius.all(Radius.circular(8)),
    'large': BorderRadius.all(Radius.circular(12)),
    'xlarge': BorderRadius.all(Radius.circular(16)),
    'full': BorderRadius.all(Radius.circular(9999)),
  };

  /// Typography scale based on Figma design systems
  static const Map<String, TextStyle> typography = {
    'displayLarge': TextStyle(fontSize: 57, fontWeight: FontWeight.w400, letterSpacing: -0.25),
    'displayMedium': TextStyle(fontSize: 45, fontWeight: FontWeight.w400, letterSpacing: 0),
    'displaySmall': TextStyle(fontSize: 36, fontWeight: FontWeight.w400, letterSpacing: 0),
    'headlineLarge': TextStyle(fontSize: 32, fontWeight: FontWeight.w400, letterSpacing: 0),
    'headlineMedium': TextStyle(fontSize: 28, fontWeight: FontWeight.w400, letterSpacing: 0),
    'headlineSmall': TextStyle(fontSize: 24, fontWeight: FontWeight.w400, letterSpacing: 0),
    'titleLarge': TextStyle(fontSize: 22, fontWeight: FontWeight.w500, letterSpacing: 0),
    'titleMedium': TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15),
    'titleSmall': TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
    'bodyLarge': TextStyle(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
    'bodyMedium': TextStyle(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
    'bodySmall': TextStyle(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
    'labelLarge': TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
    'labelMedium': TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
    'labelSmall': TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
  };
}

/// A widget that helps implement Figma-based constraints
class FigmaSizedBox extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;

  const FigmaSizedBox({
    Key? key,
    this.width,
    this.height,
    this.child,
  }) : super(key: key);

  /// Create a box with Figma-based spacing unit
  const FigmaSizedBox.unit({
    Key? key,
    double widthFactor = 1,
    double heightFactor = 1,
    Widget? child,
  }) : this(
    key: key,
    width: FigmaDesignSystem.baseSpacingUnit * widthFactor,
    height: FigmaDesignSystem.baseSpacingUnit * heightFactor,
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: child,
    );
  }
}

/// A container that implements common Figma design patterns
class FigmaContainer extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BoxDecoration? decoration;
  final Color? color;
  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final BoxBorder? border;

  const FigmaContainer({
    Key? key,
    this.child,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.decoration,
    this.color,
    this.width,
    this.height,
    this.borderRadius,
    this.border,
  }) : super(key: key);

  /// Creates a container with common Figma design properties
  const FigmaContainer.card({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    EdgeInsetsGeometry margin = const EdgeInsets.all(8),
    Color? backgroundColor,
    BorderRadiusGeometry borderRadius = const BorderRadius.all(Radius.circular(8)),
  }) : this(
    key: key,
    child: child,
    padding: padding,
    margin: margin,
    color: backgroundColor,
    borderRadius: borderRadius,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: decoration ?? BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        border: border,
      ),
      child: child,
    );
  }
}

/// Helper methods for converting Figma measurements
extension FigmaMeasurementExtension on num {
  /// Convert logical pixels to device pixels
  double get toFigmaSpacing => (this / 8).roundToDouble() * 8;
  
  /// Get responsive size based on screen dimensions
  double get responsiveSize {
    // This would typically be calculated based on screen size
    // relative to a standard Figma artboard size
    return this.toDouble();
  }
}