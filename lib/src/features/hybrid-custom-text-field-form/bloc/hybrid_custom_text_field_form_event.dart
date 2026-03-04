part of 'hybrid_custom_text_field_form_bloc.dart';

sealed class HybridCustomTextFieldFormEvent {
  const HybridCustomTextFieldFormEvent();
}

/// Fired once on form mount to register the number of child fields.
final class HybridCustomTextFieldFormStarted extends HybridCustomTextFieldFormEvent {
  final int fieldCount;
  const HybridCustomTextFieldFormStarted({required this.fieldCount});
}

/// Fired by each field on init to get the merged validation list.
///
/// The bloc uses [ValidationUtils.getAllValidations] on the form config,
/// then returns the result so the field bloc can append them to its own list.
final class HybridCustomTextFieldFormFieldStarted extends HybridCustomTextFieldFormEvent {
  /// The field's own config — used to run [ValidationUtils.getAllValidations]
  /// on the form-level config and merge the result.
  final HybridTextFieldConfig fieldConfig;

  /// The field's slot identifier inside the form.
  final String fieldId;

  const HybridCustomTextFieldFormFieldStarted({
    required this.fieldConfig,
    required this.fieldId,
  });
}

/// Fired by each field on every keystroke to report its current error state.
final class HybridCustomTextFieldFormFieldChanged extends HybridCustomTextFieldFormEvent {
  final String fieldId;
  final bool hasError;
  const HybridCustomTextFieldFormFieldChanged({
    required this.fieldId,
    required this.hasError,
  });
}
