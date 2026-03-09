import 'package:flutter/material.dart';
import '../../models/hybrid_form_state.dart';

/// A form container that aggregates the validation state of any
/// [HybridCustomBaseTextField], [HybridCustomPhoneTextField] or
/// [HybridCustomSearchTextField] widgets placed in its [children].
///
/// Non-Hybrid widgets (e.g. [Text], [Divider]) are ignored by the form and
/// rendered as-is.
///
/// ## How it works
///
/// The form injects a [HybridFormScope] above all its children. Our field
/// widgets automatically detect the scope in [State.didChangeDependencies]
/// and register themselves. On every validation change they call
/// [HybridFormScope.reportError] so the aggregate state stays in sync.

class HybridCustomTextFieldForm extends StatelessWidget {
  /// Optional controller for imperative access ([validate], [reset],
  /// [hasError], [fieldErrors]).
  final HybridFormController? controller;

  /// Called whenever the aggregate state of the form changes.
  final void Function(HybridFormState)? onFormChanged;

  /// Any widgets to display inside the form.
  ///
  /// Only Hybrid field widgets auto-subscribe to the form. Other widgets
  /// are rendered without any form interaction.
  final List<Widget> children;

  /// Main-axis alignment for the internal [Column].
  final MainAxisAlignment mainAxisAlignment;

  /// Cross-axis alignment for the internal [Column].
  final CrossAxisAlignment crossAxisAlignment;

  /// Vertical spacing between consecutive children in logical pixels.
  final double spacing;

  const HybridCustomTextFieldForm({
    super.key,
    this.controller,
    this.onFormChanged,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.spacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    return _HybridCustomTextFieldFormView(parent: this);
  }
}

// ── Internal view ─────────────────────────────────────────────────────────────

class _HybridCustomTextFieldFormView extends StatefulWidget {
  final HybridCustomTextFieldForm parent;

  const _HybridCustomTextFieldFormView({required this.parent});

  @override
  State<_HybridCustomTextFieldFormView> createState() => _HybridCustomTextFieldFormViewState();
}

class _HybridCustomTextFieldFormViewState extends State<_HybridCustomTextFieldFormView>
    with AutomaticKeepAliveClientMixin {
  // Keep the form alive when it has an external controller so that a ListView
  // scrolling the form off-screen does not dispose the state (which would null
  // out _resetFn / _validateFn on the controller and break imperative calls).
  @override
  bool get wantKeepAlive => widget.parent.controller != null;
  late final HybridFormController _effectiveController;
  bool _ownsController = false;

  final Map<String, VoidCallback> _validateCallbacks = {};
  final Map<String, VoidCallback> _resetCallbacks = {};

  // Stable closure references — evaluated once so HybridFormScope always
  // receives identical function objects across rebuilds. This lets
  // updateShouldNotify return false correctly and prevents fields from
  // losing their registered callbacks when the form rebuilds.
  late final void Function(String, {VoidCallback? onValidate, VoidCallback? onReset}) _stableRegister;
  late final void Function(String, bool) _stableReportError;
  late final void Function(String, bool) _stableReportTouched;
  late final void Function([String?]) _stableValidate;
  late final void Function([String?]) _stableReset;

  @override
  void initState() {
    super.initState();
    _stableRegister = _register;
    _stableReportError = _reportError;
    _stableReportTouched = _reportTouched;
    _stableValidate = _validate;
    _stableReset = _reset;

    if (widget.parent.controller != null) {
      _effectiveController = widget.parent.controller!;
    } else {
      _effectiveController = HybridFormController();
      _ownsController = true;
    }
    _effectiveController.addListener(_onControllerChanged);
    _effectiveController._attach(
      validate: _stableValidate,
      reset: _stableReset,
    );
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_onControllerChanged);
    _effectiveController._detach();
    if (_ownsController) _effectiveController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    widget.parent.onFormChanged?.call(
      HybridFormState(
        hasError: _effectiveController.hasError,
        fieldErrors: _effectiveController.fieldErrors,
        fieldTouched: _effectiveController.fieldTouched,
      ),
    );
  }

  void _register(
    String fieldId, {
    VoidCallback? onValidate,
    VoidCallback? onReset,
  }) {
    if (onValidate != null) _validateCallbacks[fieldId] = onValidate;
    if (onReset != null) _resetCallbacks[fieldId] = onReset;
  }

  void _reportError(String fieldId, bool hasError) {
    _effectiveController._update(fieldId, hasError);
  }

  void _reportTouched(String fieldId, bool isTouched) {
    _effectiveController._updateTouched(fieldId, isTouched);
  }

  void _validate([String? fieldId]) {
    if (fieldId != null) {
      _validateCallbacks[fieldId]?.call();
    } else {
      for (final cb in _validateCallbacks.values) {
        cb();
      }
    }
  }

  void _reset([String? fieldId]) {
    if (fieldId != null) {
      _resetCallbacks[fieldId]?.call();
    } else {
      for (final cb in _resetCallbacks.values) {
        cb();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // required by AutomaticKeepAliveClientMixin
    return HybridFormScope(
      register: _stableRegister,
      reportError: _stableReportError,
      reportTouched: _stableReportTouched,
      validate: _stableValidate,
      reset: _stableReset,
      child: Column(
        mainAxisAlignment: widget.parent.mainAxisAlignment,
        crossAxisAlignment: widget.parent.crossAxisAlignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < widget.parent.children.length; i++) ...[
            widget.parent.children[i],
            if (widget.parent.spacing > 0 && i < widget.parent.children.length - 1)
              SizedBox(height: widget.parent.spacing),
          ],
        ],
      ),
    );
  }
}

// ── HybridFormScope ───────────────────────────────────────────────────────────

/// [InheritedWidget] that exposes form callbacks to descendant Hybrid fields.
///
/// Fields call [register] once on mount and [reportError] on every validation
/// change. The form uses these to keep the aggregate [HybridFormController]
/// state up to date.
class HybridFormScope extends InheritedWidget {
  /// Registers a field with the form.
  ///
  /// - [fieldId] — stable identifier for this field.
  /// - [onValidate] — called when [HybridFormController.validate] is invoked.
  /// - [onReset] — called when [HybridFormController.reset] is invoked.
  final void Function(
    String fieldId, {
    VoidCallback? onValidate,
    VoidCallback? onReset,
  })
  register;

  /// Reports the current error flag for a registered field.
  final void Function(String fieldId, bool hasError) reportError;

  /// Reports whether a field has been touched (focused or typed into).
  final void Function(String fieldId, bool isTouched) reportTouched;

  /// Triggers validation display on all fields (or the field identified by
  /// [fieldId]).
  final void Function([String? fieldId]) validate;

  /// Resets all fields (or the field identified by [fieldId]).
  final void Function([String? fieldId]) reset;

  const HybridFormScope({
    super.key,
    required this.register,
    required this.reportError,
    required this.reportTouched,
    required this.validate,
    required this.reset,
    required super.child,
  });

  /// Returns the nearest [HybridFormScope] ancestor, or `null` if the widget
  /// is not inside a [HybridCustomTextFieldForm].
  static HybridFormScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HybridFormScope>();

  @override
  bool updateShouldNotify(HybridFormScope oldWidget) =>
      !identical(register, oldWidget.register) ||
      !identical(reportError, oldWidget.reportError) ||
      !identical(reportTouched, oldWidget.reportTouched);
}

// ── HybridFormController ──────────────────────────────────────────────────────

/// Provides imperative control over a [HybridCustomTextFieldForm].
///
/// Pass an instance to [HybridCustomTextFieldForm.controller] to:
/// - Read the aggregate [hasError] / per-field [fieldErrors] at any time.
/// - Call [validate] to force all fields (or a specific one) to show their
///   error messages — useful when the user taps submit without touching any field.
/// - Call [reset] to clear all fields (or a specific one) back to their
///   empty state.
///
/// The controller is a [ChangeNotifier]: add a listener to react to changes
/// without relying on the [HybridCustomTextFieldForm.onFormChanged] callback.
class HybridFormController extends ChangeNotifier {
  Map<String, bool> _fieldErrors = {};
  Map<String, bool> _fieldTouched = {};

  /// `true` when **at least one** registered field has an active error.
  bool get hasError => _fieldErrors.values.any((e) => e);

  /// Maps each registered field id to its current error flag.
  Map<String, bool> get fieldErrors => Map.unmodifiable(_fieldErrors);

  /// Returns the error flag for the field identified by [fieldId],
  /// or `false` if no field with that id has been registered.
  bool fieldHasError(String fieldId) => _fieldErrors[fieldId] ?? false;

  /// Maps each registered field id to its touched flag.
  Map<String, bool> get fieldTouched => Map.unmodifiable(_fieldTouched);

  /// Returns whether the field identified by [fieldId] has been touched
  /// (focused or typed into), or `false` if not registered.
  bool isTouched(String fieldId) => _fieldTouched[fieldId] ?? false;

  // ── Imperatives ────────────────────────────────────────────────────────────

  /// Forces all fields (or the field identified by [fieldId]) to display
  /// their current error message, regardless of focus state.
  void validate([String? fieldId]) => _validateFn?.call(fieldId);

  /// Clears all fields (or the field identified by [fieldId]) and resets
  /// their validation state.
  void reset([String? fieldId]) => _resetFn?.call(fieldId);

  // ── Internals (used by HybridCustomTextFieldForm) ──────────────────────────

  void Function([String?])? _validateFn;
  void Function([String?])? _resetFn;

  void _update(String fieldId, bool hasError) {
    if (_fieldErrors[fieldId] == hasError) return;
    _fieldErrors = {..._fieldErrors, fieldId: hasError};
    notifyListeners();
  }

  void _updateTouched(String fieldId, bool isTouched) {
    if (_fieldTouched[fieldId] == isTouched) return;
    _fieldTouched = {..._fieldTouched, fieldId: isTouched};
    notifyListeners();
  }

  void _attach({
    required void Function([String?]) validate,
    required void Function([String?]) reset,
  }) {
    _validateFn = validate;
    _resetFn = reset;
  }

  void _detach() {
    _validateFn = null;
    _resetFn = null;
  }
}
