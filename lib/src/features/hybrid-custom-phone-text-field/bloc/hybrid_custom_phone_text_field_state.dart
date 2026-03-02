part of 'hybrid_custom_phone_text_field_bloc.dart';

class HybridCustomPhoneTextFieldData {
  /// Whether the current field has a validation error.
  final bool hasError;

  /// Error message associated with the current validation failure (if any).
  final String? errorMessage;

  /// List of validation rules applied to the field.
  final List<ValidationTextFieldEntity> validations;

  /// List of all available countries (for phone fields).
  final List<CountryEntity> countries;

  /// List of countries filtered according to user input.
  final List<CountryEntity> filteredCountries;

  /// Currently selected country in a phone field.
  final CountryEntity selectedCountry;

  /// Constructor for initializing all the field data.
  HybridCustomPhoneTextFieldData({
    required this.hasError,
    required this.errorMessage,
    required this.validations,
    required this.countries,
    required this.filteredCountries,
    required this.selectedCountry,
  });

  /// Returns a copy of the current data with any modified fields replaced.
  HybridCustomPhoneTextFieldData copyWith({
    bool? hasError,
    ValueGetter<String?>? errorMessage,
    List<ValidationTextFieldEntity>? validations,
    List<CountryEntity>? countries,
    List<CountryEntity>? filteredCountries,
    CountryEntity? selectedCountry,
  }) {
    return HybridCustomPhoneTextFieldData(
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      validations: validations ?? this.validations,
      countries: countries ?? this.countries,
      filteredCountries: filteredCountries ?? this.filteredCountries,
      selectedCountry: selectedCountry ?? this.selectedCountry,
    );
  }
}

/// Base sealed state class for the HybridCustomPhoneTextFieldBloc.
/// Contains a [HybridCustomPhoneTextFieldData] object representing current state.
sealed class HybridCustomPhoneTextFieldState {
  final HybridCustomPhoneTextFieldData data;

  const HybridCustomPhoneTextFieldState({
    required this.data,
  });
}

/// Initial state of the text field, typically when the widget is first loaded.
final class HybridCustomPhoneTextFieldInitial extends HybridCustomPhoneTextFieldState {
  HybridCustomPhoneTextFieldInitial({
    required CountryEntity? selectedCountry,
  }) : super(
         data: HybridCustomPhoneTextFieldData(
           hasError: false,
           errorMessage: null,
           validations: [],
           countries: [],
           filteredCountries: [],
           selectedCountry: selectedCountry ?? CountriesHelper.countries.first,
         ),
       );
}

/// State representing an ongoing operation, like validating input or filtering results.
final class HybridCustomPhoneTextFieldInProgess extends HybridCustomPhoneTextFieldState {
  HybridCustomPhoneTextFieldInProgess({required super.data});
}

/// State representing a successful operation or update in the text field.
/// For example, after the input has been validated or search results updated.
final class HybridCustomPhoneTextFieldSuccess extends HybridCustomPhoneTextFieldState {
  HybridCustomPhoneTextFieldSuccess({required super.data});
}
