import 'package:flutter/material.dart';

import '../../models/entities/country_entity.dart';

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

  /// Optional text style for the search input field.
  final TextStyle? searchTextStyle;

  /// Background color of the dialog.
  final Color? dialogBackgroundColor;

  /// Creates a country picker dialog.
  const CountryPickerDialog({
    super.key,
    required this.countryList,
    required this.onCountryChanged,
    required this.selectedCountry,
    required this.filteredCountries,
    this.searchFieldInputDecoration,
    required this.dialogTitle,
    required this.searchTextStyle,
    this.dialogBackgroundColor,
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
      backgroundColor: widget.dialogBackgroundColor,
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(
              widget.dialogTitle,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              style: widget.searchTextStyle,
              decoration:
                  widget.searchFieldInputDecoration ??
                  InputDecoration(
                    suffixIcon: Icon(Icons.search),
                    hintText: 'Busca un país',
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
