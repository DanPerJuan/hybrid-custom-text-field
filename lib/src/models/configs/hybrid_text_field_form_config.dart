import 'package:flutter/material.dart';

import '../entities/validation_text_field_entity.dart';
import 'hybrid_text_field_config.dart';

class HybridFormConfig extends HybridTextFieldConfig {
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

  /// Minimum number of visible lines when [singleLine] is `false`.
  ///
  /// The field will grow vertically until it reaches [maxLines].
  final int minLines;

  /// Maximum number of visible lines when [singleLine] is `false`.
  ///
  /// Content beyond this limit becomes scrollable.
  final int maxLines;

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

  HybridFormConfig({
    this.validations,
    this.isRequired = false,
    this.maxLines = 1,
    this.minLines = 1,
    this.maxLength,
    this.minLength,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.textCapitalization = TextCapitalization.none,
    this.shouldDisplayErrorWhenClicked = false,
  });

  HybridFormConfig copyWith({
    List<ValidationTextFieldEntity>? validations,
    bool? isRequired,
    int? maxLines,
    int? minLines,
    int? maxLength,
    int? minLength,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextCapitalization? textCapitalization,
    bool? shouldDisplayErrorWhenClicked,
  }) {
    return HybridFormConfig(
      validations: validations ?? this.validations,
      isRequired: isRequired ?? this.isRequired,
      maxLines: maxLines ?? this.maxLines,
      minLines: minLines ?? this.minLines,
      maxLength: maxLength ?? this.maxLength,
      minLength: minLength ?? this.minLength,
      keyboardType: keyboardType ?? this.keyboardType,
      textInputAction: textInputAction ?? this.textInputAction,
      textCapitalization: textCapitalization ?? this.textCapitalization,
      shouldDisplayErrorWhenClicked: shouldDisplayErrorWhenClicked ?? this.shouldDisplayErrorWhenClicked,
    );
  }
}
