import 'package:flutter/material.dart';

import '../../models/entities/country_entity.dart';

/// A selectable list of phone prefixes displayed using radio buttons.
///
/// This widget is typically used inside a modal or bottom sheet
/// to allow the user to select a country phone prefix.
///
/// Each item shows:
/// - Country flag
/// - Country name
/// - Dial code
///
/// When a prefix is selected:
/// 1. The [onPrefixSelected] callback is triggered.
/// 2. The current route is closed using Navigator.pop().
class CustomPhonePrefixesList extends StatelessWidget {
  /// List of available countries to display.
  final List<CountryEntity> countries;

  /// Currently selected prefix.
  ///
  /// Used as the RadioGroup value to highlight the selected item.
  final CountryEntity? selectedPrefix;

  /// Callback triggered when a prefix is selected.
  ///
  /// Returns the selected [CountryEntity].
  final Function(CountryEntity)? onPrefixSelected;

  /// Creates a phone prefixes selection list.
  const CustomPhonePrefixesList({
    super.key,
    required this.countries,
    this.selectedPrefix,
    this.onPrefixSelected,
  });

  @override
  Widget build(BuildContext context) {
    /// RadioGroup manages the selection state
    /// for all RadioListTile widgets inside it.
    return RadioGroup<CountryEntity>(
      /// Current selected value.
      groupValue: selectedPrefix,

      /// Triggered when user selects a different country.
      onChanged: (value) {
        if (value != null) {
          /// Notify parent widget about the selection.
          onPrefixSelected?.call(value);

          /// Close the current screen (usually a modal/bottom sheet)
          /// and optionally return the selected country.
          Navigator.pop<CountryEntity>(context);
        }
      },

      /// Scrollable list of countries.
      child: ListView.builder(
        /// Total number of items.
        itemCount: countries.length,

        /// Allows ListView to size itself based on content.
        /// Useful when placed inside dialogs or bottom sheets.
        shrinkWrap: true,

        /// Builds each country item.
        itemBuilder: (context, index) {
          /// Current country entity.
          final country = countries[index];

          return Column(
            children: [
              /// Radio tile representing a selectable country prefix.
              RadioListTile<CountryEntity>(
                /// Padding inside the tile.
                contentPadding: EdgeInsets.only(left: 16, right: 8),

                /// Display flag, name and dial code.
                title: Text(
                  "${country.flag} - ${country.name} - +${country.dialCode}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                /// Value associated with this radio option.
                value: country,

                /// Scales the radio button size.
                radioScaleFactor: 1.4,

                /// Places radio button on the right side.
                controlAffinity: ListTileControlAffinity.trailing,

                /// Reduces vertical spacing.
                visualDensity: VisualDensity.compact,

                /// Border style of the radio button.
                radioSide: BorderSide(
                  width: 1.5,
                  color: Colors.black54,
                ),

                /// Fill color of the radio when selected.
                fillColor: WidgetStateProperty.all(Colors.black54),
              ),

              /// Divider between list items.
              Divider(
                indent: 16,
                endIndent: 16,
                height: 0,
                thickness: 0.5,
              ),
            ],
          );
        },
      ),
    );
  }
}
