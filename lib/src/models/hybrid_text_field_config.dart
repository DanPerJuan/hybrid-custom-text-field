import 'package:flutter/services.dart';

class HybridTextFieldConfig {
  final TextInputType keyboardType;

  /// Text capitalization behaviour.
  final TextCapitalization textCapitalization;

  /// Action button on the keyboard (done, search, next, etc.).
  final TextInputAction textInputAction;

  /// Maximum number of characters allowed (hard limit).
  final int maxLength;

  /// When `true`, the field collapses to a single line.
  final bool singleLine;

  /// Minimum visible lines (only relevant when [singleLine] is `false`).
  final int minLines;

  /// Maximum visible lines (only relevant when [singleLine] is `false`).
  final int maxLines;

  /// Optional list of [TextInputFormatter]s applied to input.
  final List<TextInputFormatter>? inputFormatters;

  /// Whether the text is obscured (for passwords).
  final bool obscureText;

  static const int _defaultMaxLength = 999;

  const HybridTextFieldConfig({
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.done,
    this.maxLength = _defaultMaxLength,
    this.singleLine = true,
    this.minLines = 1,
    this.maxLines = 1,
    this.inputFormatters,
    this.obscureText = false,
  });

  HybridTextFieldConfig copyWith({
    TextInputType? keyboardType,
    TextCapitalization? textCapitalization,
    TextInputAction? textInputAction,
    int? maxLength,
    bool? singleLine,
    int? minLines,
    int? maxLines,
    List<TextInputFormatter>? inputFormatters,
    bool? obscureText,
  }) {
    return HybridTextFieldConfig(
      keyboardType: keyboardType ?? this.keyboardType,
      textCapitalization: textCapitalization ?? this.textCapitalization,
      textInputAction: textInputAction ?? this.textInputAction,
      maxLength: maxLength ?? this.maxLength,
      singleLine: singleLine ?? this.singleLine,
      minLines: minLines ?? this.minLines,
      maxLines: maxLines ?? this.maxLines,
      inputFormatters: inputFormatters ?? this.inputFormatters,
      obscureText: obscureText ?? this.obscureText,
    );
  }
}
