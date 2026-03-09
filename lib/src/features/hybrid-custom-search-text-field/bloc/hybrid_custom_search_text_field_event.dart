part of 'hybrid_custom_search_text_field_bloc.dart';

sealed class HybridCustomSearchTextFieldEvent {}

/// Event triggered when a search-enabled text field is initialized with a list of items.
class HybridCustomSearchTextFieldStarted extends HybridCustomSearchTextFieldEvent {
  final List<dynamic> items;

  HybridCustomSearchTextFieldStarted({
    required this.items,
  });
}

/// Event triggered when the user changes the text in a search-enabled field.
/// Uses [displayedText] to extract the display string for each item.
class HybridCustomSearchTextFieldChanged extends HybridCustomSearchTextFieldEvent {
  final String value;
  String Function(dynamic item) displayedText;

  HybridCustomSearchTextFieldChanged({
    required this.value,
    required this.displayedText,
  });
}

/// Event triggered when the user taps the search field to show results.
/// Can optionally sort using [sortOrder] and [sortValue], and uses [displayedText] to display items.
class HybridCustomSearchTextFieldTapped extends HybridCustomSearchTextFieldEvent {
  String Function(dynamic item) displayedText;

  HybridCustomSearchTextFieldTapped({
    required this.displayedText,
  });
}

/// Event triggered when the user selects an item from a search result.
class HybridCustomSearchTextFieldItemSelected extends HybridCustomSearchTextFieldEvent {
  final dynamic item;

  HybridCustomSearchTextFieldItemSelected({required this.item});
}

/// Event triggered when the search overlay is dismissed.
class HybridCustomSearchTextFieldDismissed extends HybridCustomSearchTextFieldEvent {}
