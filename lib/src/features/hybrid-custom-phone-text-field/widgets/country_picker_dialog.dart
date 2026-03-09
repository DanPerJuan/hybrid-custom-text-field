import 'package:flutter/material.dart';

import '../../../models/entities/country_entity.dart';
import '../../../theme/country_picker_dialog_theme.dart';

/// A dialog that allows users to pick a country from a list.
///
/// Includes:
/// - A search bar to filter countries by name or dial code.
/// - Displays country flag, name, and dial code in a list.
/// - Returns the selected country via [onCountryChanged].
class CountryPickerDialog extends StatefulWidget {
  /// Full list of available countries.
  final List<CountryEntity> countryList;

  /// The currently selected country.
  final CountryEntity selectedCountry;

  /// Callback triggered when a country is selected.
  final ValueChanged<CountryEntity> onCountryChanged;

  /// List of filtered countries. Initially displayed in the dialog.
  final List<CountryEntity> filteredCountries;

  /// Optional custom input decoration for the search field.
  final InputDecoration? searchFieldInputDecoration;

  /// Title displayed at the top of the dialog.
  final String dialogTitle;

  final CountryPickerDialogTheme style;

  /// Creates a country picker dialog.
  const CountryPickerDialog({
    super.key,
    required this.countryList,
    required this.onCountryChanged,
    required this.selectedCountry,
    required this.filteredCountries,
    this.searchFieldInputDecoration,
    required this.dialogTitle,
    required this.style,
  });

  @override
  _CountryPickerDialogState createState() => _CountryPickerDialogState();
}

/// State of the [CountryPickerDialog].
///
/// Handles:
/// - Filtering countries based on search input.
/// - Maintaining currently selected country.
class _CountryPickerDialogState extends State<CountryPickerDialog> {
  /// List of countries filtered by search input.
  late List<CountryEntity> _filteredCountries;

  /// Currently selected country.
  late CountryEntity _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.selectedCountry;
    _filteredCountries = widget.filteredCountries;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: widget.style.alignment,
      insetPadding: widget.style.insetPadding,
      backgroundColor: widget.style.backgroundColor,
      elevation: widget.style.elevation,
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(
              widget.dialogTitle,
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            decoration: BoxDecoration(borderRadius: widget.style.searchStyle.borderRadius),
            padding: widget.style.searchStyle.outerPadding,
            child: TextField(
              style: widget.style.searchStyle.textStyle,
              decoration:
                  widget.searchFieldInputDecoration ??
                  InputDecoration(
                    border: widget.style.searchStyle.border,
                    suffixIcon: widget.style.searchStyle.suffixIcon,
                    hintText: 'Busca un país',
                    hintStyle: widget.style.searchStyle.hintStyle,
                    fillColor: widget.style.searchStyle.fillColor,
                    focusedBorder: widget.style.searchStyle.focusedBorder,
                    contentPadding: widget.style.searchStyle.contentPadding,
                  ),
              onChanged: (value) {
                _filteredCountries = value.trim().isEmpty
                    ? widget.countryList
                          .where(
                            (country) => country.dialCode.contains(value.trim()),
                          )
                          .toList()
                    : widget.countryList
                          .where(
                            (country) => country.name.toLowerCase().contains(value.toLowerCase().trim()),
                          )
                          .toList();

                if (mounted) setState(() {});
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredCountries.length,
              itemBuilder: (ctx, index) => ListTile(
                leading: Text(
                  _filteredCountries[index].flag,
                ),
                title: Text(
                  _filteredCountries[index].name,
                ),
                trailing: Text(
                  '+${_filteredCountries[index].dialCode}',
                ),

                /// When a country is tapped:
                /// - Update selected country
                /// - Trigger [onCountryChanged] callback
                /// - Close the dialog.
                onTap: () {
                  _selectedCountry = _filteredCountries[index];
                  widget.onCountryChanged(_selectedCountry);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
