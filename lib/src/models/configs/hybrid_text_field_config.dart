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

  /// When `true`, validation errors are only shown while the field has focus
  /// (i.e. the user has tapped into it at least once).
  ///
  /// When `false` (default), errors are shown as soon as they occur,
  /// regardless of focus state.
  bool get shouldDisplayErrorWhenClicked;

  /// Validation rules applied on every keystroke.
  ///
  /// Each [ValidationTextFieldEntity] defines a predicate and an error message.
  /// Rules are evaluated in list order; the first failing rule wins.
  ///
  /// Use [ValidationConstants] to build common rules:
  /// ```dart
  /// validations: [
  ///   ValidationConstants.isRequired(),
  ///   ValidationConstants.email(),
  /// ]
  /// ```
  List<ValidationTextFieldEntity>? get validations;

  HybridTextFieldConfig();
}
