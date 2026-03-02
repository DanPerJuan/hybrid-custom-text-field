import 'package:flutter/material.dart';

import '../../../../hybrid_custom_text_field.dart';

/// A selectable list of phone prefixes displayed using radio buttons.
///
/// This widget is typically used inside a modal or bottom sheet
/// to allow the user to select a country phone prefix.
///
/// What each row displays is controlled by [CustomPrefixesListStyle.countryViewOptions],
/// which uses the same [CountryViewOptions] enum that drives the prefix button
/// in [HybridCustomPhoneTextField]. This keeps the picker consistent with
/// however the field is configured.
///

class CustomPhonePrefixesList extends StatelessWidget {
  /// List of available countries to display.
  final List<CountryEntity> countries;

  /// Currently selected prefix. Used as the [RadioGroup] value.
  final CountryEntity? selectedPrefix;

  /// Callback triggered when a prefix is selected.
  final Function(CountryEntity)? onPrefixSelected;

  /// Visual style overrides. All fields are optional — when `null`, the
  /// original defaults are preserved.
  final CustomPrefixesListStyle style;

  final HybridPhoneTextFieldConfig config;

  /// Creates a phone prefixes selection list.
  const CustomPhonePrefixesList({
    super.key,
    required this.countries,
    this.selectedPrefix,
    this.onPrefixSelected,
    required this.style,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: style.backgroundColor,
      child: RadioGroup<CountryEntity>(
        groupValue: selectedPrefix,
        onChanged: (value) {
          if (value != null) {
            onPrefixSelected?.call(value);
            Navigator.pop<CountryEntity>(context);
          }
        },
        child: ListView.builder(
          itemCount: countries.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final country = countries[index];

            return Column(
              children: [
                RadioListTile<CountryEntity>(
                  contentPadding: style.contentPadding,
                  title: Text(
                    buttonResult(
                      countryViewOptions: config.countryViewOptions,
                      selectedCountry: country,
                    ),
                    style: style.nameStyle,
                  ),
                  value: country,
                  radioScaleFactor: style.radioScaleFactor,
                  controlAffinity: style.radioAffinity,
                  visualDensity: style.visualDensity,
                  radioSide: BorderSide(
                    width: style.radioBorderWidth,
                    color: style.radioBorderColor,
                  ),
                  fillColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return style.radioSelectedColor;
                    }
                    return style.radioColor;
                  }),
                ),
                if (style.showDivider)
                  Divider(
                    indent: style.dividerIndent,
                    endIndent: style.dividerEndIndent,
                    height: 0,
                    thickness: style.dividerThickness,
                    color: style.dividerColor,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Builds the tile title driven by [CustomPrefixesListStyle.countryViewOptions].
  ///
  /// Each [CountryViewOptions] value maps to a different layout:
  /// - `countryCodeOnly`    → `+34`
  /// - `countryNameOnly`    → `Spain`
  /// - `countryFlagOnly`    → `🇪🇸`
  /// - `countryCodeWithFlag`→ `🇪🇸  +34`
  /// - `countryNameWithFlag`→ `🇪🇸  Spain`
  String buttonResult({
    required CountryViewOptions countryViewOptions,
    required CountryEntity selectedCountry,
  }) {
    switch (countryViewOptions) {
      case CountryViewOptions.countryCodeOnly:
        return '+${selectedCountry.dialCode}';
      case CountryViewOptions.countryNameOnly:
        return selectedCountry.name;
      case CountryViewOptions.countryFlagOnly:
        return selectedCountry.flag;
      case CountryViewOptions.countryCodeWithFlag:
        return '${selectedCountry.flag} +${selectedCountry.dialCode}';
      case CountryViewOptions.countryNameWithFlag:
        return '${selectedCountry.flag} ${selectedCountry.name}';
    }
  }
}
