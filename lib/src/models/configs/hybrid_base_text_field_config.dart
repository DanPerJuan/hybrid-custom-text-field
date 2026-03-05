import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../entities/validation_text_field_entity.dart';
import 'hybrid_text_field_config.dart';

/// Configuration for [HybridCustomBaseTextField].
///
/// Encapsulates all keyboard behaviour, validation rules and text-display
/// options for a generic single- or multi-line text field.
class HybridBaseTextFieldConfig extends HybridTextFieldConfig {
  /// {@macro HybridTextFieldConfig.textInputAction}
  @override
  final TextInputAction textInputAction;

  /// {@macro HybridTextFieldConfig.maxLength}
  @override
  final int? maxLength;

  /// {@macro HybridTextFieldConfig.minLength}
  @override
  final int? minLength;

  /// {@macro HybridTextFieldConfig.isRequired}
  @override
  final bool isRequired;

  /// {@macro HybridTextFieldConfig.shouldDisplayErrorWhenClicked}
  @override
  final bool shouldDisplayErrorWhenClicked;

  /// {@macro HybridTextFieldConfig.validations}
  @override
  final List<ValidationTextFieldEntity>? validations;

  /// When `true`, the field collapses to a single line and [minLines] /
  /// [maxLines] are ignored. Defaults to `true`.
  final bool singleLine;

  /// Minimum number of visible lines when [singleLine] is `false`.
  ///
  /// The field will grow vertically until it reaches [maxLines].
  final int minLines;

  /// Maximum number of visible lines when [singleLine] is `false`.
  ///
  /// Content beyond this limit becomes scrollable.
  final int maxLines;

  /// Optional list of [TextInputFormatter]s applied to every character the
  /// user types. Useful for restricting input to digits, currency formats, etc.
  final List<TextInputFormatter>? inputFormatters;

  /// When `true`, the field renders each character as a bullet (•) and a
  /// visibility-toggle icon is shown in the suffix slot.
  ///
  /// Use this for password fields.
  final bool obscureText;

  /// Soft keyboard type presented when the field is focused.
  ///
  /// Defaults to [TextInputType.text]. Use [TextInputType.emailAddress],
  /// [TextInputType.number], etc. to optimise the keyboard layout for the
  /// expected input.
  final TextInputType keyboardType;

  /// Controls how the OS auto-capitalizes text as the user types.
  ///
  /// Defaults to [TextCapitalization.none].
  final TextCapitalization textCapitalization;

  /// Optional custom widget shown when [isPassword] is `true` and the text
  /// is currently **visible**.
  ///
  /// Falls back to [Icons.visibility_outlined] when `null`.
  final Widget? passwordVisibleImage;

  /// Optional custom widget shown when [isPassword] is `true` and the text
  /// is currently **hidden**.
  ///
  /// Falls back to [Icons.visibility_off_outlined] when `null`.
  final Widget? passwordHiddenImage;

  /// Defines the built-in validation strategy applied to the text field.
  ///
  /// When provided, the corresponding validation rule is automatically
  /// added to the field’s validation pipeline.
  final HybridTextFieldValidationType? validationType;

  /// Defines the date formatting strategy applied to the text field input.
  ///
  /// When set, an appropriate input formatter is automatically attached
  /// to enforce the desired date structure (e.g. adding separators such as `/`
  /// and limiting character length).
  ///
  /// Add validations to the field to enforce the expected date format.
  final HybridTextFieldFormatterDateType? dateFormatterType;

  /// Creates a [HybridBaseTextFieldConfig].
  ///
  /// All parameters are optional and fall back to sensible defaults so the
  /// config can be used with zero configuration for simple cases.
  HybridBaseTextFieldConfig({
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.done,
    this.maxLength,
    this.singleLine = true,
    this.minLines = 1,
    this.maxLines = 1,
    this.inputFormatters,
    this.obscureText = false,
    this.isRequired = false,
    this.minLength,
    this.validations,
    this.shouldDisplayErrorWhenClicked = false,
    this.passwordVisibleImage,
    this.passwordHiddenImage,
    this.validationType,
    this.dateFormatterType,
  });

  /// Returns a copy of this config with the given fields replaced.
  ///
  /// Fields not passed to [copyWith] keep their current values.
  HybridBaseTextFieldConfig copyWith({
    TextInputType? keyboardType,
    TextCapitalization? textCapitalization,
    TextInputAction? textInputAction,
    int? maxLength,
    bool? singleLine,
    int? minLines,
    int? maxLines,
    List<TextInputFormatter>? inputFormatters,
    bool? obscureText,
    bool? isRequired,
    int? minLength,
    List<ValidationTextFieldEntity>? validations,
    bool? shouldDisplayErrorWhenClicked,
    Widget? passwordVisibleImage,
    Widget? passwordHiddenImage,
    HybridTextFieldValidationType? validationType,
    HybridTextFieldFormatterDateType? dateFormatterType,
  }) {
    return HybridBaseTextFieldConfig(
      keyboardType: keyboardType ?? this.keyboardType,
      textCapitalization: textCapitalization ?? this.textCapitalization,
      textInputAction: textInputAction ?? this.textInputAction,
      maxLength: maxLength ?? this.maxLength,
      singleLine: singleLine ?? this.singleLine,
      minLines: minLines ?? this.minLines,
      maxLines: maxLines ?? this.maxLines,
      inputFormatters: inputFormatters ?? this.inputFormatters,
      obscureText: obscureText ?? this.obscureText,
      isRequired: isRequired ?? this.isRequired,
      minLength: minLength ?? this.minLength,
      validations: validations ?? this.validations,
      shouldDisplayErrorWhenClicked: shouldDisplayErrorWhenClicked ?? this.shouldDisplayErrorWhenClicked,
      passwordVisibleImage: passwordVisibleImage ?? this.passwordVisibleImage,
      passwordHiddenImage: passwordHiddenImage ?? this.passwordHiddenImage,
      validationType: validationType ?? this.validationType,
      dateFormatterType: dateFormatterType ?? this.dateFormatterType,
    );
  }
}

/// Built-in validation types supported by the base text field.
///
/// Each value corresponds to a predefined validation rule:
/// - [email]: Valid email format validation.
/// - [url]: Valid URL format validation.
/// - [dni]: DNI-like format requiring specific constraints.
/// - [creditCard]: Numeric credit card format validation.
enum HybridTextFieldValidationType {
  email,
  url,
  dni,
  creditCard,
}

/// Supported date formatting strategies for the text field.
///
/// Each type automatically applies an input formatter that enforces
/// a specific date structure:
///
/// - [mmyy]: Formats input as `MM/YY`.
/// - [mmyyyy]: Formats input as `MM/YYYY`.
/// - [ddmmyyyy]: Formats input as `DD/MM/YYYY`.
///
/// These formatters control visual structure only. Additional
/// validation rules may be required to ensure logical date correctness.
enum HybridTextFieldFormatterDateType {
  mmyy,
  mmyyyy,
  ddmmyyyy,
}
