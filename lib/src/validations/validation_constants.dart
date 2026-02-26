import '../models/entities/validation_text_field_entity.dart';

/// A collection of common validation rules for text fields.
///
/// Each method returns a [ValidationTextFieldEntity] that can be used
/// in your custom text field validators.
abstract class ValidationConstants {
  /// Validation rule to check that a field is not empty.
  static ValidationTextFieldEntity isRequired({
    String errorMessage = 'Este campo es obligatorio',
  }) => ValidationTextFieldEntity(
    errorMessage: errorMessage,
    regex: RegExp(r'.+'),
  );

  /// Validation rule to check that a field has at least [min] characters.
  static ValidationTextFieldEntity minLength(
    int min, {
    String? errorMessage,
  }) => ValidationTextFieldEntity(
    errorMessage: errorMessage ?? 'Debe tener al menos $min caracteres',
    regex: RegExp('^.{$min,}\$'),
  );

  /// Validation rule to check that a field has at most [max] characters.
  static ValidationTextFieldEntity maxLength(
    int max, {
    String? errorMessage,
  }) => ValidationTextFieldEntity(
    errorMessage: errorMessage ?? 'Debe tener como máximo $max caracteres',
    regex: RegExp('^.{0,$max}\$'),
  );

  /// Validation rule to check that a field has between [min] and [max] characters.
  static ValidationTextFieldEntity minMaxLength(
    int min,
    int max, {
    String? errorMessage,
  }) => ValidationTextFieldEntity(
    errorMessage: errorMessage ?? 'Debe tener entre $min y $max caracteres',
    regex: RegExp('^.{$min,$max}\$'),
  );

  /// Validation rule for phone numbers with [min] and [max] digit length.
  static ValidationTextFieldEntity phone({
    required int min,
    required int max,
    String errorMessage = 'Número de teléfono inválido',
  }) {
    return ValidationTextFieldEntity(
      errorMessage: errorMessage,
      regex: RegExp('^[0-9]{$min,$max}\$'),
    );
  }
}
