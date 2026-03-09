import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../hybrid_text_field.dart';
import '../../models/configs/hybrid_base_text_field_config.dart';
import '../../models/hybrid_field_state.dart';
import '../../utils/date_input_formatter.dart';
import '../../utils/floating_label_outline_input_border.dart';
import '../hybrid-custom-text-field-form/hybrid_custom_text_field_form.dart';
import '../hybrid_library_field_class.dart';
import 'bloc/hybrid_custom_base_text_field_bloc.dart';

/// A customizable text field with built-in validation, error display and an
/// optional password-visibility toggle.
///
/// The field is backed by an internal [HybridCustomBaseTextFieldBloc] that manages
/// validation state. Each keystroke dispatches [HybridCustomBaseTextFieldChanged];
/// the bloc runs all configured rules and the widget reacts to the resulting
/// state to update border colors and show or hide the error message.
class HybridCustomBaseTextField extends HybridLibraryField {
  /// Placeholder text shown inside the field when it is empty.
  final String? hint;

  /// Floating label displayed inside the [InputDecoration].
  final String? label;

  /// Supporting text rendered below the field (e.g. a character-count hint).
  /// Not shown when a validation error is active.
  final String? bottom;

  /// Descriptive text rendered above the field.
  /// Its color switches to [HybridTextFieldTheme.errorTextColor] on error.
  final String? info;

  /// Optional external controller. When `null`, an internal
  /// [TextEditingController] is created and owned by this widget.
  final TextEditingController? controller;

  /// When `true`, the field obscures each character and renders a
  /// visibility-toggle icon in the suffix slot.
  ///
  /// Custom icons can be set via [HybridBaseTextFieldConfig.passwordVisibleImage]
  /// and [HybridBaseTextFieldConfig.passwordHiddenImage].
  final bool isPassword;

  /// Callback triggered when the user changes the text.
  final void Function(HybridFieldState)? onChanged;

  /// Called when the user taps the field.
  final VoidCallback? onTap;

  /// Called when the user taps outside the field and focus is lost.
  final VoidCallback? onTapOutside;

  /// Controls whether the field accepts user input. When `false`, the field
  /// uses disabled colors and ignores taps.
  final bool enabled;

  /// Custom widget placed at the trailing edge of the field.
  /// Ignored when [isPassword] is `true` — the toggle icon takes priority.
  final Widget? suffixIcon;

  /// Custom widget placed at the leading edge of the field.
  final Widget? prefixIcon;

  /// Validation, keyboard and display configuration.
  /// Falls back to a default [HybridBaseTextFieldConfig] when not provided.
  final HybridBaseTextFieldConfig config;

  /// Visual theme tokens (colors, borders, typography, etc.).
  /// Falls back to [HybridTextField.theme] when not provided.
  final HybridTextFieldTheme theme;

  /// Optional external [FocusNode]. An internal node is created when `null`.
  final FocusNode? focusNode;

  /// Stable identifier used by [HybridCustomTextFieldForm] to track this
  /// field's error state. Auto-generated when `null`.
  final String? fieldId;

  /// Creates a [HybridCustomBaseTextField].
  HybridCustomBaseTextField({
    super.key,
    this.hint,
    this.label,
    this.bottom,
    this.info,
    this.controller,
    this.isPassword = false,
    this.onChanged,
    this.onTap,
    this.onTapOutside,
    this.enabled = true,
    this.suffixIcon,
    this.prefixIcon,
    HybridTextFieldTheme? theme,
    HybridBaseTextFieldConfig? config,
    this.focusNode,
    this.fieldId,
  }) : theme = theme ?? HybridTextField.theme,
       config = config ?? HybridBaseTextFieldConfig();

  @override
  Widget build(BuildContext context) {
    final effectiveConfig = HybridTextField.baseConfig.mergeWith(config);

    return BlocProvider(
      create: (_) => HybridCustomBaseTextFieldBloc(config: effectiveConfig)..add(HybridCustomBaseTextFieldStarted()),
      child: _HybridCustomBaseTextFieldView(parent: this, effectiveConfig: effectiveConfig),
    );
  }
}

class _HybridCustomBaseTextFieldView extends StatefulWidget {
  final HybridCustomBaseTextField parent;
  final HybridBaseTextFieldConfig effectiveConfig;

  const _HybridCustomBaseTextFieldView({required this.parent, required this.effectiveConfig});

  @override
  State<_HybridCustomBaseTextFieldView> createState() => _HybridCustomBaseTextFieldViewState();
}

class _HybridCustomBaseTextFieldViewState extends State<_HybridCustomBaseTextFieldView> {
  /// Whether the text is currently obscured. Initialized to `true` when
  /// [HybridCustomBaseTextField.isPassword] is `true`.
  bool isObscuringText = false;

  /// When `true`, error messages are shown regardless of focus state.
  /// Set by the form's [HybridFormController.validate] call.
  bool _forceShowErrors = false;

  /// `true` once the user has typed in the field at least once.
  /// Errors are never shown before the field is touched.
  bool _isTouched = false;

  /// Focus node — either provided by the parent or created locally.
  late final FocusNode _focusNode;

  /// Stores the pointer-down position to distinguish a real tap from a drag
  /// in [onTapUpOutside].
  Offset _lastTapPosition = Offset.zero;

  /// Shortcut to the bloc. Reads without subscribing to rebuilds.
  HybridCustomBaseTextFieldBloc get _bloc => context.read<HybridCustomBaseTextFieldBloc>();

  /// Resolved config (global merged with widget-level).
  HybridBaseTextFieldConfig get _config => widget.effectiveConfig;

  /// Controller — either provided by the parent or created locally.
  late TextEditingController _controller;

  /// Listener stored so it can be removed in [dispose].
  late final VoidCallback _controllerListener;

  /// Last value dispatched to the bloc. Used to avoid duplicate events
  /// when both [onChanged] and [_controllerListener] fire for the same input,
  /// and to detect programmatic controller updates.
  String _lastDispatchedValue = '';

  /// Stable form field id — provided by the user or auto-generated.
  late final String _formFieldId;

  /// Cached scope reference to avoid re-registering on every rebuild.
  HybridFormScope? _scope;

  /// Key used to measure the rendered size of the field so the overlay can
  /// match its width.
  final GlobalKey _fieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _formFieldId = widget.parent.fieldId ?? UniqueKey().toString();
    _focusNode = widget.parent.focusNode ?? FocusNode();
    _controller = widget.parent.controller ?? TextEditingController();
    _controllerListener = () {
      setState(() {});
      final text = _controller.text;
      if (text != _lastDispatchedValue) {
        _lastDispatchedValue = text;
        _bloc.add(HybridCustomBaseTextFieldChanged(value: text));
      }
    };
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_controllerListener);
    isObscuringText = widget.parent.isPassword;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = HybridFormScope.maybeOf(context);
    if (scope != _scope) {
      _scope = scope;
      _scope?.register(
        _formFieldId,
        onValidate: () => setState(() => _forceShowErrors = true),
        onReset: _handleReset,
      );
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.removeListener(_controllerListener);
    if (widget.parent.focusNode == null) _focusNode.dispose();
    if (widget.parent.controller == null) _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() => setState(() {
    if (_focusNode.hasFocus && !_isTouched) {
      _isTouched = true;
      _scope?.reportTouched(_formFieldId, true);
    }
  });

  void _handleReset() {
    _controller.clear(); // triggers _controllerListener → dispatches Changed(value: '')
    setState(() {
      _forceShowErrors = false;
      _isTouched = false;
    });
    _scope?.reportTouched(_formFieldId, false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HybridCustomBaseTextFieldBloc, HybridCustomBaseTextFieldState>(
      listenWhen: (prev, curr) => prev.data.hasError != curr.data.hasError,
      listener: (_, state) => _scope?.reportError(_formFieldId, state.data.hasError),
      child: _body(),
    );
  }

  Widget _body() {
    return BlocBuilder<HybridCustomBaseTextFieldBloc, HybridCustomBaseTextFieldState>(
      builder: (context, state) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.parent.info != null)
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: _info(hasError: _shouldShowError(state.data.hasError)),
                ),
              Padding(
                padding: EdgeInsetsGeometry.only(top: 8, bottom: 5),
                child: _textField(state),
              ),
              if (widget.parent.bottom != null) _bottomMessage(),
              ?_errorMessage(state),
            ],
          ),
        );
      },
    );
  }

  /// Renders the [info] label above the field. Color is [errorTextColor] on
  /// error, otherwise [descriptionColor].
  Widget _info({required bool hasError}) {
    return Text(
      widget.parent.info!,
      style: widget.parent.theme.descriptionStyle.copyWith(
        color: hasError ? widget.parent.theme.errorTextColor : widget.parent.theme.descriptionColor,
      ),
    );
  }

  /// Builds the main text field wrapped in an [AnimatedContainer] that renders
  /// the optional outer double-border decoration with a 150 ms transition.
  Widget _textField(HybridCustomBaseTextFieldState state) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: _shouldShowDouble(_shouldShowError(state.data.hasError))
          ? BoxDecoration(
              borderRadius: widget.parent.theme.resolvedDoubleBorderRadius,
              border: Border.all(
                color: _doubleColor(_shouldShowError(state.data.hasError)),
                width: widget.parent.theme.doubleBorderWidth,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
            )
          : const BoxDecoration(),
      child: Container(
        key: _fieldKey,
        height: widget.parent.config.maxLines == 1 ? widget.parent.theme.containerHeight : null,
        child: TextFormField(
          focusNode: _focusNode,
          controller: _controller,
          validator: (value) {
            if (state.data.hasError) {
              return state.data.errorMessage;
            }
            return null;
          },
          enabled: widget.parent.enabled,
          obscureText: isObscuringText,
          textAlign: widget.parent.theme.textAlign,
          textAlignVertical: widget.parent.theme.textAlignVertical,
          keyboardType: _config.dateFormatterType != null ? TextInputType.datetime : _config.keyboardType,
          textInputAction: _config.textInputAction,
          textCapitalization: _config.textCapitalization,
          inputFormatters: [
            if (_config.dateFormatterType != null) DateInputFormatter(_config.dateFormatterType!),
            ...?_config.inputFormatters,
          ],
          buildCounter:
              (
                BuildContext context, {
                required int currentLength,
                required bool isFocused,
                required int? maxLength,
              }) => null,
          maxLength: widget.parent.config.maxLength,
          maxLines: _config.singleLine ? 1 : _config.maxLines,
          minLines: _config.singleLine ? 1 : _config.minLines,
          cursorColor: widget.parent.theme.cursorColor,
          style: widget.parent.theme.textStyle.copyWith(
            color: widget.parent.enabled ? widget.parent.theme.textColor : widget.parent.theme.disabledTextColor,
          ),
          onChanged: (value) {
            if (!_isTouched) {
              setState(() => _isTouched = true);
              _scope?.reportTouched(_formFieldId, true);
            }
            widget.parent.onChanged?.call(
              HybridFieldState(
                value: value,
                hasError: state.data.hasError,
                errorMessage: state.data.errorMessage,
              ),
            );
          },
          onTap: () => widget.parent.onTap?.call(),
          onTapOutside: (event) => _lastTapPosition = event.position,
          onTapUpOutside: (event) {
            if (_lastTapPosition == event.position) {
              FocusScope.of(context).unfocus();
              widget.parent.onTapOutside?.call();
            }
          },
          decoration: _inputDecoration(state),
        ),
      ),
    );
  }

  /// Builds the full [InputDecoration] with all border variants, fill color,
  /// hint/label text and icon slots.
  InputDecoration _inputDecoration(HybridCustomBaseTextFieldState state) {
    return InputDecoration(
      isDense: false,
      filled: true,
      fillColor: widget.parent.enabled ? widget.parent.theme.fillColor : widget.parent.theme.disabledFillColor,
      error: _shouldShowError(state.data.hasError) ? const SizedBox.shrink() : null,
      hintTextDirection: widget.parent.theme.hintTextDirection,
      hintMaxLines: widget.parent.theme.hintMaxLines,
      enabled: widget.parent.enabled,
      hintText: widget.parent.hint,
      hintStyle: widget.parent.theme.hintStyle,
      prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
      prefixIcon: widget.parent.prefixIcon,
      suffixIcon: _suffixIcon(),
      labelText: widget.parent.label,
      suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      contentPadding: widget.parent.label == null
          ? EdgeInsets.symmetric(
              horizontal: widget.parent.theme.containerHeight / 4,
              vertical: widget.parent.theme.containerHeight / 3.2,
            )
          : widget.parent.config.maxLines > 1
          ? EdgeInsets.symmetric(horizontal: 10, vertical: 8)
          : widget.parent.theme.contentPadding,
      border: _enabledBorder(_shouldShowError(state.data.hasError)),
      enabledBorder: _enabledBorder(_shouldShowError(state.data.hasError)),
      focusedBorder: _focusedBorder(_shouldShowError(state.data.hasError)),
      disabledBorder: _disabledBorder(),
      errorBorder: _errorBorder(),
      focusedErrorBorder: _errorBorder(),
      errorText: null,
      errorStyle: const TextStyle(height: 0, fontSize: 0),
    );
  }

  /// Creates a [FloatingLabelOutlineInputBorder] with [color] and [width].
  FloatingLabelOutlineInputBorder _border(Color color, double width) {
    return FloatingLabelOutlineInputBorder(
      borderRadius: widget.parent.theme.borderRadius,
      borderSide: BorderSide(color: color, width: width),
    );
  }

  FloatingLabelOutlineInputBorder _enabledBorder(bool hasError) => _border(
    hasError ? widget.parent.theme.getErrorBorderColor : widget.parent.theme.getBorderColor,
    widget.parent.theme.borderWidth,
  );

  FloatingLabelOutlineInputBorder _focusedBorder(bool hasError) => _border(
    widget.parent.theme.getFocusedBorderColor,
    widget.parent.theme.focusedBorderWidth,
  );

  FloatingLabelOutlineInputBorder _disabledBorder() =>
      _border(widget.parent.theme.getDisabledBorderColor, widget.parent.theme.borderWidth);

  FloatingLabelOutlineInputBorder _errorBorder() => _border(
    _focusNode.hasFocus ? widget.parent.theme.getFocusedBorderColor : widget.parent.theme.getErrorBorderColor,
    widget.parent.theme.borderWidth,
  );

  bool _shouldShowDouble(bool hasError) {
    final s = widget.parent.theme;
    if (!widget.parent.enabled) return s.doubleBorderColor != null;
    if (_focusNode.hasFocus) {
      return s.doubleFocusedBorderColor != null || s.doubleBorderColor != null;
    }
    if (hasError) {
      return s.doubleErrorBorderColor != null || s.doubleBorderColor != null;
    }
    return s.doubleBorderColor != null;
  }

  Color _doubleColor(bool hasError) {
    final s = widget.parent.theme;
    if (!widget.parent.enabled) return s.doubleBorderColor ?? s.getDisabledBorderColor;
    if (_focusNode.hasFocus) {
      return s.doubleFocusedBorderColor ?? s.doubleBorderColor ?? s.getFocusedBorderColor;
    }
    if (hasError) {
      return s.doubleErrorBorderColor ?? s.doubleBorderColor ?? s.getErrorBorderColor;
    }
    return s.doubleBorderColor ?? s.getBorderColor;
  }

  Widget? _suffixIcon() {
    if (widget.parent.isPassword) {
      return Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
        child: Material(
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            child: isObscuringText
                ? _config.passwordHiddenImage ?? Icon(Icons.visibility_off_outlined, color: Color(0xFFBDBDBD))
                : _config.passwordVisibleImage ?? Icon(Icons.visibility_outlined, color: Color(0xFFBDBDBD)),
            onTap: () => setState(() => isObscuringText = !isObscuringText),
          ),
        ),
      );
    }
    if (widget.parent.suffixIcon != null) return widget.parent.suffixIcon;
    return null;
  }

  Widget _bottomMessage() {
    return SizedBox(
      height: 16,
      child: Text(
        widget.parent.bottom!,
        style: widget.parent.theme.supportingTextStyle.copyWith(
          color: widget.parent.theme.supportingTextColor,
        ),
      ),
    );
  }

  bool _shouldShowError(bool hasError) {
    if (!hasError) return false;
    if (_forceShowErrors) return true;
    if (!_isTouched) return false;
    if (!_config.shouldDisplayErrorWhenClicked) return true;
    return _focusNode.hasFocus;
  }

  Widget? _errorMessage(HybridCustomBaseTextFieldState state) {
    if (!_shouldShowError(state.data.hasError)) return SizedBox();
    return SizedBox(
      height: 16,
      child: Text(state.data.errorMessage!, style: widget.parent.theme.errorStyle),
    );
  }
}
