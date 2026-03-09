import '../../hybrid_custom_text_field.dart';
import '../models/configs/hybrid_text_field_config.dart';

class ValidationUtils {
  /// Builds the validation list for [config].
  ///
  /// When [config] is a [HybridBaseTextFieldConfig] with a [dateFormatterType],
  /// the matching date validation rule is added automatically (since the
  /// formatter and its validator are always used together).
  ///
  /// All other rules come from [config.validations] and are appended in order.
  List<ValidationTextFieldEntity> getAllValidations(HybridTextFieldConfig config) {
    final validations = <ValidationTextFieldEntity>[];

    // Auto-add date validation when a date formatter is configured.
    if (config is HybridBaseTextFieldConfig) {
      switch (config.dateFormatterType) {
        case HybridTextFieldFormatterDateType.mmyy:
          validations.add(ValidationConstants.dateMMYY());
        case HybridTextFieldFormatterDateType.mmyyyy:
          validations.add(ValidationConstants.dateMMYYYY());
        case HybridTextFieldFormatterDateType.ddmmyyyy:
          validations.add(ValidationConstants.dateDDMMYYYY());
        case null:
          break;
      }
    }

    if (config.validations != null) {
      validations.addAll(config.validations!);
    }

    return validations;
  }
}
