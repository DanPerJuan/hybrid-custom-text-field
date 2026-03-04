import 'package:bloc/bloc.dart';

import '../../../../hybrid_custom_text_field.dart';
import '../../../models/configs/hybrid_text_field_config.dart';
import '../../../utils/validation_utils.dart';

part 'hybrid_custom_text_field_form_event.dart';
part 'hybrid_custom_text_field_form_state.dart';

/// Manages the aggregate validation state of a [HybridCustomTextFieldForm].
///
/// Responsibilities:
/// 1. Track each field's error flag and expose [hasError] for the whole form.
/// 2. When a field initialises ([HybridCustomTextFieldFormFieldStarted]),
///    compute the merged validation list using [ValidationUtils.getAllValidations]
///    and emit [HybridCustomTextFieldFormValidationsReady] so the field's own
///    bloc can append the form-level rules — no logic leaks into the widget layer.
class HybridCustomTextFieldFormBloc extends Bloc<HybridCustomTextFieldFormEvent, HybridCustomTextFieldFormState> {
  /// The form-level config that carries the shared validation rules.
  final HybridTextFieldConfig _config;

  HybridCustomTextFieldFormBloc({required HybridTextFieldConfig config})
    : _config = config,
      super(HybridCustomTextFieldFormInitial()) {
    on<HybridCustomTextFieldFormStarted>(_onStarted);
    on<HybridCustomTextFieldFormFieldStarted>(_onFieldStarted);
    on<HybridCustomTextFieldFormFieldChanged>(_onFieldChanged);
  }

  /// Initialises the error map with `false` for every field slot.
  void _onStarted(
    HybridCustomTextFieldFormStarted event,
    Emitter<HybridCustomTextFieldFormState> emit,
  ) {
    final initialErrors = <String, bool>{
      for (var i = 0; i < event.fieldCount; i++) i.toString(): false,
    };

    emit(
      HybridCustomTextFieldFormSuccess(
        data: state.data.copyWith(fieldErrors: initialErrors),
      ),
    );
  }

  /// Computes merged validations for a field and emits
  /// [HybridCustomTextFieldFormValidationsReady].
  ///
  /// Merge order (priority high → low):
  /// 1. Field's own validations (already inside [fieldConfig.validations])
  /// 2. Form-level validations from [_config] via [ValidationUtils]
  void _onFieldStarted(
    HybridCustomTextFieldFormFieldStarted event,
    Emitter<HybridCustomTextFieldFormState> emit,
  ) {
    // Form-level validations derived from the form config.
    final formValidations = ValidationUtils().getAllValidations(_config);

    // Field-level validations derived from the field's own config.
    // These are already computed by the field's own bloc via getAllValidations,
    // but we need them here to build the merged list that goes back to the field.
    //final fieldValidations = ValidationUtils().getAllValidations(event.fieldConfig);

    // Field rules first → form rules appended at the end.
    //final mergedValidations = [...fieldValidations, ...formValidations];

    emit(
      HybridCustomTextFieldFormSuccess(
        data: state.data.copyWith(validations: formValidations, fieldId: event.fieldId),
      ),
    );
  }

  /// Updates the error flag for [event.fieldId] and re-evaluates [hasError].
  void _onFieldChanged(
    HybridCustomTextFieldFormFieldChanged event,
    Emitter<HybridCustomTextFieldFormState> emit,
  ) {
    final updatedErrors = Map<String, bool>.from(state.data.fieldErrors)..[event.fieldId] = event.hasError;

    emit(
      HybridCustomTextFieldFormSuccess(
        data: state.data.copyWith(fieldErrors: updatedErrors),
      ),
    );
  }
}
