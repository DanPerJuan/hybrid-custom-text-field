/// Represents a validation rule for a text field.
///
/// Each instance defines a [regex] pattern and an [errorMessage] that
/// should be displayed if the validation fails.
class ValidationTextFieldEntity {
  /// The error message to display when the validation fails.
  final String errorMessage;

  /// The regular expression used to validate the input.
  final RegExp regex;

  /// Creates a [ValidationTextFieldEntity] with a required [errorMessage] and [regex].
  ValidationTextFieldEntity({
    required this.errorMessage,
    required this.regex,
  });

  /// Validates the given [value] against the [regex] pattern.
  ///
  /// Returns `true` if the value matches the pattern, otherwise `false`.
  /// If [value] is `null` or empty, it will only pass if the regex
  /// pattern is not `r'.+'` (i.e., not a required field).
  bool validate(String? value) {
    final text = value ?? '';

    if (text.isEmpty) {
      if (regex.pattern == r'.+') {
        return false;
      }
      return true;
    }

    return regex.hasMatch(text);
  }
}
