import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../../hybrid_custom_text_field.dart';
import '../models/configs/hybryd_text_field_config.dart';
import '../models/entities/validation_text_field_entity.dart';
import '../utils/countries_helper.dart';
import '../utils/validation_utils.dart';
import '../validations/validation_constants.dart';

part 'hybrid_custom_text_field_event.dart';
part 'hybrid_custom_text_field_state.dart';

/// Shared BLoC that manages the state for all `HybridCustomTextField` variants:
/// base, phone and search.
///
/// A single bloc implementation keeps validation logic centralized and avoids
/// duplication across field types. Each field variant fires a specific started
/// event ([HybridCustomTextFieldStarted], [HybridCustomTextFieldPhoneStarted],
/// [HybridCustomTextFieldSearchStarted]) that loads the relevant initial data
/// from the config.
///
/// ### Event → handler mapping
/// | Event | Handler | Description |
/// |---|---|---|
/// | [HybridCustomTextFieldStarted] | `_onStarted` | Loads validations for the base field. |
/// | [HybridCustomTextFieldPhoneStarted] | `_onPhoneStarted` | Loads validations + country list for the phone field. |
/// | [HybridCustomTextFieldSearchStarted] | `_onSearchStarted` | Loads the searchable item list. |
/// | [HybridCustomTextFieldChanged] | `_onChanged` | Runs validation on every keystroke (base & phone). |
/// | [HybridCustomTextFieldCountryChanged] | `_onCountryChanged` | Updates phone length validation when the user picks a new country prefix. |
/// | [HybridCustomTextFieldCountrySearched] | `_onCountrySearched` | Sorts the country list alphabetically for the picker. |
/// | [HybridCustomTextFieldSearchChanged] | `_onSearchChanged` | Filters the item list on every keystroke. |
/// | [HybridCustomTextFieldSearchTapped] | `_onSearchTapped` | Shows the results overlay, applying the configured sort. |
/// | [HybridCustomTextFieldItemSelected] | `_onItemSelected` | Closes the overlay after an item is selected. |
/// | [HybridCustomTextFieldSearchDismissed] | `_onSearchDismissed` | Hides the results overlay. |
class HybridCustomTextFieldBloc extends Bloc<HybridCustomTextFieldEvent, HybridCustomTextFieldState> {
  /// The config provided by the consumer. Used to derive validation rules and
  /// to read search-specific settings (e.g. sort order).
  final HybridTextFieldConfig _config;

  /// Creates a [HybridCustomTextFieldBloc] with the given [config].
  ///
  /// The initial state is [HybridCustomTextFieldInitial] with the first
  /// available country pre-selected (relevant only for the phone field).
  HybridCustomTextFieldBloc({required HybridTextFieldConfig config})
    : _config = config,
      super(HybridCustomTextFieldInitial(selectedCountry: CountriesHelper.countries.first)) {
    on<HybridCustomTextFieldEvent>((event, emit) async {
      await switch (event) {
        HybridCustomTextFieldStarted() => _onStarted(event, emit),
        HybridCustomTextFieldPhoneStarted() => _onPhoneStarted(event, emit),
        HybridCustomTextFieldChanged() => _onChanged(event, emit),
        HybridCustomTextFieldCountryChanged() => _onCountryChanged(event, emit),
        HybridCustomTextFieldCountrySearched() => _onCountrySearched(event, emit),
        HybridCustomTextFieldSearchChanged() => _onSearchChanged(event, emit),
        HybridCustomTextFieldItemSelected() => _onItemSelected(event, emit),
        HybridCustomTextFieldSearchDismissed() => _onSearchDismissed(event, emit),
        HybridCustomTextFieldSearchStarted() => _onSearchStarted(event, emit),
        HybridCustomTextFieldSearchTapped() => _onSearchTapped(event, emit),
      };
    });
  }

  // ── Base field ─────────────────────────────────────────────────────────────

  /// Initializes the base text field by loading all validation rules derived
  /// from the config via [ValidationUtils].
  Future<void> _onStarted(
    HybridCustomTextFieldStarted event,
    Emitter<HybridCustomTextFieldState> emit,
  ) async {
    final validations = ValidationUtils().getAllValidations(_config);
    emit(
      HybridCustomTextFieldSuccess(
        data: state.data.copyWith(validations: validations),
      ),
    );
  }

  // ── Phone field ────────────────────────────────────────────────────────────

  /// Initializes the phone field by loading validation rules and the full
  /// country list. If [HybridCustomTextFieldPhoneStarted.selectedCountry] is
  /// provided, it becomes the pre-selected prefix.
  Future<void> _onPhoneStarted(
    HybridCustomTextFieldPhoneStarted event,
    Emitter<HybridCustomTextFieldState> emit,
  ) async {
    final validations = ValidationUtils().getAllValidations(_config);
    final countries = CountriesHelper.countries;

    if (event.selectedCountry != null) {
      emit(
        HybridCustomTextFieldSuccess(
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

    emit(
      HybridCustomTextFieldSuccess(
        data: state.data.copyWith(
          validations: validations,
          countries: countries,
          filteredCountries: countries,
        ),
      ),
    );
  }

  // ── Search field ───────────────────────────────────────────────────────────

  /// Initializes the search field by storing the full item list in both
  /// [HybridCustomTextFieldData.allItems] (unchanged master copy) and
  /// [HybridCustomTextFieldData.filteredItems] (the list shown in the overlay).
  Future<void> _onSearchStarted(
    HybridCustomTextFieldSearchStarted event,
    Emitter<HybridCustomTextFieldState> emit,
  ) async {
    emit(
      HybridCustomTextFieldSuccess(
        data: state.data.copyWith(
          allItems: event.items,
          filteredItems: event.items,
        ),
      ),
    );
  }

  // ── Shared (base + phone) ──────────────────────────────────────────────────

  /// Runs all configured validation rules against the current value on every
  /// keystroke and updates [HybridCustomTextFieldData.hasError] /
  /// [HybridCustomTextFieldData.errorMessage] accordingly.
  ///
  /// Used by the base and phone fields. The search field uses
  /// [_onSearchChanged] instead.
  Future<void> _onChanged(
    HybridCustomTextFieldChanged event,
    Emitter<HybridCustomTextFieldState> emit,
  ) async {
    final hasError = state.data.validations.any((v) => !v.validate(event.value.trim()));

    ValidationTextFieldEntity? error;
    if (hasError) {
      error = state.data.validations.firstWhere((v) => !v.validate(event.value.trim()));
    }

    emit(
      HybridCustomTextFieldSuccess(
        data: state.data.copyWith(
          hasError: hasError,
          errorMessage: () => hasError ? error!.errorMessage : null,
        ),
      ),
    );
  }

  /// Updates the active phone validation rule when the user changes the
  /// country prefix.
  ///
  /// Removes any existing phone length rule and adds a new one whose min/max
  /// bounds are derived from the selected [CountryEntity].
  Future<void> _onCountryChanged(
    HybridCustomTextFieldCountryChanged event,
    Emitter<HybridCustomTextFieldState> emit,
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
      HybridCustomTextFieldSuccess(
        data: state.data.copyWith(selectedCountry: event.country, validations: validations),
      ),
    );
  }

  /// Sorts the country list alphabetically and stores the result in
  /// [HybridCustomTextFieldData.filteredCountries] for display in the picker.
  Future<void> _onCountrySearched(
    HybridCustomTextFieldCountrySearched event,
    Emitter<HybridCustomTextFieldState> emit,
  ) async {
    final List<CountryEntity> unSortcountryList = [...state.data.countries];
    unSortcountryList.sort((a, b) => a.name.compareTo(b.name));

    emit(
      HybridCustomTextFieldSuccess(
        data: state.data.copyWith(filteredCountries: unSortcountryList),
      ),
    );
  }

  // ── Search field handlers ──────────────────────────────────────────────────

  /// Filters [HybridCustomTextFieldData.allItems] on every keystroke using
  /// [HybridCustomTextFieldSearchChanged.displayText] as the string extractor.
  ///
  /// When the query is empty, the full list is restored. The overlay is kept
  /// visible ([showResults] = `true`) so the user sees results immediately
  /// while typing.
  ///
  /// Also runs validation rules and updates the error state.
  Future<void> _onSearchChanged(
    HybridCustomTextFieldSearchChanged event,
    Emitter<HybridCustomTextFieldState> emit,
  ) async {
    final hasError = state.data.validations.any((v) => !v.validate(event.value));

    ValidationTextFieldEntity? error;
    if (hasError) {
      error = state.data.validations.firstWhere((v) => !v.validate(event.value));
    }

    // Restore the full list when the field is cleared.
    if (event.value.isEmpty) {
      emit(
        HybridCustomTextFieldSuccess(
          data: state.data.copyWith(
            hasError: hasError,
            errorMessage: () => error?.errorMessage,
            filteredItems: state.data.allItems,
            showResults: true,
          ),
        ),
      );
      return;
    }

    final query = event.value.trim().toLowerCase();

    // Filter by checking whether the display string contains the query.
    final filtered = state.data.filteredItems
        .where((item) => event.displayText(item).toString().toLowerCase().contains(query))
        .toList();

    emit(
      HybridCustomTextFieldSuccess(
        data: state.data.copyWith(
          hasError: hasError,
          errorMessage: () => error?.errorMessage,
          filteredItems: filtered,
          showResults: true,
        ),
      ),
    );
  }

  /// Called when the user taps the field.
  ///
  /// Applies the configured [SearchSortOrder] to the current item list and
  /// sets [showResults] to `true` to trigger the overlay. If no sort is
  /// configured ([SearchSortOrder.none]), the list is shown in its original
  /// order without copying or re-sorting.
  Future<void> _onSearchTapped(
    HybridCustomTextFieldSearchTapped event,
    Emitter<HybridCustomTextFieldState> emit,
  ) async {
    // Determine whether any sort needs to be applied.
    final bool haveToOrder =
        event.sortOrder == SearchSortOrder.numericAscending && event.sortValue != null ||
        event.sortOrder == SearchSortOrder.numericDescending && event.sortValue != null ||
        event.sortOrder != SearchSortOrder.none;

    if (event.sortOrder == null || !haveToOrder) {
      // No sort — show the full list in its original order.
      emit(
        HybridCustomTextFieldSuccess(
          data: state.data.copyWith(
            filteredItems: [...state.data.allItems],
            showResults: state.data.allItems.isNotEmpty,
          ),
        ),
      );
      return;
    }

    // Sort and persist the result as the new master order so subsequent
    // filter operations are always performed against the sorted list.
    final filteredList = _applySort(
      state.data.allItems,
      event.sortOrder!,
      event.sortValue,
      event.displayText,
    );

    emit(
      HybridCustomTextFieldSuccess(
        data: state.data.copyWith(
          filteredItems: filteredList,
          allItems: filteredList,
          showResults: filteredList.isNotEmpty,
        ),
      ),
    );
  }

  /// Closes the results overlay after the user selects an item and clears
  /// any active validation error.
  Future<void> _onItemSelected(
    HybridCustomTextFieldItemSelected event,
    Emitter<HybridCustomTextFieldState> emit,
  ) async {
    emit(
      HybridCustomTextFieldSuccess(
        data: state.data.copyWith(
          showResults: false,
          hasError: false,
          errorMessage: () => null,
        ),
      ),
    );
  }

  /// Hides the results overlay without selecting any item.
  /// Dispatched when the user taps outside the field.
  Future<void> _onSearchDismissed(
    HybridCustomTextFieldSearchDismissed event,
    Emitter<HybridCustomTextFieldState> emit,
  ) async {
    emit(
      HybridCustomTextFieldSuccess(
        data: state.data.copyWith(showResults: false),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Returns a sorted copy of [list] according to [order].
  ///
  /// - [SearchSortOrder.none] → returns the list unchanged.
  /// - [SearchSortOrder.alphabetical] → A → Z using [displayText].
  /// - [SearchSortOrder.alphabeticalReverse] → Z → A using [displayText].
  /// - [SearchSortOrder.numericAscending] → smallest first using [sortValue].
  /// - [SearchSortOrder.numericDescending] → largest first using [sortValue].
  ///
  /// [sortValue] must be non-null for numeric orders; the assert in
  /// [HybridSearchTextFieldConfig] enforces this at construction time.
  List<dynamic> _applySort(
    List<dynamic> list,
    SearchSortOrder order,
    num Function(dynamic)? sortValue,
    String Function(dynamic item) displayText,
  ) {
    final sortedList = List<dynamic>.from(list);

    switch (order) {
      case SearchSortOrder.none:
        break;
      case SearchSortOrder.alphabetical:
        sortedList.sort(
          (a, b) => displayText(a).toString().compareTo(displayText(b)),
        );
        break;
      case SearchSortOrder.alphabeticalReverse:
        sortedList.sort(
          (a, b) => displayText(b).toString().compareTo(displayText(a)),
        );
        break;
      case SearchSortOrder.numericAscending:
        if (sortValue != null) {
          sortedList.sort((a, b) => sortValue(a).compareTo(sortValue(b)));
        }
        break;
      case SearchSortOrder.numericDescending:
        if (sortValue != null) {
          sortedList.sort((a, b) => sortValue(b).compareTo(sortValue(a)));
        }
        break;
    }

    return sortedList;
  }
}
