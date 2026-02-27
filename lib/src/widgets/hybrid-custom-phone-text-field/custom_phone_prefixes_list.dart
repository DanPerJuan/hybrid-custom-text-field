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
                contentPadding: EdgeInsets.only(left: 16, right: 8),
                title: Text(
                  "${country.flag} - ${country.name} - +${country.dialCode}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                value: country,
                radioScaleFactor: 1.4,
                controlAffinity: ListTileControlAffinity.trailing,
                visualDensity: VisualDensity.compact,
                radioSide: BorderSide(
                  width: 1.5,
                  color: Colors.black54,
                ),
                fillColor: WidgetStateProperty.all(Colors.black54),
              ),
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
