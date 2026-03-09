/// Contract object returned by [HybridCustomBaseTextField.onChanged],
/// [HybridCustomPhoneTextField.onChanged] and
/// [HybridCustomSearchTextField.onChanged].
class HybridFieldState {
  /// Current text value of the field.
  final String value;

  /// Whether the field currently has a validation error.
  final bool hasError;

  /// The active error message, or `null` when [hasError] is `false`.
  final String? errorMessage;

  const HybridFieldState({
    required this.value,
    required this.hasError,
    this.errorMessage,
  });
}
