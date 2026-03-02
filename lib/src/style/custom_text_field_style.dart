import 'package:flutter/material.dart';

import '../theme/hybrid_text_field_colors.dart';
import 'country_picker_dialog_style.dart';
import 'custom_prefixes_list_style.dart';

/// Visual style configuration for [BaseTextField] and all its variants.
class HybridTextFieldStyle {
  /// ── Typography ─────────────────────────────────────────────────────────────
  final TextStyle textStyle;
  final TextStyle labelStyle;
  final TextStyle hintStyle;
  final TextStyle supportingTextStyle;
  final TextStyle descriptionStyle;
  final TextStyle errorStyle;

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
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? disabledBorderColor;
  final Color? errorBorderColor;
  final double borderWidth;
  final double focusedBorderWidth;
  final BorderRadius borderRadius;

  /// ── double border ───────────────────────────────────────────────────────────

  /// Activates the double border ring. When null, double-border is disabled.
  final Color? doubleBorderColor;

  /// Color of the double ring when focused. Falls back to [doubleBorderColor].
  final Color? doubleFocusedBorderColor;

  /// Color of the double ring on error. Falls back to [errorBorderColor].
  final Color? doubleErrorBorderColor;

  /// Thickness of the double ring. Default 2.0.
  final double doubleBorderWidth;

  /// Radius of the double ring.
  /// Defaults to [borderRadius] expanded by [doubleBorderWidth] on each corner
  /// so it sits flush around the inner field without any gaps.
  final BorderRadius? doubleBorderRadius;

  /// Show double ring when the field is focused. Default true.
  final bool showDoubleBorderOnFocus;

  /// Show double ring when the field has an error. Default true.
  final bool showDoubleBorderOnError;

  // ── Spacing / Layout ───────────────────────────────────────────────────────
  final EdgeInsets contentPadding;
  final double descriptionSpacing;
  final double supportingTextSpacing;

  final TextDirection? hintTextDirection;
  final int? hintMaxLines;

  final TextAlign textAlign;
  final TextAlignVertical textAlignVertical;

  final CustomPrefixesListStyle prefixesListStyle;
  final CountryPickerDialogStyle dialogStyle;

  // --- Computed getters con fallback ---
  Color get getBorderColor => borderColor ?? Colors.grey;
  Color get getFocusedBorderColor => focusedBorderColor ?? getBorderColor;
  Color get getDisabledBorderColor => disabledBorderColor ?? getBorderColor;
  Color get getErrorBorderColor => errorBorderColor ?? getBorderColor;

  // Para el double border puedes mantener lo que ya hiciste antes
  Color get getDoubleBorderColor => doubleBorderColor ?? getBorderColor;
  Color get getDoubleFocusedBorderColor => doubleFocusedBorderColor ?? getFocusedBorderColor;
  Color get getDoubleErrorBorderColor => doubleErrorBorderColor ?? getErrorBorderColor;

  const HybridTextFieldStyle({
    double? doubleBorderRadius,

    /// ── Typography ──────────────────────────────────────────────────────────
    this.textStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
    this.labelStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
    this.focusedBorderColor,
    this.disabledBorderColor,
    this.errorBorderColor,
    this.borderWidth = 1.0,
    this.focusedBorderWidth = 1.5,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),

    /// ── double border (double-border effect) ─────────────────────────────────
    /// Leave [doubleBorderColor] null to disable entirely.
    this.doubleBorderColor,
    this.doubleFocusedBorderColor,
    this.doubleErrorBorderColor,
    this.doubleBorderWidth = 2.0,
    this.showDoubleBorderOnFocus = false,
    this.showDoubleBorderOnError = false,

    /// ── Spacing / Layout ────────────────────────────────────────────────────
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.descriptionSpacing = 8.0,
    this.supportingTextSpacing = 4.0,
    this.errorStyle = const TextStyle(color: Colors.red, fontSize: 10),
    this.hintTextDirection = TextDirection.ltr,
    this.hintMaxLines,
    this.textAlign = TextAlign.start,
    this.textAlignVertical = TextAlignVertical.center,
    this.prefixesListStyle = const CustomPrefixesListStyle(),
    this.dialogStyle = const CountryPickerDialogStyle(),
  }) : doubleBorderRadius = borderRadius;

  // ── Computed helpers ───────────────────────────────────────────────────────

  /// Returns the double ring radius, expanding each corner of [borderRadius]
  /// by [doubleBorderWidth] so the ring wraps the inner border perfectly.
  BorderRadius get resolvedDoubleBorderRadius {
    return doubleBorderRadius ??
        BorderRadius.only(
          topLeft: Radius.circular(borderRadius.topLeft.x + doubleBorderWidth),
          topRight: Radius.circular(borderRadius.topRight.x + doubleBorderWidth),
          bottomLeft: Radius.circular(borderRadius.bottomLeft.x + doubleBorderWidth),
          bottomRight: Radius.circular(borderRadius.bottomRight.x + doubleBorderWidth),
        );
  }
}
