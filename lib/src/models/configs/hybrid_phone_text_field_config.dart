import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../entities/country_entity.dart';
import '../entities/validation_text_field_entity.dart';
import 'hybrid_base_text_field_config.dart';

/// Configuration for [HybridCustomPhoneTextField].
///
/// ### Global params (inheritable via [HybridTextField.phoneConfig])
/// - [textInputAction] — keyboard action button
/// - [shouldDisplayErrorWhenClicked] — show errors only while focused
/// - [countryViewOptions] — how the selected country is displayed
/// - [showDialog] — dialog vs bottom sheet for the country picker
///
/// ### Per-field params
/// - [validations], [countries], [selectedCountry]
///
/// ### Validation
///
/// All validation rules are provided via [validations]. Use [ValidationConstants]
/// to build common rules:
/// ```dart
/// config: HybridPhoneTextFieldConfig(
///   validations: [ValidationConstants.isRequired()],
/// )
/// ```
///
/// > **Note on `copyWith`:** inherited base params that are not relevant to
/// > phone fields (`keyboardType`, `textCapitalization`, `singleLine`,
/// > `inputFormatters`, etc.) are accepted for Dart override compatibility
/// > but have no effect — they are not forwarded to the phone widget.
class HybridPhoneTextFieldConfig extends HybridBaseTextFieldConfig {
  // ── Phone global params (explicit* pattern) ────────────────────────────────

  final CountryViewOptions? explicitCountryViewOptions;
  final bool? explicitShowDialog;

  /// Controls how the selected country is shown in the prefix tap button.
  /// Defaults to [CountryViewOptions.countryCodeOnly].
  CountryViewOptions get countryViewOptions =>
      explicitCountryViewOptions ?? CountryViewOptions.countryCodeOnly;

  /// When `true`, the country picker opens as a [Dialog].
  /// When `false` (default), it opens as a modal bottom sheet.
  bool get showDialog => explicitShowDialog ?? false;

  // ── Phone per-field params ─────────────────────────────────────────────────

  /// Optional override of the full country list used in the prefix picker.
  final List<CountryEntity>? countries;

  /// Country pre-selected when the field mounts.
  final CountryEntity? selectedCountry;

  /// Creates a [HybridPhoneTextFieldConfig].
  ///
  /// Only exposes params that are relevant to the phone text field widget.
  HybridPhoneTextFieldConfig({
    // Base global params relevant to phone
    TextInputAction? textInputAction,
    bool? shouldDisplayErrorWhenClicked,
    // Base per-field params relevant to phone
    List<ValidationTextFieldEntity>? validations,
    // Phone global params
    CountryViewOptions? countryViewOptions,
    bool? showDialog,
    // Phone per-field params
    this.countries,
    this.selectedCountry,
  })  : explicitCountryViewOptions = countryViewOptions,
        explicitShowDialog = showDialog,
        super(
          textInputAction: textInputAction,
          shouldDisplayErrorWhenClicked: shouldDisplayErrorWhenClicked,
          validations: validations,
        );

  /// Merges [this] (global phone config) with [other] (widget-level config).
  ///
  /// Only propagates params that are relevant to the phone widget.
  @override
  HybridPhoneTextFieldConfig mergeWith(HybridBaseTextFieldConfig? other) {
    if (other == null) return this;
    final base = super.mergeWith(other);
    final otherPhone = other is HybridPhoneTextFieldConfig ? other : null;
    return HybridPhoneTextFieldConfig(
      // Base global (phone-relevant)
      textInputAction: base.explicitTextInputAction,
      shouldDisplayErrorWhenClicked: base.explicitShouldDisplayErrorWhenClicked,
      // Base per-field (phone-relevant, widget wins)
      validations: other.validations,
      // Phone global (widget wins if set)
      countryViewOptions: otherPhone?.explicitCountryViewOptions ?? explicitCountryViewOptions,
      showDialog: otherPhone?.explicitShowDialog ?? explicitShowDialog,
      // Phone per-field (widget wins)
      countries: otherPhone?.countries ?? countries,
      selectedCountry: otherPhone?.selectedCountry ?? selectedCountry,
    );
  }

  /// Returns a copy of this config with the given fields replaced.
  ///
  /// Params from the base class that are not relevant to the phone widget
  /// (`keyboardType`, `textCapitalization`, `singleLine`, `inputFormatters`,
  /// `passwordVisibleImage`, `passwordHiddenImage`, `dateFormatterType`,
  /// `minLines`, `maxLines`) are accepted for Dart override compatibility
  /// but have no effect.
  @override
  HybridPhoneTextFieldConfig copyWith({
    // Base global — phone-relevant
    TextInputAction? textInputAction,
    bool? shouldDisplayErrorWhenClicked,
    // Base global — accepted for override compat., not forwarded
    TextCapitalization? textCapitalization,
    TextInputType? keyboardType,
    // Base per-field — phone-relevant
    List<ValidationTextFieldEntity>? validations,
    // Base per-field — accepted for override compat., not forwarded
    bool? singleLine,
    int? minLines,
    int? maxLines,
    List<TextInputFormatter>? inputFormatters,
    Widget? passwordVisibleImage,
    Widget? passwordHiddenImage,
    HybridTextFieldFormatterDateType? dateFormatterType,
    // Phone-specific
    CountryViewOptions? countryViewOptions,
    bool? showDialog,
    List<CountryEntity>? countries,
    CountryEntity? selectedCountry,
  }) {
    return HybridPhoneTextFieldConfig(
      textInputAction: textInputAction ?? explicitTextInputAction,
      shouldDisplayErrorWhenClicked:
          shouldDisplayErrorWhenClicked ?? explicitShouldDisplayErrorWhenClicked,
      validations: validations ?? this.validations,
      countryViewOptions: countryViewOptions ?? explicitCountryViewOptions,
      showDialog: showDialog ?? explicitShowDialog,
      countries: countries ?? this.countries,
      selectedCountry: selectedCountry ?? this.selectedCountry,
    );
  }
}

/// Controls how the selected country is displayed in the prefix button.
/// - [countryCodeOnly] — e.g. `+34` (default)
/// - [countryNameOnly] — e.g. `Spain`
/// - [countryFlagOnly] — e.g. `🇪🇸`
/// - [countryCodeWithFlag] — e.g. `🇪🇸 +34`
/// - [countryNameWithFlag] — e.g. `🇪🇸 Spain`
enum CountryViewOptions {
  countryNameOnly,
  countryNameWithFlag,
  countryCodeOnly,
  countryCodeWithFlag,
  countryFlagOnly,
}
