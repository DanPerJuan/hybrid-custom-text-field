part of 'hybrid_custom_base_text_field_bloc.dart';

sealed class HybridCustomBaseTextFieldEvent {}

/// Event triggered when the basic text field is initialized.
class HybridCustomBaseTextFieldStarted extends HybridCustomBaseTextFieldEvent {}

/// Event triggered whenever the user changes the text in the field.
class HybridCustomBaseTextFieldChanged extends HybridCustomBaseTextFieldEvent {
  final String value;

  HybridCustomBaseTextFieldChanged({required this.value});
}

/// Fired when [HybridCustomTextFieldFormBloc] responds with the merged
/// validation list for this field.
///
/// The field bloc replaces its current validation list with [mergedValidations]
/// so form-level rules are active from the first keystroke onwards.
final class HybridCustomBaseTextFieldFormValidationsReceived extends HybridCustomBaseTextFieldEvent {
  final List<ValidationTextFieldEntity> mergedValidations;

  HybridCustomBaseTextFieldFormValidationsReceived({required this.mergedValidations});
}
