part of 'hybrid_custom_text_field_bloc.dart';

/// Holds all the data relevant to the current state of the HybridCustomTextField.
class HybridCustomTextFieldData {
  /// Whether the current field has a validation error.
  final bool hasError;

  /// Error message associated with the current validation failure (if any).
  final String? errorMessage;

  /// List of validation rules applied to the field.
  final List<ValidationTextFieldEntity> validations;

  // ── Phone-specific fields ────────────────────────────────────────────────

  /// List of all available countries (for phone fields).
  final List<CountryEntity> countries;

  /// List of countries filtered according to user input.
  final List<CountryEntity> filteredCountries;

  /// Currently selected country in a phone field.
  final CountryEntity selectedCountry;

  // ── Search-specific fields ──────────────────────────────────────────────

  /// Complete list of items in a search-enabled field.
  final List<dynamic> allItems;

  /// Filtered items after applying the search query.
  final List<dynamic> filteredItems;

  /// Whether the search results overlay should be shown.
  final bool showResults;

  /// Constructor for initializing all the field data.
  HybridCustomTextFieldData({
    required this.hasError,
    required this.errorMessage,
    required this.validations,
    required this.countries,
    required this.filteredCountries,
    required this.selectedCountry,
    required this.allItems,
    required this.filteredItems,
    required this.showResults,
  });

  /// Returns a copy of the current data with any modified fields replaced.
  HybridCustomTextFieldData copyWith({
    bool? hasError,
    ValueGetter<String?>? errorMessage,
    List<ValidationTextFieldEntity>? validations,
    List<CountryEntity>? countries,
    List<CountryEntity>? filteredCountries,
    CountryEntity? selectedCountry,
    List<dynamic>? allItems,
    List<dynamic>? filteredItems,
    bool? showResults,
  }) {
    return HybridCustomTextFieldData(
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      validations: validations ?? this.validations,
      countries: countries ?? this.countries,
      filteredCountries: filteredCountries ?? this.filteredCountries,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      allItems: allItems ?? this.allItems,
      filteredItems: filteredItems ?? this.filteredItems,
      showResults: showResults ?? this.showResults,
    );
  }
}

/// Base sealed state class for the HybridCustomTextFieldBloc.
/// Contains a [HybridCustomTextFieldData] object representing current state.
sealed class HybridCustomTextFieldState {
  final HybridCustomTextFieldData data;

  HybridCustomTextFieldState({required this.data});
}

/// Initial state of the text field, typically when the widget is first loaded.
final class HybridCustomTextFieldInitial extends HybridCustomTextFieldState {
  HybridCustomTextFieldInitial({required CountryEntity selectedCountry})
    : super(
        data: HybridCustomTextFieldData(
          hasError: false,
          errorMessage: null,
          validations: [],
          countries: [],
          filteredCountries: [],
          selectedCountry: CountriesHelper.countries.first, // Default selected country
          allItems: [],
          filteredItems: [],
          showResults: false,
        ),
      );
}

/// State representing an ongoing operation, like validating input or filtering results.
final class HybridCustomTextFieldInProgess extends HybridCustomTextFieldState {
  HybridCustomTextFieldInProgess({required super.data});
}

/// State representing a successful operation or update in the text field.
/// For example, after the input has been validated or search results updated.
final class HybridCustomTextFieldSuccess extends HybridCustomTextFieldState {
  HybridCustomTextFieldSuccess({required super.data});
}
