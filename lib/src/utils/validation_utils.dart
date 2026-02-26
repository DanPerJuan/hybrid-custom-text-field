import '../models/configs/hybryd_text_field_config.dart';
import '../models/entities/validation_text_field_entity.dart';
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
enum _ValidationFlag {
  isRequired,
  length,
}
