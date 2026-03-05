import 'package:flutter/material.dart';

/// Defines the visual appearance of [CustomPhonePrefixesList].
///
/// All properties are optional — when `null`, the widget uses the values
/// hardcoded as defaults in the original implementation.
class CustomPrefixesListStyle {
  /// Background color of the list container.
  final Color backgroundColor;

  /// Style applied specifically to the country name.
  /// Only used when [countryViewOptions] includes the name part.
  final TextStyle nameStyle;

  /// Fill color of the radio button (both selected and unselected states).
  final Color radioColor;

  /// Fill color of the radio button when selected. When `null`, [radioColor]
  /// is used for both states.
  final Color radioSelectedColor;

  /// Border color of the radio button outline.
  final Color radioBorderColor;

  /// Border width of the radio button.
  final double radioBorderWidth;

  /// Scale factor applied to the radio button
  final double radioScaleFactor;

  /// Whether the radio button appears on the leading or trailing side.
  final ListTileControlAffinity radioAffinity;

  /// Padding applied to each [RadioListTile].
  final EdgeInsetsGeometry contentPadding;

  /// [VisualDensity] of each [RadioListTile].
  final VisualDensity visualDensity;

  /// Background color for the selected item tile.
  final Color selectedTileColor;

  /// Whether to show a [Divider] between items.
  final bool shouldShowDivider;

  /// Color of the divider between items.
  final Color dividerColor;

  /// Thickness of the divider in logical pixels
  final double dividerThickness;

  /// Left indent of the divider
  final double dividerIndent;

  /// Right indent of the divider
  final double dividerEndIndent;

  const CustomPrefixesListStyle({
    this.backgroundColor = Colors.white,
    this.nameStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    this.radioColor = Colors.black,
    this.radioBorderColor = Colors.black54,
    this.radioBorderWidth = 1.5,
    this.radioScaleFactor = 1.4,
    this.radioAffinity = ListTileControlAffinity.trailing,
    this.contentPadding = const EdgeInsets.only(left: 16, right: 8),
    this.visualDensity = VisualDensity.compact,
    this.selectedTileColor = Colors.black,
    this.shouldShowDivider = true,
    this.dividerColor = const Color.fromARGB(255, 206, 206, 206),
    this.dividerThickness = 0.5,
    this.dividerIndent = 16,
    this.dividerEndIndent = 16,
  }) : radioSelectedColor = radioColor;

  CustomPrefixesListStyle copyWith({
    Color? backgroundColor,
    TextStyle? itemTextStyle,
    TextStyle? flagStyle,
    TextStyle? nameStyle,
    TextStyle? dialCodeStyle,
    double? itemSpacing,
    Color? radioColor,
    Color? radioSelectedColor,
    Color? radioBorderColor,
    double? radioBorderWidth,
    double? radioScaleFactor,
    ListTileControlAffinity? radioAffinity,
    EdgeInsetsGeometry? contentPadding,
    VisualDensity? visualDensity,
    Color? selectedTileColor,
    bool? showDivider,
    Color? dividerColor,
    double? dividerThickness,
    double? dividerIndent,
    double? dividerEndIndent,
  }) {
    return CustomPrefixesListStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      nameStyle: nameStyle ?? this.nameStyle,
      radioColor: radioColor ?? this.radioColor,
      radioBorderColor: radioBorderColor ?? this.radioBorderColor,
      radioBorderWidth: radioBorderWidth ?? this.radioBorderWidth,
      radioScaleFactor: radioScaleFactor ?? this.radioScaleFactor,
      radioAffinity: radioAffinity ?? this.radioAffinity,
      contentPadding: contentPadding ?? this.contentPadding,
      visualDensity: visualDensity ?? this.visualDensity,
      selectedTileColor: selectedTileColor ?? this.selectedTileColor,
      shouldShowDivider: showDivider ?? this.shouldShowDivider,
      dividerColor: dividerColor ?? this.dividerColor,
      dividerThickness: dividerThickness ?? this.dividerThickness,
      dividerIndent: dividerIndent ?? this.dividerIndent,
      dividerEndIndent: dividerEndIndent ?? this.dividerEndIndent,
    );
  }
}
