import 'package:flutter/material.dart';

/// A custom [InputBorder] that draws an outline with a floating label style.
///
/// This border allows customization of the [borderRadius] and [borderSide].
/// It can be used in [TextFormField] or [TextField] to create rounded outlined fields.
class FloatingLabelOutlineInputBorder extends InputBorder {
  /// Creates a [FloatingLabelOutlineInputBorder].
  ///
  /// [borderSide] defines the color, width, and style of the border.
  /// [borderRadius] defines the roundness of the corners. Defaults to 16px circular radius.
  const FloatingLabelOutlineInputBorder({
    super.borderSide = const BorderSide(),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  /// The radius of the border corners.
  final BorderRadius borderRadius;

  @override
  bool get isOutline => false;

  /// Returns a copy of this border with the given fields replaced with new values.
  @override
  FloatingLabelOutlineInputBorder copyWith({
    BorderSide? borderSide,
    BorderRadius? borderRadius,
  }) {
    return FloatingLabelOutlineInputBorder(
      borderSide: borderSide ?? this.borderSide,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  /// Returns the insets used by this border for layout.
  @override
  EdgeInsetsGeometry get dimensions {
    return EdgeInsets.all(borderSide.width);
  }

  /// Scales the border by the given factor [t].
  @override
  FloatingLabelOutlineInputBorder scale(double t) {
    return FloatingLabelOutlineInputBorder(
      borderSide: borderSide.scale(t),
      borderRadius: borderRadius * t,
    );
  }

  /// Linearly interpolates from another [ShapeBorder] to this border.
  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is FloatingLabelOutlineInputBorder) {
      final FloatingLabelOutlineInputBorder outline = a;
      return FloatingLabelOutlineInputBorder(
        borderRadius: BorderRadius.lerp(outline.borderRadius, borderRadius, t)!,
        borderSide: BorderSide.lerp(outline.borderSide, borderSide, t),
      );
    }
    return super.lerpFrom(a, t);
  }

  /// Linearly interpolates from this border to another [ShapeBorder].
  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is FloatingLabelOutlineInputBorder) {
      final FloatingLabelOutlineInputBorder outline = b;
      return FloatingLabelOutlineInputBorder(
        borderRadius: BorderRadius.lerp(borderRadius, outline.borderRadius, t)!,
        borderSide: BorderSide.lerp(borderSide, outline.borderSide, t),
      );
    }
    return super.lerpTo(b, t);
  }

  /// Returns the inner path for this border inside the given [rect].
  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRRect(borderRadius.resolve(textDirection).toRRect(rect).deflate(borderSide.width));
  }

  /// Returns the outer path for this border inside the given [rect].
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRRect(borderRadius.resolve(textDirection).toRRect(rect));
  }

  /// Paints the interior of the border inside the given [rect].
  @override
  void paintInterior(
    Canvas canvas,
    Rect rect,
    Paint paint, {
    TextDirection? textDirection,
  }) {
    canvas.drawRRect(borderRadius.resolve(textDirection).toRRect(rect), paint);
  }

  @override
  bool get preferPaintInterior => true;

  /// Paints the border on the canvas for the given [rect].
  ///
  /// This method handles drawing the rounded rectangle outline.
  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapStart,
    double gapExtent = 0.0,
    double gapPercentage = 0.0,
    TextDirection? textDirection,
  }) {
    final Paint paint = borderSide.toPaint();
    final RRect outer = borderRadius.toRRect(rect);
    final RRect center = outer.deflate(borderSide.width / 2.0);
    canvas.drawRRect(center, paint);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is FloatingLabelOutlineInputBorder &&
        other.borderSide == borderSide &&
        other.borderRadius == borderRadius;
  }

  @override
  int get hashCode => Object.hash(borderSide, borderRadius);
}
