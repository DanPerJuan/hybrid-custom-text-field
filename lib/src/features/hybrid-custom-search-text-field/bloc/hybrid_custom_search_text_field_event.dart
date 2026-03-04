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
/// Uses [displayText] to extract the display string for each item.
class HybridCustomSearchTextFieldChanged extends HybridCustomSearchTextFieldEvent {
  final String value;
  String Function(dynamic item) displayText;

  HybridCustomSearchTextFieldChanged({
    required this.value,
    required this.displayText,
  });
}

/// Event triggered when the user taps the search field to show results.
/// Can optionally sort using [sortOrder] and [sortValue], and uses [displayText] to display items.
class HybridCustomSearchTextFieldTapped extends HybridCustomSearchTextFieldEvent {
  String Function(dynamic item) displayText;

  HybridCustomSearchTextFieldTapped({
    required this.displayText,
  });
}

/// Event triggered when the user selects an item from a search result.
class HybridCustomSearchTextFieldItemSelected extends HybridCustomSearchTextFieldEvent {
  final dynamic item;

  HybridCustomSearchTextFieldItemSelected({required this.item});
}

/// Event triggered when the search overlay is dismissed.
class HybridCustomSearchTextFieldDismissed extends HybridCustomSearchTextFieldEvent {}

/// Fired when [HybridCustomTextFieldFormBloc] responds with the merged
/// validation list for this field.
///
/// The field bloc replaces its current validation list with [mergedValidations]
/// so form-level rules are active from the first keystroke onwards.
final class HybridCustomBaseTextFieldFormValidationsReceived extends HybridCustomSearchTextFieldEvent {
  final List<ValidationTextFieldEntity> mergedValidations;

  HybridCustomBaseTextFieldFormValidationsReceived({required this.mergedValidations});
}
