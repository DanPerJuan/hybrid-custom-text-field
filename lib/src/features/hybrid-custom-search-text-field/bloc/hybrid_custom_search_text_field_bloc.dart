import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import '../../../../hybrid_custom_text_field.dart';
import '../../../models/configs/hybrid_text_field_config.dart';

part 'hybrid_custom_search_text_field_event.dart';
part 'hybrid_custom_search_text_field_state.dart';

class HybridCustomSearchTextFieldBloc extends Bloc<HybridCustomSearchTextFieldEvent, HybridCustomSearchTextFieldState> {
  /// The config provided by the consumer. Used to derive validation rules and
  /// to read search-specific settings (e.g. sort order).
  final HybridTextFieldConfig _config;

  /// Creates a [HybridCustomSearchTextFieldBloc] with the given [config].
  ///
  /// The initial state is [HybridCustomSearchTextFieldInitial] with the first
  /// available country pre-selected (relevant only for the phone field).

  HybridCustomSearchTextFieldBloc({required HybridTextFieldConfig config})
    : _config = config,
      super(HybridCustomSearchTextFieldInitial()) {
    on<HybridCustomSearchTextFieldEvent>((event, emit) async {
      await switch (event) {
        HybridCustomSearchTextFieldStarted() => _onStarted(event, emit),
        HybridCustomSearchTextFieldChanged() => _onChanged(event, emit),
        HybridCustomSearchTextFieldTapped() => _onTapped(event, emit),
        HybridCustomSearchTextFieldItemSelected() => _onItemSelected(event, emit),
        HybridCustomSearchTextFieldDismissed() => _onDismissed(event, emit),
        HybridCustomBaseTextFieldFormValidationsReceived() => _onFormValidationReceived(event, emit),
      };
    });
  }

  /// Initializes the search field by storing the full item list in both
  /// [HybridCustomSearchTextFieldData.allItems] (unchanged master copy) and
  /// [HybridCustomSearchTextFieldData.filteredItems] (the list shown in the overlay).
  Future<void> _onStarted(
    HybridCustomSearchTextFieldStarted event,
    Emitter<HybridCustomSearchTextFieldState> emit,
  ) async {
    emit(
      HybridCustomSearchTextFieldSuccess(
        data: state.data.copyWith(
          allItems: event.items,
          filteredItems: event.items,
        ),
      ),
    );
  }

  /// Filters [HybridCustomSearchTextFieldData.allItems] on every keystroke using
  /// [HybridCustomSearchTextFieldChanged.displayText] as the string extractor.
  ///
  /// When the query is empty, the full list is restored. The overlay is kept
  /// visible ([showResults] = `true`) so the user sees results immediately
  /// while typing.
  ///
  /// Also runs validation rules and updates the error state.
  Future<void> _onChanged(
    HybridCustomSearchTextFieldChanged event,
    Emitter<HybridCustomSearchTextFieldState> emit,
  ) async {
    final hasError = state.data.validations.any((v) => !v.validate(event.value));

    ValidationTextFieldEntity? error;
    if (hasError) {
      error = state.data.validations.firstWhere((v) => !v.validate(event.value));
    }

    // Restore the full list when the field is cleared.
    if (event.value.isEmpty) {
      emit(
        HybridCustomSearchTextFieldSuccess(
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
      HybridCustomSearchTextFieldSuccess(
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
  Future<void> _onTapped(
    HybridCustomSearchTextFieldTapped event,
    Emitter<HybridCustomSearchTextFieldState> emit,
  ) async {
    // Determine whether any sort needs to be applied.
    if (_config is HybridSearchTextFieldConfig) {
      final bool haveToOrder =
          _config.sortOrder == SearchSortOrder.numericAscending && _config.sortValue != null ||
          _config.sortOrder == SearchSortOrder.numericDescending && _config.sortValue != null ||
          _config.sortOrder != SearchSortOrder.none;

      if (!haveToOrder) {
        // No sort — show the full list in its original order.
        emit(
          HybridCustomSearchTextFieldSuccess(
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
        _config.sortOrder,
        _config.sortValue,
        event.displayText,
      );

      emit(
        HybridCustomSearchTextFieldSuccess(
          data: state.data.copyWith(
            filteredItems: filteredList,
            allItems: filteredList,
            showResults: filteredList.isNotEmpty,
          ),
        ),
      );
    }
  }

  /// Closes the results overlay after the user selects an item and clears
  /// any active validation error.
  Future<void> _onItemSelected(
    HybridCustomSearchTextFieldItemSelected event,
    Emitter<HybridCustomSearchTextFieldState> emit,
  ) async {
    emit(
      HybridCustomSearchTextFieldSuccess(
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
  Future<void> _onDismissed(
    HybridCustomSearchTextFieldDismissed event,
    Emitter<HybridCustomSearchTextFieldState> emit,
  ) async {
    emit(
      HybridCustomSearchTextFieldSuccess(
        data: state.data.copyWith(showResults: false),
      ),
    );
  }

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

  Future<void> _onFormValidationReceived(
    HybridCustomBaseTextFieldFormValidationsReceived event,
    Emitter<HybridCustomSearchTextFieldState> emit,
  ) async {
    final mergedValidations = [
      ...state.data.validations,
      ...event.mergedValidations,
    ];

    emit(
      HybridCustomSearchTextFieldSuccess(
        data: state.data.copyWith(validations: mergedValidations),
      ),
    );
  }
}
