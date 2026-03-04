import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import '../../../../hybrid_custom_text_field.dart';
import '../../../models/configs/hybrid_text_field_config.dart';
import '../../../utils/countries_helper.dart';
import '../../../utils/validation_utils.dart';
import '../../../validations/validation_constants.dart';

part 'hybrid_custom_phone_text_field_event.dart';
part 'hybrid_custom_phone_text_field_state.dart';

class HybridCustomPhoneTextFieldBloc extends Bloc<HybridCustomPhoneTextFieldEvent, HybridCustomPhoneTextFieldState> {
  /// The config provided by the consumer. Used to derive validation rules and
  /// to read search-specific settings (e.g. sort order).
  final HybridTextFieldConfig _config;

  final CountryEntity? selectedCountry;

  /// Creates a [HybridCustomTextFieldBloc] with the given [config].
  ///
  /// The initial state is [HybridCustomTextFieldInitial] with the first
  /// available country pre-selected (relevant only for the phone field).
  HybridCustomPhoneTextFieldBloc({required HybridTextFieldConfig config, this.selectedCountry})
    : _config = config,
      super(HybridCustomPhoneTextFieldInitial(selectedCountry: selectedCountry)) {
    on<HybridCustomPhoneTextFieldEvent>((event, emit) async {
      await switch (event) {
        HybridCustomPhoneTextFieldStarted() => _onStarted(event, emit),
        HybridCustomPhoneTextFieldChanged() => _onChanged(event, emit),
        HybridCustomPhoneTextFieldCountryChanged() => _onCountryChanged(event, emit),
        HybridCustomPhoneTextFieldCountrySearched() => _onCountrySearched(event, emit),
        HybridCustomPhoneTextFieldFormValidationsReceived() => _onFormValidationReceived(event, emit),
      };
    });
  }

  Future<void> _onStarted(
    HybridCustomPhoneTextFieldStarted event,
    Emitter<HybridCustomPhoneTextFieldState> emit,
  ) async {
    final validations = ValidationUtils().getAllValidations(_config);
    final countries = CountriesHelper.countries;

    if (event.selectedCountry != null) {
      validations.add(
        ValidationConstants.phone(
          min: event.selectedCountry!.minLength,
          max: event.selectedCountry!.maxLength,
        ),
      );

      emit(
        HybridCustomPhoneTextFieldSuccess(
          data: state.data.copyWith(
            validations: validations,
            countries: countries,
            selectedCountry: event.selectedCountry,
            filteredCountries: countries,
          ),
        ),
      );
      return;
    }

    validations.add(
      ValidationConstants.phone(
        min: state.data.selectedCountry.minLength,
        max: state.data.selectedCountry.maxLength,
      ),
    );

    emit(
      HybridCustomPhoneTextFieldSuccess(
        data: state.data.copyWith(
          validations: validations,
          countries: countries,
          filteredCountries: countries,
        ),
      ),
    );
  }

  Future<void> _onCountryChanged(
    HybridCustomPhoneTextFieldCountryChanged event,
    Emitter<HybridCustomPhoneTextFieldState> emit,
  ) async {
    final validations = [...state.data.validations];
    final validation = state.data.selectedCountry;

    // Remove the old phone length rule before adding the updated one.
    validations.removeWhere((v) => v.regex == RegExp('^[0-9]{${validation.minLength},${validation.maxLength}}\$'));

    validations.add(
      ValidationConstants.phone(
        min: event.country.minLength,
        max: event.country.maxLength,
      ),
    );

    emit(
      HybridCustomPhoneTextFieldSuccess(
        data: state.data.copyWith(selectedCountry: event.country, validations: validations),
      ),
    );
  }

  Future<void> _onCountrySearched(
    HybridCustomPhoneTextFieldCountrySearched event,
    Emitter<HybridCustomPhoneTextFieldState> emit,
  ) async {
    final List<CountryEntity> unSortcountryList = [...state.data.countries];
    unSortcountryList.sort((a, b) => a.name.compareTo(b.name));

    emit(
      HybridCustomPhoneTextFieldSuccess(
        data: state.data.copyWith(filteredCountries: unSortcountryList),
      ),
    );
  }

  /// Runs all configured validation rules against the current value on every
  /// keystroke and updates [HybridCustomPhoneTextFieldData.hasError] /
  /// [HybridCustomPhoneTextFieldData.errorMessage] accordingly.
  Future<void> _onChanged(
    HybridCustomPhoneTextFieldChanged event,
    Emitter<HybridCustomPhoneTextFieldState> emit,
  ) async {
    final hasError = state.data.validations.any((v) => !v.validate(event.value.trim()));

    ValidationTextFieldEntity? error;
    if (hasError) {
      error = state.data.validations.firstWhere((v) => !v.validate(event.value.trim()));
    }

    emit(
      HybridCustomPhoneTextFieldSuccess(
        data: state.data.copyWith(
          hasError: hasError,
          errorMessage: () => hasError ? error!.errorMessage : null,
        ),
      ),
    );
  }

  Future<void> _onFormValidationReceived(
    HybridCustomPhoneTextFieldFormValidationsReceived event,
    Emitter<HybridCustomPhoneTextFieldState> emit,
  ) async {
    final mergedValidations = [
      ...state.data.validations,
      ...event.mergedValidations,
    ];

    emit(
      HybridCustomPhoneTextFieldSuccess(
        data: state.data.copyWith(validations: mergedValidations),
      ),
    );
  }
}
