part of 'hybrid_custom_search_text_field_bloc.dart';

class HybridCustomSearchTextFieldData {
  /// Whether the current field has a validation error.
  final bool hasError;

  /// Error message associated with the current validation failure (if any).
  final String? errorMessage;

  /// List of validation rules applied to the field.
  final List<ValidationTextFieldEntity> validations;

  /// Complete list of items in a search-enabled field.
  final List<dynamic> allItems;

  /// Filtered items after applying the search query.
  final List<dynamic> filteredItems;

  /// Whether the search results overlay should be shown.
  final bool showResults;

  HybridCustomSearchTextFieldData({
    required this.hasError,
    required this.errorMessage,
    required this.validations,
    required this.allItems,
    required this.filteredItems,
    required this.showResults,
  });

  HybridCustomSearchTextFieldData copyWith({
    bool? hasError,
    ValueGetter<String?>? errorMessage,
    List<ValidationTextFieldEntity>? validations,
    List<dynamic>? allItems,
    List<dynamic>? filteredItems,
    bool? showResults,
  }) {
    return HybridCustomSearchTextFieldData(
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      validations: validations ?? this.validations,
      allItems: allItems ?? this.allItems,
      filteredItems: filteredItems ?? this.filteredItems,
      showResults: showResults ?? this.showResults,
    );
  }
}

sealed class HybridCustomSearchTextFieldState {
  final HybridCustomSearchTextFieldData data;

  const HybridCustomSearchTextFieldState({
    required this.data,
  });
}

final class HybridCustomSearchTextFieldInitial extends HybridCustomSearchTextFieldState {
  HybridCustomSearchTextFieldInitial()
    : super(
        data: HybridCustomSearchTextFieldData(
          hasError: false,
          errorMessage: null,
          validations: [],
          allItems: [],
          filteredItems: [],
          showResults: false,
        ),
      );
}

final class HybridCustomSearchTextFieldInProgess extends HybridCustomSearchTextFieldState {
  HybridCustomSearchTextFieldInProgess({required super.data});
}

final class HybridCustomSearchTextFieldSuccess extends HybridCustomSearchTextFieldState {
  HybridCustomSearchTextFieldSuccess({required super.data});
}
