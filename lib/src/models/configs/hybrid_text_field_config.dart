import 'package:flutter/services.dart';
import '../entities/validation_text_field_entity.dart';

/// Base contract that all field configuration classes must implement.
///
/// Each concrete config (e.g. [HybridBaseTextFieldConfig],
/// [HybridPhoneTextFieldConfig], [HybridSearchTextFieldConfig]) extends this
/// class and overrides every getter to expose its specific values to the bloc
/// and the widget layer through a single, unified interface.
///
/// The bloc receives a [HybridTextFieldConfig] and does not need to know the
/// concrete subtype — this keeps the validation pipeline reusable across all
/// field variants.
abstract class HybridTextFieldConfig {
  /// Keyboard action button shown at the bottom-right of the soft keyboard.
  ///
  /// Typical values: [TextInputAction.done], [TextInputAction.next],
  /// [TextInputAction.search].
  TextInputAction get textInputAction;

  /// Hard upper limit on the number of characters the user can type.
  ///
  /// When `null`, no maximum is enforced.
  int? get maxLength;

  /// Minimum number of characters required for the field to be considered
  /// valid.
  ///
  /// When `null`, no minimum length is enforced.
  int? get minLength;

  /// Whether the field must contain a non-empty value to pass validation.
  ///
  /// When `true`, the bloc adds a "required" validation rule automatically.
  bool get isRequired;

  /// When `true`, validation errors are only shown while the field has focus
  /// (i.e. the user has tapped into it at least once).
  ///
  /// When `false` (default), errors are shown as soon as they occur,
  /// regardless of focus state.
  bool get shouldDisplayErrorWhenClicked;

  /// Additional custom validation rules applied on top of the built-in ones
  /// ([isRequired], [minLength], [maxLength]).
  ///
  /// Each [ValidationTextFieldEntity] defines a predicate and an error message.
  /// Rules are evaluated in list order; the first failing rule wins.
  List<ValidationTextFieldEntity>? get validations;

  HybridTextFieldConfig();
}
