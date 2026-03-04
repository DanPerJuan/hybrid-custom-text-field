import '../models/entities/validation_text_field_entity.dart';

/// A collection of common validation rules for text fields.
///
/// Each method returns a [ValidationTextFieldEntity] that can be used
/// in your custom text field validators.
abstract class ValidationConstants {
  /// Validation rule to check that a field is not empty.
  static ValidationTextFieldEntity isRequired({
    String? errorMessage,
  }) => ValidationTextFieldEntity(
    errorMessage: errorMessage ?? 'Este campo es obligatorio',
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
    String? errorMessage,
  }) {
    return ValidationTextFieldEntity(
      errorMessage: errorMessage ?? 'Número de teléfono inválido',
      regex: RegExp('^[0-9]{$min,$max}\$'),
    );
  }

  /// Validation rule to check that a text is a valid URL.
  ///
  /// Accepts URLs with or without protocol (http/https),
  /// including domain and optional path or query parameters.
  static ValidationTextFieldEntity url({
    String? errorMessage,
  }) => ValidationTextFieldEntity(
    errorMessage: errorMessage ?? 'URL inválida',
    regex: RegExp(r'^(https?:\/\/)?([\w\d-]+\.)+\w{2,}(\/[\w\d-./?%&=]*)?$'),
  );

  /// Validation rule to check that a text is a valid email address.
  ///
  /// Ensures the email contains:
  /// - Local part (before @)
  /// - Domain name
  /// - Valid domain extension (2–4 characters)
  static ValidationTextFieldEntity email({
    String? errorMessage,
  }) => ValidationTextFieldEntity(
    errorMessage: errorMessage ?? 'Email inválido',
    regex: RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'),
  );

  /// Validation rule for DNI-like formats requiring at least
  /// one uppercase letter in the text.
  static ValidationTextFieldEntity dni({
    String? errorMessage,
  }) => ValidationTextFieldEntity(
    errorMessage: errorMessage ?? 'Debe tener 9 caracteres y al menos una letra mayúscula',
    regex: RegExp(r'^(?=.*[A-Z]).{9}$'),
  );

  /// Validation rule to check that a text is a valid credit card number.
  static ValidationTextFieldEntity creditCard({String? errorMessage}) {
    return ValidationTextFieldEntity(
      errorMessage: errorMessage ?? 'Número de tarjeta inválido',
      regex: RegExp(r'^[0-9]{13,19}$'),
    );
  }

  static ValidationTextFieldEntity dateMMYY({
    String? errorMessage,
  }) => ValidationTextFieldEntity(
    errorMessage: errorMessage ?? 'Fecha inválida',
    regex: RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$'),
  );

  static ValidationTextFieldEntity dateMMYYYY({
    String? errorMessage,
  }) => ValidationTextFieldEntity(
    errorMessage: errorMessage ?? 'Fecha inválida',
    regex: RegExp(r'^(0[1-9]|1[0-2])\/\d{4}$'),
  );

  static ValidationTextFieldEntity dateDDMMYYYY({
    String? errorMessage,
  }) => ValidationTextFieldEntity(
    errorMessage: errorMessage ?? 'Fecha inválida',
    regex: RegExp(r'^(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[0-2])\/\d{4}$'),
  );
}
