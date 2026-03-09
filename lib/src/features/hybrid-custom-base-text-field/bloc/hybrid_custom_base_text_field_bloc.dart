import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../../../models/configs/hybrid_text_field_config.dart';
import '../../../models/entities/validation_text_field_entity.dart';
import '../../../utils/validation_utils.dart';

part 'hybrid_custom_base_text_field_event.dart';
part 'hybrid_custom_base_text_field_state.dart';

class HybridCustomBaseTextFieldBloc extends Bloc<HybridCustomBaseTextFieldEvent, HybridCustomBaseTextFieldState> {
  /// The config provided by the consumer. Used to derive validation rules and
  /// to read search-specific settings (e.g. sort order).
  final HybridTextFieldConfig _config;

  /// Creates a [HybridCustomBaseTextFieldBloc] with the given [config].
  ///
  /// The initial state is [HybridCustomBaseTextFieldInitial] with the first
  /// available country pre-selected (relevant only for the phone field).
  HybridCustomBaseTextFieldBloc({required HybridTextFieldConfig config})
    : _config = config,
      super(HybridCustomBaseTextFieldInitial()) {
    on<HybridCustomBaseTextFieldEvent>((event, emit) async {
      await switch (event) {
        HybridCustomBaseTextFieldStarted() => _onStarted(event, emit),
        HybridCustomBaseTextFieldChanged() => _onChanged(event, emit),
      };
    });
  }

  /// Initializes the base text field by loading all validation rules derived
  /// from the config via [ValidationUtils], then validates against the empty
  /// string so the form can know the correct initial error state without
  /// waiting for the first user keystroke.
  Future<void> _onStarted(
    HybridCustomBaseTextFieldStarted event,
    Emitter<HybridCustomBaseTextFieldState> emit,
  ) async {
    final validations = ValidationUtils().getAllValidations(_config);
    final hasError = validations.any((v) => !v.validate(''));
    final error = hasError ? validations.firstWhere((v) => !v.validate('')) : null;
    emit(
      HybridCustomBaseTextFieldSuccess(
        data: state.data.copyWith(
          validations: validations,
          hasError: hasError,
          errorMessage: () => error?.errorMessage,
        ),
      ),
    );
  }

  /// Runs all configured validation rules against the current value on every
  /// keystroke and updates [HybridCustomBaseTextFieldData.hasError] /
  /// [HybridCustomBaseTextFieldData.errorMessage] accordingly.
  Future<void> _onChanged(
    HybridCustomBaseTextFieldChanged event,
    Emitter<HybridCustomBaseTextFieldState> emit,
  ) async {
    final hasError = state.data.validations.any(
      (v) => !v.validate(event.value.trim()),
    );

    ValidationTextFieldEntity? error;
    if (hasError) {
      error = state.data.validations.firstWhere(
        (v) => !v.validate(event.value.trim()),
      );
    }

    emit(
      HybridCustomBaseTextFieldSuccess(
        data: state.data.copyWith(
          hasError: hasError,
          errorMessage: () => hasError ? error!.errorMessage : null,
        ),
      ),
    );
  }
}
