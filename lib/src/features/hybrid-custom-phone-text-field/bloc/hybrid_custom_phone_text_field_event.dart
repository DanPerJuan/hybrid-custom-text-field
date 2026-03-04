part of 'hybrid_custom_phone_text_field_bloc.dart';

sealed class HybridCustomPhoneTextFieldEvent {}

/// Event triggered when a phone text field is initialized, optionally with a selected country.
class HybridCustomPhoneTextFieldStarted extends HybridCustomPhoneTextFieldEvent {
  final CountryEntity? selectedCountry;

  HybridCustomPhoneTextFieldStarted({
    this.selectedCountry,
  });
}

/// Event triggered whenever the user changes the text in the field.
class HybridCustomPhoneTextFieldChanged extends HybridCustomPhoneTextFieldEvent {
  final String value;

  HybridCustomPhoneTextFieldChanged({required this.value});
}

/// Event triggered when the user selects a new country in a phone text field.
class HybridCustomPhoneTextFieldCountryChanged extends HybridCustomPhoneTextFieldEvent {
  final CountryEntity country;

  HybridCustomPhoneTextFieldCountryChanged({required this.country});
}

/// Event triggered when the user searches for a country by typing.
class HybridCustomPhoneTextFieldCountrySearched extends HybridCustomPhoneTextFieldEvent {
  final String value;

  HybridCustomPhoneTextFieldCountrySearched({required this.value});
}

/// Fired when [HybridCustomTextFieldFormBloc] responds with the merged
/// validation list for this field.
///
/// The field bloc replaces its current validation list with [mergedValidations]
/// so form-level rules are active from the first keystroke onwards.
final class HybridCustomPhoneTextFieldFormValidationsReceived extends HybridCustomPhoneTextFieldEvent {
  final List<ValidationTextFieldEntity> mergedValidations;

  HybridCustomPhoneTextFieldFormValidationsReceived({required this.mergedValidations});
}
