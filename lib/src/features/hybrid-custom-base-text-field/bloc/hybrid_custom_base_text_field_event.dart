part of 'hybrid_custom_base_text_field_bloc.dart';

sealed class HybridCustomBaseTextFieldEvent {}

/// Event triggered when the basic text field is initialized.
class HybridCustomBaseTextFieldStarted extends HybridCustomBaseTextFieldEvent {}

/// Event triggered whenever the user changes the text in the field.
class HybridCustomBaseTextFieldChanged extends HybridCustomBaseTextFieldEvent {
  final String value;

  HybridCustomBaseTextFieldChanged({required this.value});
}
