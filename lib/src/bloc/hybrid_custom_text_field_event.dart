part of 'hybrid_custom_text_field_bloc.dart';

/// Base sealed class for all events handled by the HybridCustomTextFieldBloc.
sealed class HybridCustomTextFieldEvent {}

/// Event triggered when the basic text field is initialized.
class HybridCustomTextFieldStarted extends HybridCustomTextFieldEvent {}

/// Event triggered when a phone text field is initialized, optionally with a selected country.
class HybridCustomTextFieldPhoneStarted extends HybridCustomTextFieldEvent {
  final CountryEntity? selectedCountry;

  HybridCustomTextFieldPhoneStarted({
    this.selectedCountry,
  });
}

/// Event triggered when a search-enabled text field is initialized with a list of items.
class HybridCustomTextFieldSearchStarted extends HybridCustomTextFieldEvent {
  final List<dynamic> items;

  HybridCustomTextFieldSearchStarted({
    required this.items,
  });
}

/// Event triggered whenever the user changes the text in the field.
class HybridCustomTextFieldChanged extends HybridCustomTextFieldEvent {
  final String value;

  HybridCustomTextFieldChanged({required this.value});
}

/// Event triggered when the user selects a new country in a phone text field.
class HybridCustomTextFieldCountryChanged extends HybridCustomTextFieldEvent {
  final CountryEntity country;

  HybridCustomTextFieldCountryChanged({required this.country});
}

/// Event triggered when the user searches for a country by typing.
class HybridCustomTextFieldCountrySearched extends HybridCustomTextFieldEvent {
  final String value;

  HybridCustomTextFieldCountrySearched({required this.value});
}

/// Event triggered when the user changes the text in a search-enabled field.
/// Uses [displayText] to extract the display string for each item.
class HybridCustomTextFieldSearchChanged extends HybridCustomTextFieldEvent {
  final String value;
  String Function(dynamic item) displayText;

  HybridCustomTextFieldSearchChanged({
    required this.value,
    required this.displayText,
  });
}

/// Event triggered when the user taps the search field to show results.
/// Can optionally sort using [sortOrder] and [sortValue], and uses [displayText] to display items.
class HybridCustomTextFieldSearchTapped extends HybridCustomTextFieldEvent {
  final SearchSortOrder? sortOrder;
  final num Function(dynamic item)? sortValue;
  String Function(dynamic item) displayText;

  HybridCustomTextFieldSearchTapped({
    this.sortOrder,
    this.sortValue,
    required this.displayText,
  });
}

/// Event triggered when the user selects an item from a search result.
class HybridCustomTextFieldItemSelected extends HybridCustomTextFieldEvent {
  final dynamic item;

  HybridCustomTextFieldItemSelected({required this.item});
}

/// Event triggered when the search overlay is dismissed.
class HybridCustomTextFieldSearchDismissed extends HybridCustomTextFieldEvent {}
