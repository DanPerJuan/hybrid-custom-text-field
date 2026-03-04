part of 'hybrid_custom_text_field_form_bloc.dart';

class HybridCustomTextFieldFormData {
  /// Maps each field id to its current error flag.
  final Map<String, bool> fieldErrors;

  /// `true` when **any** registered field has an active validation error.
  bool get hasError => fieldErrors.values.any((e) => e);

  /// List of validation rules applied to the field.
  final List<ValidationTextFieldEntity> validations;

  /// The field that requested the validations.
  final String fieldId;

  const HybridCustomTextFieldFormData({required this.fieldErrors, required this.validations, required this.fieldId});

  HybridCustomTextFieldFormData copyWith({
    Map<String, bool>? fieldErrors,
    List<ValidationTextFieldEntity>? validations,
    String? fieldId,
  }) {
    return HybridCustomTextFieldFormData(
      fieldErrors: fieldErrors ?? this.fieldErrors,
      validations: validations ?? this.validations,
      fieldId: fieldId ?? this.fieldId,
    );
  }
}

sealed class HybridCustomTextFieldFormState {
  final HybridCustomTextFieldFormData data;

  HybridCustomTextFieldFormState({required this.data});
}

final class HybridCustomTextFieldFormInitial extends HybridCustomTextFieldFormState {
  HybridCustomTextFieldFormInitial()
    : super(
        data: const HybridCustomTextFieldFormData(fieldErrors: {}, validations: [], fieldId: ''),
      );
}

final class HybridCustomTextFieldFormSuccess extends HybridCustomTextFieldFormState {
  HybridCustomTextFieldFormSuccess({required super.data});
}
