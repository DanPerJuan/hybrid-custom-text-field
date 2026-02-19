import 'package:flutter/material.dart';

import '../theme/hybrid_text_field_colors.dart';

/// Visual style configuration for [BaseTextField] and all its variants.
class HybridTextFieldStyle {
  /// ── Typography ─────────────────────────────────────────────────────────────
  final TextStyle textStyle;
  final TextStyle labelStyle;
  final TextStyle hintStyle;
  final TextStyle supportingTextStyle;
  final TextStyle descriptionStyle;

  /// ── Colors ─────────────────────────────────────────────────────────────────
  final Color textColor;
  final Color disabledTextColor;
  final Color hintColor;
  final Color labelColor;
  final Color focusedLabelColor;
  final Color errorLabelColor;
  final Color supportingTextColor;
  final Color errorTextColor;
  final Color descriptionColor;
  final Color cursorColor;

  /// ── Background ─────────────────────────────────────────────────────────────
  final Color fillColor;
  final Color disabledFillColor;
  final Color errorFillColor;

  /// ── Inner border ───────────────────────────────────────────────────────────
  final Color borderColor;
  final Color focusedBorderColor;
  final Color disabledBorderColor;
  final Color errorBorderColor;
  final double borderWidth;
  final double focusedBorderWidth;
  final BorderRadius borderRadius;

  /// ── Outer border ───────────────────────────────────────────────────────────

  /// Activates the outer border ring. When null, double-border is disabled.
  final Color? outerBorderColor;

  /// Color of the outer ring when focused. Falls back to [outerBorderColor].
  final Color? outerFocusedBorderColor;

  /// Color of the outer ring on error. Falls back to [errorBorderColor].
  final Color? outerErrorBorderColor;

  /// Thickness of the outer ring. Default 2.0.
  final double outerBorderWidth;

  /// Radius of the outer ring.
  /// Defaults to [borderRadius] expanded by [outerBorderWidth] on each corner
  /// so it sits flush around the inner field without any gaps.
  final BorderRadius? outerBorderRadius;

  /// Show outer ring when the field is focused. Default true.
  final bool showOuterBorderOnFocus;

  /// Show outer ring when the field has an error. Default true.
  final bool showOuterBorderOnError;

  // ── Spacing / Layout ───────────────────────────────────────────────────────
  final EdgeInsets contentPadding;
  final double descriptionSpacing;
  final double supportingTextSpacing;
  final double height;

  const HybridTextFieldStyle({
    /// ── Typography ──────────────────────────────────────────────────────────
    this.textStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
    this.labelStyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    this.hintStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
    this.supportingTextStyle = const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
    this.descriptionStyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),

    /// ── Colors ──────────────────────────────────────────────────────────────
    this.textColor = HybridTextFieldColors.primaryBlack,
    this.disabledTextColor = HybridTextFieldColors.disabledText,
    this.hintColor = HybridTextFieldColors.gray3,
    this.labelColor = HybridTextFieldColors.grayPurple,
    this.focusedLabelColor = HybridTextFieldColors.grayPurple,
    this.errorLabelColor = HybridTextFieldColors.errorRed,
    this.supportingTextColor = HybridTextFieldColors.grayPurple,
    this.errorTextColor = HybridTextFieldColors.errorRed,
    this.descriptionColor = HybridTextFieldColors.primaryBlack,
    this.cursorColor = HybridTextFieldColors.primaryBlack,

    /// ── Background ──────────────────────────────────────────────────────────
    this.fillColor = HybridTextFieldColors.white,
    this.disabledFillColor = HybridTextFieldColors.white,
    this.errorFillColor = HybridTextFieldColors.white,

    /// ── Inner border ────────────────────────────────────────────────────────
    this.borderColor = HybridTextFieldColors.dustyGrayTint,
    this.focusedBorderColor = HybridTextFieldColors.dustyGrayTint,
    this.disabledBorderColor = HybridTextFieldColors.disabledBorder,
    this.errorBorderColor = HybridTextFieldColors.errorRed,
    this.borderWidth = 1.0,
    this.focusedBorderWidth = 1.5,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),

    /// ── Outer border (double-border effect) ─────────────────────────────────
    /// Leave [outerBorderColor] null to disable entirely.
    this.outerBorderColor,
    this.outerFocusedBorderColor,
    this.outerErrorBorderColor,
    this.outerBorderWidth = 2.0,
    this.outerBorderRadius,
    this.showOuterBorderOnFocus = true,
    this.showOuterBorderOnError = true,

    /// ── Spacing / Layout ────────────────────────────────────────────────────
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    this.descriptionSpacing = 8.0,
    this.supportingTextSpacing = 4.0,
    this.height = 48.0,
  });

  // ── Computed helpers ───────────────────────────────────────────────────────

  /// Returns the outer ring radius, expanding each corner of [borderRadius]
  /// by [outerBorderWidth] so the ring wraps the inner border perfectly.
  BorderRadius get resolvedOuterBorderRadius {
    return outerBorderRadius ??
        BorderRadius.only(
          topLeft: Radius.circular(borderRadius.topLeft.x + outerBorderWidth),
          topRight: Radius.circular(borderRadius.topRight.x + outerBorderWidth),
          bottomLeft: Radius.circular(borderRadius.bottomLeft.x + outerBorderWidth),
          bottomRight: Radius.circular(borderRadius.bottomRight.x + outerBorderWidth),
        );
  }

  HybridTextFieldStyle copyWith({
    TextStyle? textStyle,
    TextStyle? labelStyle,
    TextStyle? hintStyle,
    TextStyle? supportingTextStyle,
    TextStyle? descriptionStyle,
    Color? textColor,
    Color? disabledTextColor,
    Color? hintColor,
    Color? labelColor,
    Color? focusedLabelColor,
    Color? errorLabelColor,
    Color? supportingTextColor,
    Color? errorTextColor,
    Color? descriptionColor,
    Color? cursorColor,
    Color? fillColor,
    Color? disabledFillColor,
    Color? errorFillColor,
    Color? borderColor,
    Color? focusedBorderColor,
    Color? disabledBorderColor,
    Color? errorBorderColor,
    double? borderWidth,
    double? focusedBorderWidth,
    BorderRadius? borderRadius,
    Color? outerBorderColor,
    Color? outerFocusedBorderColor,
    Color? outerErrorBorderColor,
    double? outerBorderWidth,
    BorderRadius? outerBorderRadius,
    bool? showOuterBorderOnFocus,
    bool? showOuterBorderOnError,
    EdgeInsets? contentPadding,
    double? descriptionSpacing,
    double? supportingTextSpacing,
    double? height,
  }) {
    return HybridTextFieldStyle(
      textStyle: textStyle ?? this.textStyle,
      labelStyle: labelStyle ?? this.labelStyle,
      hintStyle: hintStyle ?? this.hintStyle,
      supportingTextStyle: supportingTextStyle ?? this.supportingTextStyle,
      descriptionStyle: descriptionStyle ?? this.descriptionStyle,
      textColor: textColor ?? this.textColor,
      disabledTextColor: disabledTextColor ?? this.disabledTextColor,
      hintColor: hintColor ?? this.hintColor,
      labelColor: labelColor ?? this.labelColor,
      focusedLabelColor: focusedLabelColor ?? this.focusedLabelColor,
      errorLabelColor: errorLabelColor ?? this.errorLabelColor,
      supportingTextColor: supportingTextColor ?? this.supportingTextColor,
      errorTextColor: errorTextColor ?? this.errorTextColor,
      descriptionColor: descriptionColor ?? this.descriptionColor,
      cursorColor: cursorColor ?? this.cursorColor,
      fillColor: fillColor ?? this.fillColor,
      disabledFillColor: disabledFillColor ?? this.disabledFillColor,
      errorFillColor: errorFillColor ?? this.errorFillColor,
      borderColor: borderColor ?? this.borderColor,
      focusedBorderColor: focusedBorderColor ?? this.focusedBorderColor,
      disabledBorderColor: disabledBorderColor ?? this.disabledBorderColor,
      errorBorderColor: errorBorderColor ?? this.errorBorderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      focusedBorderWidth: focusedBorderWidth ?? this.focusedBorderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      outerBorderColor: outerBorderColor ?? this.outerBorderColor,
      outerFocusedBorderColor: outerFocusedBorderColor ?? this.outerFocusedBorderColor,
      outerErrorBorderColor: outerErrorBorderColor ?? this.outerErrorBorderColor,
      outerBorderWidth: outerBorderWidth ?? this.outerBorderWidth,
      outerBorderRadius: outerBorderRadius ?? this.outerBorderRadius,
      showOuterBorderOnFocus: showOuterBorderOnFocus ?? this.showOuterBorderOnFocus,
      showOuterBorderOnError: showOuterBorderOnError ?? this.showOuterBorderOnError,
      contentPadding: contentPadding ?? this.contentPadding,
      descriptionSpacing: descriptionSpacing ?? this.descriptionSpacing,
      supportingTextSpacing: supportingTextSpacing ?? this.supportingTextSpacing,
      height: height ?? this.height,
    );
  }
}
