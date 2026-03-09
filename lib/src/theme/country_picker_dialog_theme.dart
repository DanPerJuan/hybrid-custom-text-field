import 'package:flutter/material.dart';

/// Defines the visual appearance of [CountryPickerDialog].
class CountryPickerDialogTheme {
  /// Background color of the dialog surface.
  final Color backgroundColor;

  /// Elevation of the dialog surface.
  final double elevation;

  /// Padding applied inside the dialog around all its children.
  final EdgeInsets insetPadding;

  /// Text style for the dialog title.
  final TextStyle titleStyle;

  /// Text alignment for the dialog title. Defaults to [TextAlign.center].
  final TextAlign titleAlignment;

  /// Style for the search field.
  final CountryPickerSearchTheme searchStyle;

  /// Alignment of the embedded [CustomPhonePrefixesList].
  final AlignmentGeometry alignment;

  const CountryPickerDialogTheme({
    this.backgroundColor = Colors.white,
    this.elevation = 0,
    this.insetPadding = const EdgeInsets.all(30),
    this.titleStyle = const TextStyle(fontSize: 14),
    this.titleAlignment = TextAlign.center,
    this.searchStyle = const CountryPickerSearchTheme(),
    this.alignment = Alignment.center,
  });

  CountryPickerDialogTheme copyWith({
    Color? backgroundColor,
    double? elevation,
    EdgeInsets? insetPadding,
    TextStyle? titleStyle,
    TextAlign? titleAlignment,
    CountryPickerSearchTheme? searchStyle,
  }) {
    return CountryPickerDialogTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      elevation: elevation ?? this.elevation,
      insetPadding: insetPadding ?? this.insetPadding,
      titleStyle: titleStyle ?? this.titleStyle,
      titleAlignment: titleAlignment ?? this.titleAlignment,
      searchStyle: searchStyle ?? this.searchStyle,
    );
  }
}

/// Styling options for the search [TextField] inside [CountryPickerDialog].
class CountryPickerSearchTheme {
  /// Style of the hint text.
  final TextStyle hintStyle;

  /// Style of the typed text inside the search field.
  final TextStyle textStyle;

  /// Fill color of the search field.
  final Color fillColor;

  /// Border radius of the search field container.
  final BorderRadius borderRadius;

  /// Border shown when the field is not focused.
  final InputBorder border;

  /// Border shown when the field is focused.
  final InputBorder focusedBorder;

  /// Padding applied inside the search field.
  final EdgeInsetsGeometry contentPadding;

  /// Icon shown inside the search field.
  final Widget suffixIcon;

  /// Padding around the entire search field widget.
  final EdgeInsetsGeometry outerPadding;

  const CountryPickerSearchTheme({
    this.hintStyle = const TextStyle(fontSize: 14),
    this.textStyle = const TextStyle(fontSize: 14),
    this.fillColor = Colors.white,
    this.borderRadius = BorderRadius.zero,
    this.border = const UnderlineInputBorder(),
    this.focusedBorder = const OutlineInputBorder(),
    this.contentPadding = const EdgeInsets.all(10),
    this.suffixIcon = const Icon(Icons.search),
    this.outerPadding = const EdgeInsets.all(10),
  });

  CountryPickerSearchTheme copyWith({
    TextStyle? hintStyle,
    TextStyle? textStyle,
    Color? fillColor,
    BorderRadius? borderRadius,
    InputBorder? border,
    InputBorder? focusedBorder,
    EdgeInsetsGeometry? contentPadding,
    Widget? suffixIcon,
    EdgeInsetsGeometry? outerPadding,
  }) {
    return CountryPickerSearchTheme(
      hintStyle: hintStyle ?? this.hintStyle,
      textStyle: textStyle ?? this.textStyle,
      fillColor: fillColor ?? this.fillColor,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      focusedBorder: focusedBorder ?? this.focusedBorder,
      contentPadding: contentPadding ?? this.contentPadding,
      suffixIcon: suffixIcon ?? this.suffixIcon,
      outerPadding: outerPadding ?? this.outerPadding,
    );
  }
}
