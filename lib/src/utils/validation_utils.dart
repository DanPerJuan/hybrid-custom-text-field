import '../../hybrid_custom_text_field.dart';
import '../models/configs/hybrid_text_field_config.dart';
import '../validations/validation_constants.dart';

class ValidationUtils {
  /// Builds the list of built-in validations from [config] flags using a switch,
  /// then appends any custom [config.validations] at the end.
  List<ValidationTextFieldEntity> getAllValidations(HybridTextFieldConfig config) {
    final validations = <ValidationTextFieldEntity>[];

    for (final flag in _ValidationFlag.values) {
      switch (flag) {
        case _ValidationFlag.isRequired:
          if (config.isRequired) {
            validations.add(ValidationConstants.isRequired());
          }

        case _ValidationFlag.length:
          final min = config.minLength;
          final max = config.maxLength;
          if (min != null && max != null) {
            validations.add(ValidationConstants.minMaxLength(min, max));
          } else if (min != null) {
            validations.add(ValidationConstants.minLength(min));
          } else if (max != null) {
            validations.add(ValidationConstants.maxLength(max));
          }
        case _ValidationFlag.email:
          if (config is HybridBaseTextFieldConfig && config.validationType == HybridTextFieldValidationType.email) {
            validations.add(ValidationConstants.email());
          }
        case _ValidationFlag.url:
          if (config is HybridBaseTextFieldConfig && config.validationType == HybridTextFieldValidationType.url) {
            validations.add(ValidationConstants.url());
          }
        case _ValidationFlag.dni:
          if (config is HybridBaseTextFieldConfig && config.validationType == HybridTextFieldValidationType.dni) {
            validations.add(ValidationConstants.dni());
          }
        case _ValidationFlag.creditCard:
          if (config is HybridBaseTextFieldConfig &&
              config.validationType == HybridTextFieldValidationType.creditCard) {
            validations.add(ValidationConstants.creditCard());
          }
        case _ValidationFlag.dateMMYY:
          if (config is HybridBaseTextFieldConfig &&
              config.dateFormatterType == HybridTextFieldFormatterDateType.mmyy) {
            validations.add(ValidationConstants.dateMMYY());
          }

        case _ValidationFlag.dateMMYYYY:
          if (config is HybridBaseTextFieldConfig &&
              config.dateFormatterType == HybridTextFieldFormatterDateType.mmyyyy) {
            validations.add(ValidationConstants.dateMMYYYY());
          }
        case _ValidationFlag.dateDDMMYYY:
          if (config is HybridBaseTextFieldConfig &&
              config.dateFormatterType == HybridTextFieldFormatterDateType.ddmmyyyy) {
            validations.add(ValidationConstants.dateDDMMYYYY());
          }
      }
    }

    if (config.validations != null) {
      validations.addAll(config.validations!);
    }

    return validations;
  }
}

/// Internal enum that drives the switch in [ValidationUtils].
/// Add new cases here when new built-in validations are needed.
enum _ValidationFlag { isRequired, length, email, url, dni, creditCard, dateMMYY, dateMMYYYY, dateDDMMYYY }
