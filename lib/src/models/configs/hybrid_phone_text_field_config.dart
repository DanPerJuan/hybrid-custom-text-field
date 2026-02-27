import 'package:flutter/material.dart';

import '../entities/validation_text_field_entity.dart';
import 'hybryd_text_field_config.dart';

/// Configuration for [HybridCustomPhoneTextField].
///
/// Extends [HybridTextFieldConfig] with phone-specific options such as how
/// the selected country is displayed in the prefix button.
///
/// ### Example
/// ```dart
/// HybridPhoneTextFieldConfig(
///   isRequired: true,
///   countryViewOptions: CountryViewOptions.countryCodeWithFlag,
///   shouldDisplayErrorWhenClicked: true,
/// )
/// ```
class HybridPhoneTextFieldConfig extends HybridTextFieldConfig {
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

  /// {@macro HybridTextFieldConfig.validations}
  @override
  final List<ValidationTextFieldEntity>? validations;

  /// {@macro HybridTextFieldConfig.shouldDisplayErrorWhenClicked}
  @override
  final bool shouldDisplayErrorWhenClicked;

  /// Controls how the selected country is shown in the prefix tap button.
  ///
  /// Available options are defined in [CountryViewOptions]:
  /// - [CountryViewOptions.countryCodeOnly] — e.g. `+34` (default)
  /// - [CountryViewOptions.countryNameOnly] — e.g. `Spain`
  /// - [CountryViewOptions.countryFlagOnly] — e.g. `🇪🇸`
  /// - [CountryViewOptions.countryCodeWithFlag] — e.g. `🇪🇸 +34`
  /// - [CountryViewOptions.countryNameWithFlag] — e.g. `🇪🇸 Spain`
  final CountryViewOptions countryViewOptions;

  /// When `true`, the country picker is presented as a [Dialog].
  /// When `false` (default), it is presented as a modal bottom sheet.
  final bool showDialog;

  /// Creates a [HybridPhoneTextFieldConfig].
  ///
  /// All parameters are optional. [countryViewOptions] defaults to
  /// [CountryViewOptions.countryCodeOnly].
  HybridPhoneTextFieldConfig({
    this.maxLength,
    this.minLength,
    this.countryViewOptions = CountryViewOptions.countryCodeOnly,
    this.isRequired = false,
    this.validations,
    this.shouldDisplayErrorWhenClicked = false,
    this.textInputAction = TextInputAction.done,
    this.showDialog = false,
  });

  /// Returns a copy of this config with the given fields replaced.
  ///
  /// Fields not passed to [copyWith] keep their current values.
  HybridPhoneTextFieldConfig copyWith({
    TextInputAction? textInputAction,
    int? maxLength,
    int? minLength,
    CountryViewOptions? countryViewOptions,
    bool? isRequired,
    List<ValidationTextFieldEntity>? validations,
    bool? shouldDisplayErrorWhenClicked,
    bool? showDialog,
  }) {
    return HybridPhoneTextFieldConfig(
      textInputAction: textInputAction ?? this.textInputAction,
      maxLength: maxLength ?? this.maxLength,
      minLength: minLength ?? this.minLength,
      countryViewOptions: countryViewOptions ?? this.countryViewOptions,
      isRequired: isRequired ?? this.isRequired,
      validations: validations ?? this.validations,
      shouldDisplayErrorWhenClicked: shouldDisplayErrorWhenClicked ?? this.shouldDisplayErrorWhenClicked,
      showDialog: showDialog ?? this.showDialog,
    );
  }
}

/// Style prefix options
/// - [CountryViewOptions.countryCodeOnly] — e.g. `+34` (default)
/// - [CountryViewOptions.countryNameOnly] — e.g. `Spain`
/// - [CountryViewOptions.countryFlagOnly] — e.g. `🇪🇸`
/// - [CountryViewOptions.countryCodeWithFlag] — e.g. `🇪🇸 +34`
/// - [CountryViewOptions.countryNameWithFlag] — e.g. `🇪🇸 Spain`
enum CountryViewOptions {
  countryNameOnly,
  countryNameWithFlag,
  countryCodeOnly,
  countryCodeWithFlag,
  countryFlagOnly,
}
