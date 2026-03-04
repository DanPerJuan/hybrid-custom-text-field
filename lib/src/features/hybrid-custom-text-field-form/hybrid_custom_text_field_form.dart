import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../hybrid_custom_text_field.dart';
import 'bloc/hybrid_custom_text_field_form_bloc.dart';

/// A form widget that groups [HybridCustomBaseTextField],
/// [HybridCustomPhoneTextField] and [HybridCustomSearchTextField] children
/// under a shared validation umbrella — inspired by Angular's reactive forms.
///
/// ## How it works
///
/// 1. Wrap any number of supported Hybrid text fields inside [HybridCustomTextFieldForm].
/// 2. Pass a [HybridFormConfig] with form-level [ValidationTextFieldEntity] rules.
/// 3. Those rules are **appended** to each child field's own validations via
///    [HybridFormConfig.validations], so field-specific rules always run first.
/// 4. Use [onFormChanged] to react whenever **any** field error state changes.
///    The callback receives the aggregate [hasError] flag for the whole form.
///
/// ## How fields communicate with the form
///
/// The form injects a [HybridFormScope] (an [InheritedWidget]) above each
/// child. Each Hybrid field reads the scope inside its own [onChanged] to:
/// - Merge form-level validations into its config at construction time.
/// - Report its error flag back to [HybridCustomTextFieldFormBloc] **without
///   the form ever needing to clone or replace the field widget**.
///
/// This means the field's own [BlocProvider] / [State] lifecycle is never
/// interrupted by the form, which fixes any layout/height issues that arose
/// from widget reconstruction.
class HybridCustomTextFieldForm extends StatelessWidget {
  /// Form-level configuration that carries shared validation rules.
  final HybridFormConfig config;

  /// Called whenever the aggregate error state of the form changes.
  ///
  /// Receives `true` when **at least one** child field has an active error.
  final void Function(bool hasError)? onFormChanged;

  /// The Hybrid text fields to display inside this form.
  ///
  /// Each element **must** be a [HybridFormField].
  final List<HybridFormField> children;

  /// Axis alignment for the internal [Column] that stacks the fields.
  final MainAxisAlignment mainAxisAlignment;

  /// Cross-axis alignment for the internal [Column].
  final CrossAxisAlignment crossAxisAlignment;

  /// Vertical spacing between consecutive child fields in logical pixels.
  final double spacing;

  const HybridCustomTextFieldForm({
    super.key,
    required this.config,
    required this.children,
    this.onFormChanged,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.spacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          HybridCustomTextFieldFormBloc(config: config)
            ..add(HybridCustomTextFieldFormStarted(fieldCount: children.length)),
      child: _HybridCustomTextFieldFormView(parent: this),
    );
  }
}

class _HybridCustomTextFieldFormView extends StatelessWidget {
  final HybridCustomTextFieldForm parent;

  const _HybridCustomTextFieldFormView({required this.parent});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<HybridCustomTextFieldFormBloc>();

    return BlocListener<HybridCustomTextFieldFormBloc, HybridCustomTextFieldFormState>(
      listener: (_, state) => parent.onFormChanged?.call(state.data.hasError),
      child: Column(
        mainAxisAlignment: parent.mainAxisAlignment,
        crossAxisAlignment: parent.crossAxisAlignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < parent.children.length; i++) ...[
            HybridFormScope(
              formBloc: bloc,
              fieldId: parent.children[i].id ?? i.toString(),
              child: parent.children[i],
            ),
            if (parent.spacing > 0 && i < parent.children.length - 1) SizedBox(height: parent.spacing),
          ],
        ],
      ),
    );
  }
}

/// [InheritedWidget] that exposes the form bloc and field id to descendant
/// Hybrid fields so they can request merged validations and report errors
/// without any logic living in the widget layer.
class HybridFormScope extends InheritedWidget {
  final HybridCustomTextFieldFormBloc formBloc;
  final String fieldId;

  const HybridFormScope({
    super.key,
    required this.formBloc,
    required this.fieldId,
    required super.child,
  });

  static HybridFormScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HybridFormScope>();

  void reportError(bool hasError) {
    formBloc.add(
      HybridCustomTextFieldFormFieldChanged(fieldId: fieldId, hasError: hasError),
    );
  }

  @override
  bool updateShouldNotify(HybridFormScope oldWidget) => fieldId != oldWidget.fieldId || formBloc != oldWidget.formBloc;
}
