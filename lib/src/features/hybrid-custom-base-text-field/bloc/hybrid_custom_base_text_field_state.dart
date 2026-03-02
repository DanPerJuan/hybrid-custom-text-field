part of 'hybrid_custom_base_text_field_bloc.dart';

class HybridCustomBaseTextFieldData {
  /// Whether the current field has a validation error.
  final bool hasError;

  /// Error message associated with the current validation failure (if any).
  final String? errorMessage;

  /// List of validation rules applied to the field.
  final List<ValidationTextFieldEntity> validations;

  /// Constructor for initializing all the field data.
  HybridCustomBaseTextFieldData({
    required this.hasError,
    required this.errorMessage,
    required this.validations,
  });

  /// Returns a copy of the current data with any modified fields replaced.
  HybridCustomBaseTextFieldData copyWith({
    bool? hasError,
    ValueGetter<String?>? errorMessage,
    List<ValidationTextFieldEntity>? validations,
  }) {
    return HybridCustomBaseTextFieldData(
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      validations: validations ?? this.validations,
    );
  }
}

/// Base sealed state class for the HybridCustomTextFieldBloc.
/// Contains a [HybridCustomBaseTextFieldData] object representing current state.
sealed class HybridCustomBaseTextFieldState {
  final HybridCustomBaseTextFieldData data;

  const HybridCustomBaseTextFieldState({
    required this.data,
  });
}

/// Initial state of the text field, typically when the widget is first loaded.
final class HybridCustomBaseTextFieldInitial extends HybridCustomBaseTextFieldState {
  HybridCustomBaseTextFieldInitial()
    : super(
        data: HybridCustomBaseTextFieldData(
          hasError: false,
          errorMessage: null,
          validations: [],
        ),
      );
}

/// State representing an ongoing operation, like validating input or filtering results.
final class HybridCustomBaseTextFieldInProgess extends HybridCustomBaseTextFieldState {
  HybridCustomBaseTextFieldInProgess({required super.data});
}

/// State representing a successful operation or update in the text field.
/// For example, after the input has been validated or search results updated.
final class HybridCustomBaseTextFieldSuccess extends HybridCustomBaseTextFieldState {
  HybridCustomBaseTextFieldSuccess({required super.data});
}
