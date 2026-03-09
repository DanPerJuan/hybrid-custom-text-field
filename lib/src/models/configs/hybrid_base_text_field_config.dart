import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../entities/validation_text_field_entity.dart';
import 'hybrid_text_field_config.dart';

/// Configuration for [HybridCustomBaseTextField].
///
/// ### Global params (inheritable via [HybridTextField.baseConfig])
/// - [textInputAction] — keyboard action button
/// - [shouldDisplayErrorWhenClicked] — show errors only while focused
/// - [textCapitalization] — OS auto-capitalisation
/// - [keyboardType] — soft keyboard layout
///
/// ### Per-field params (always widget-level)
/// - [validations], [dateFormatterType], [singleLine], [minLines], [maxLines],
///   [inputFormatters], [passwordVisibleImage], [passwordHiddenImage]
///
/// ### Validation
///
/// All validation rules are provided via [validations]. Use [ValidationConstants]
/// to build common rules:
/// ```dart
/// config: HybridBaseTextFieldConfig(
///   validations: [
///     ValidationConstants.isRequired(),
///     ValidationConstants.email(),
///   ],
/// )
/// ```
class HybridBaseTextFieldConfig extends HybridTextFieldConfig {
  // ── Global params (explicit* pattern) ──────────────────────────────────────

  final TextInputAction? explicitTextInputAction;
  final bool? explicitShouldDisplayErrorWhenClicked;
  final TextCapitalization? explicitTextCapitalization;
  final TextInputType? explicitKeyboardType;

  @override
  TextInputAction get textInputAction => explicitTextInputAction ?? TextInputAction.done;

  @override
  bool get shouldDisplayErrorWhenClicked => explicitShouldDisplayErrorWhenClicked ?? false;

  TextCapitalization get textCapitalization => explicitTextCapitalization ?? TextCapitalization.none;

  TextInputType get keyboardType => explicitKeyboardType ?? TextInputType.text;

  // ── Per-field params ────────────────────────────────────────────────────────

  @override
  final List<ValidationTextFieldEntity>? validations;

  /// When `true`, the field collapses to a single line and [minLines] /
  /// [maxLines] are ignored. Defaults to `true`.
  ///
  /// This is always a per-field decision — it is not inheritable from global
  /// config.
  final bool singleLine;

  final int minLines;
  final int maxLines;

  final int? maxLength;

  final List<TextInputFormatter>? inputFormatters;
  final Widget? passwordVisibleImage;
  final Widget? passwordHiddenImage;

  /// When set, automatically applies the matching input formatter and adds the
  /// corresponding date validation rule.
  final HybridTextFieldFormatterDateType? dateFormatterType;

  HybridBaseTextFieldConfig({
    TextInputAction? textInputAction,
    TextCapitalization? textCapitalization,
    TextInputType? keyboardType,
    bool? shouldDisplayErrorWhenClicked,
    this.singleLine = true,
    this.minLines = 1,
    this.maxLines = 1,
    this.inputFormatters,
    this.validations,
    this.passwordVisibleImage,
    this.passwordHiddenImage,
    this.dateFormatterType,
    this.maxLength,
  }) : explicitTextInputAction = textInputAction,
       explicitTextCapitalization = textCapitalization,
       explicitKeyboardType = keyboardType,
       explicitShouldDisplayErrorWhenClicked = shouldDisplayErrorWhenClicked;

  /// Merges [this] (global config) with [other] (widget-level config).
  ///
  /// Global params: [other]'s explicit value wins when set, otherwise [this]
  /// keeps its value. Per-field params always come from [other].
  HybridBaseTextFieldConfig mergeWith(HybridBaseTextFieldConfig? other) {
    if (other == null) return this;
    return HybridBaseTextFieldConfig(
      textInputAction: other.explicitTextInputAction ?? explicitTextInputAction,
      shouldDisplayErrorWhenClicked:
          other.explicitShouldDisplayErrorWhenClicked ?? explicitShouldDisplayErrorWhenClicked,
      textCapitalization: other.explicitTextCapitalization ?? explicitTextCapitalization,
      keyboardType: other.explicitKeyboardType ?? explicitKeyboardType,
      // per-field: widget always wins
      singleLine: other.singleLine,
      validations: other.validations,
      dateFormatterType: other.dateFormatterType,
      minLines: other.minLines,
      maxLines: other.maxLines,
      inputFormatters: other.inputFormatters,
      passwordVisibleImage: other.passwordVisibleImage,
      passwordHiddenImage: other.passwordHiddenImage,
    );
  }

  HybridBaseTextFieldConfig copyWith({
    TextInputAction? textInputAction,
    TextCapitalization? textCapitalization,
    TextInputType? keyboardType,
    bool? singleLine,
    int? minLines,
    int? maxLines,
    List<TextInputFormatter>? inputFormatters,
    List<ValidationTextFieldEntity>? validations,
    bool? shouldDisplayErrorWhenClicked,
    Widget? passwordVisibleImage,
    Widget? passwordHiddenImage,
    HybridTextFieldFormatterDateType? dateFormatterType,
  }) {
    return HybridBaseTextFieldConfig(
      textInputAction: textInputAction ?? explicitTextInputAction,
      textCapitalization: textCapitalization ?? explicitTextCapitalization,
      keyboardType: keyboardType ?? explicitKeyboardType,
      shouldDisplayErrorWhenClicked: shouldDisplayErrorWhenClicked ?? explicitShouldDisplayErrorWhenClicked,
      singleLine: singleLine ?? this.singleLine,
      minLines: minLines ?? this.minLines,
      maxLines: maxLines ?? this.maxLines,
      inputFormatters: inputFormatters ?? this.inputFormatters,
      validations: validations ?? this.validations,
      passwordVisibleImage: passwordVisibleImage ?? this.passwordVisibleImage,
      passwordHiddenImage: passwordHiddenImage ?? this.passwordHiddenImage,
      dateFormatterType: dateFormatterType ?? this.dateFormatterType,
    );
  }
}

enum HybridTextFieldFormatterDateType { mmyy, mmyyyy, ddmmyyyy }
