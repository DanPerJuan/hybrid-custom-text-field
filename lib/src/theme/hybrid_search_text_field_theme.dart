import 'package:flutter/material.dart';

import 'hybrid_text_field_theme.dart';

/// Visual theme for [HybridCustomSearchTextField].
///
/// Extends [HybridTextFieldTheme] with search-specific style props.
class HybridSearchTextFieldTheme extends HybridTextFieldTheme {
  /// Maximum height of the results overlay. Default `200`.
  final double resultsMaxHeight;

  /// Custom decoration for the results overlay container.
  final BoxDecoration? resultsDecoration;

  /// Whether to show a divider between result items. Default `false`.
  final bool shouldShowDivider;

  /// Custom divider widget. Falls back to [Divider(height: 1)] when null.
  final Widget? divider;

  final double resultSeparation;

  const HybridSearchTextFieldTheme({
    super.textStyle,
    super.hintStyle,
    super.supportingTextStyle,
    super.descriptionStyle,
    super.errorStyle,
    super.textColor,
    super.disabledTextColor,
    super.labelColor,
    super.focusedLabelColor,
    super.errorLabelColor,
    super.supportingTextColor,
    super.errorTextColor,
    super.descriptionColor,
    super.cursorColor,
    super.fillColor,
    super.disabledFillColor,
    super.borderColor,
    super.focusedBorderColor,
    super.disabledBorderColor,
    super.errorBorderColor,
    super.borderWidth,
    super.focusedBorderWidth,
    super.borderRadius,
    super.doubleBorderColor,
    super.doubleFocusedBorderColor,
    super.doubleErrorBorderColor,
    super.doubleBorderWidth,
    super.doubleBorderRadius,
    super.showDoubleBorderOnFocus,
    super.showDoubleBorderOnError,
    super.contentPadding,
    super.descriptionSpacing,
    super.supportingTextSpacing,
    super.hintTextDirection,
    super.hintMaxLines,
    super.textAlign,
    super.textAlignVertical,
    super.containerHeight,
    this.resultsMaxHeight = 200,
    this.resultsDecoration,
    this.shouldShowDivider = false,
    this.divider,
    this.resultSeparation = 4,
  });
}
