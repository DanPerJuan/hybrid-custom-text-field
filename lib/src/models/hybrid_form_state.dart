/// Contract object returned by [HybridCustomTextFieldForm.onFormChanged].
class HybridFormState {
  /// `true` when at least one registered field has an active error.
  final bool hasError;

  /// Maps each registered field id to its current error flag.
  final Map<String, bool> fieldErrors;

  /// Maps each registered field id to its touched flag.
  final Map<String, bool> fieldTouched;

  const HybridFormState({
    required this.hasError,
    required this.fieldErrors,
    required this.fieldTouched,
  });
}
