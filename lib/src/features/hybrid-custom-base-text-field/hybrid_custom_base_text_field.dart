import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../hybrid_custom_text_field.dart';
import '../../utils/date_input_formatter.dart';
import '../../utils/floating_label_outline_input_border.dart';
import '../hybrid-custom-text-field-form/bloc/hybrid_custom_text_field_form_bloc.dart';
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
  /// Its color switches to [HybridTextFieldStyle.errorTextColor] on error.
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

  /// Callback triggered when the text changes, returning the current value and whether the field contains a validation error.
  final void Function(String, bool)? onChanged;

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
  /// Falls back to [HybridTextField.baseConfig] when not provided.
  final HybridBaseTextFieldConfig config;

  /// Visual style tokens (colors, borders, typography, etc.).
  /// Falls back to [HybridTextField.style] when not provided.
  final HybridTextFieldStyle style;

  /// Optional external [FocusNode]. An internal node is created when `null`.
  final FocusNode? focusNode;

  /// Fixed height of the [TextFormField] container in logical pixels.
  /// Defaults to `62`.
  final double containerHeight;

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
    HybridTextFieldStyle? style,
    HybridBaseTextFieldConfig? config,
    this.focusNode,
    this.containerHeight = 62,
  }) : style = style ?? HybridTextField.style,
       config = config ?? HybridTextField.baseConfig;

  @override
  Widget build(BuildContext context) {
    final scope = HybridFormScope.maybeOf(context);

    return BlocProvider(
      /// Provide an isolated bloc instance and immediately fire the started
      /// event so validations are loaded from the config.
      create: (_) {
        final fieldBloc = HybridCustomBaseTextFieldBloc(config: config)..add(HybridCustomBaseTextFieldStarted());

        /// If inside a form, ask the form bloc to compute the merged validation
        /// list (field validations first, form validations appended).
        /// The form bloc responds with HybridCustomTextFieldFormValidationsReady,
        /// which the BlocListener below forwards to this field's bloc.
        if (scope != null) {
          scope.formBloc.add(
            HybridCustomTextFieldFormFieldStarted(
              fieldConfig: config,
              fieldId: scope.fieldId,
            ),
          );
        }

        return fieldBloc;
      },
      child: _HybridCustomBaseTextFieldView(parent: this, scope: scope),
    );
  }
}

class _HybridCustomBaseTextFieldView extends StatefulWidget {
  final HybridCustomBaseTextField parent;
  final HybridFormScope? scope;

  _HybridCustomBaseTextFieldView({required this.parent, this.scope});

  @override
  State<_HybridCustomBaseTextFieldView> createState() => _HybridCustomBaseTextFieldViewState();
}

class _HybridCustomBaseTextFieldViewState extends State<_HybridCustomBaseTextFieldView> {
  /// Whether the text is currently obscured. Initialized to `true` when
  /// [HybridCustomBaseTextField.isPassword] is `true`.
  bool isObscuringText = false;

  /// Focus node — either provided by the parent or created locally.
  late final FocusNode _focusNode;

  /// Stores the pointer-down position to distinguish a real tap from a drag
  /// in [onTapUpOutside].
  Offset _lastTapPosition = Offset.zero;

  /// Shortcut to the bloc. Reads without subscribing to rebuilds.
  HybridCustomBaseTextFieldBloc get _bloc => context.read<HybridCustomBaseTextFieldBloc>();

  /// Controller — either provided by the parent or created locally.
  late TextEditingController _controller;

  /// Key used to measure the rendered size of the field so the overlay can
  /// match its width.
  final GlobalKey _fieldKey = GlobalKey();

  @override
  void initState() {
    _focusNode = widget.parent.focusNode ?? FocusNode();
    _controller = widget.parent.controller ?? TextEditingController();
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(() => setState(() {}));
    isObscuringText = widget.parent.isPassword;
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return widget.scope != null
        ? BlocListener<HybridCustomTextFieldFormBloc, HybridCustomTextFieldFormState>(
            bloc: widget.scope!.formBloc,
            listenWhen: (_, state) =>
                state is HybridCustomTextFieldFormSuccess && state.data.fieldId == widget.scope!.fieldId,
            listener: (_, state) {
              if (state is HybridCustomTextFieldFormSuccess) {
                _bloc.add(
                  HybridCustomBaseTextFieldFormValidationsReceived(
                    mergedValidations: state.data.validations,
                  ),
                );
              }
            },
            child: _body(),
          )
        : _body();
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
                  child: _info(hasError: state.data.hasError),
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
      style: widget.parent.style.descriptionStyle.copyWith(
        color: hasError ? widget.parent.style.errorTextColor : widget.parent.style.descriptionColor,
      ),
    );
  }

  /// Builds the main text field wrapped in an [AnimatedContainer] that renders
  /// the optional outer double-border decoration with a 150 ms transition.
  Widget _textField(HybridCustomBaseTextFieldState state) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: _shouldShowDoubleBorder(state.data.hasError)
          ? BoxDecoration(
              borderRadius: widget.parent.style.resolvedDoubleBorderRadius,
              border: Border.all(
                color: _doubleBorderColor(state.data.hasError),
                width: widget.parent.style.doubleBorderWidth,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
            )
          : const BoxDecoration(),
      child: Container(
        key: _fieldKey,
        height: widget.parent.containerHeight,
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
          textAlign: widget.parent.style.textAlign,
          textAlignVertical: widget.parent.style.textAlignVertical,
          keyboardType: widget.parent.config.dateFormatterType != null
              ? TextInputType.datetime
              : widget.parent.config.keyboardType,
          textInputAction: widget.parent.config.textInputAction,
          textCapitalization: widget.parent.config.textCapitalization,
          inputFormatters: [
            if (widget.parent.config.dateFormatterType != null)
              DateInputFormatter(widget.parent.config.dateFormatterType!),
            ...?widget.parent.config.inputFormatters,
          ],
          maxLines: widget.parent.config.singleLine ? 1 : widget.parent.config.maxLines,
          minLines: widget.parent.config.singleLine ? 1 : widget.parent.config.minLines,
          cursorColor: widget.parent.style.cursorColor,
          style: widget.parent.style.textStyle.copyWith(
            color: widget.parent.enabled ? widget.parent.style.textColor : widget.parent.style.disabledTextColor,
          ),
          onChanged: (value) {
            _bloc.add(HybridCustomBaseTextFieldChanged(value: value));
            widget.parent.onChanged?.call(value, state.data.hasError);
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
      fillColor: widget.parent.enabled ? widget.parent.style.fillColor : widget.parent.style.disabledFillColor,
      error: state.data.hasError ? const SizedBox.shrink() : null,
      hintTextDirection: widget.parent.style.hintTextDirection,
      hintMaxLines: widget.parent.style.hintMaxLines,
      enabled: widget.parent.enabled,
      hintText: widget.parent.hint,
      hintStyle: widget.parent.style.hintStyle,
      prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
      prefixIcon: widget.parent.prefixIcon,
      suffixIcon: _suffixIcon(),
      labelText: widget.parent.label,
      suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      contentPadding: widget.parent.label == null
          ? EdgeInsets.symmetric(
              horizontal: widget.parent.containerHeight / 4,
              vertical: widget.parent.containerHeight / 3.2,
            )
          : widget.parent.style.contentPadding,
      border: _enabledBorder(state.data.hasError),
      enabledBorder: _enabledBorder(state.data.hasError),
      focusedBorder: _focusedBorder(state.data.hasError),
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
      borderRadius: widget.parent.style.borderRadius,
      borderSide: BorderSide(color: color, width: width),
    );
  }

  /// Border shown when the field is enabled but not focused.
  /// Switches to [errorBorderColor] when [hasError] is `true`.
  FloatingLabelOutlineInputBorder _enabledBorder(bool hasError) => _border(
    hasError ? widget.parent.style.getErrorBorderColor : widget.parent.style.getBorderColor,
    widget.parent.style.borderWidth,
  );

  /// Border shown while the field is focused.
  FloatingLabelOutlineInputBorder _focusedBorder(bool hasError) => _border(
    widget.parent.style.getFocusedBorderColor,
    widget.parent.style.focusedBorderWidth,
  );

  /// Border shown when the field is disabled (not interactive).
  FloatingLabelOutlineInputBorder _disabledBorder() =>
      _border(widget.parent.style.getDisabledBorderColor, widget.parent.style.borderWidth);

  /// Border used when [TextFormField] enters error state.
  /// Uses [focusedBorderColor] while focused, otherwise [errorBorderColor].
  FloatingLabelOutlineInputBorder _errorBorder() => _border(
    _focusNode.hasFocus ? widget.parent.style.getFocusedBorderColor : widget.parent.style.getErrorBorderColor,
    widget.parent.style.borderWidth,
  );

  /// Returns `true` when the outer double-border decoration should be visible.
  ///
  /// Priority:
  /// 1. Disabled → show only if [doubleBorderColor] is set.
  /// 2. Focused  → show if [doubleFocusedBorderColor] OR [doubleBorderColor] is set.
  /// 3. Error    → show if [doubleErrorBorderColor] OR [doubleBorderColor] is set.
  /// 4. Default  → show only if [doubleBorderColor] is set.
  bool _shouldShowDoubleBorder(bool hasError) {
    final s = widget.parent.style;
    if (!widget.parent.enabled) return s.doubleBorderColor != null;
    if (_focusNode.hasFocus) {
      return s.doubleFocusedBorderColor != null || s.doubleBorderColor != null;
    }
    if (hasError) {
      return s.doubleErrorBorderColor != null || s.doubleBorderColor != null;
    }
    return s.doubleBorderColor != null;
  }

  /// Resolves the outer double-border color, falling back through
  /// state-specific → base double → primary border color.
  Color _doubleBorderColor(bool hasError) {
    final s = widget.parent.style;
    if (!widget.parent.enabled) return s.doubleBorderColor ?? s.getDisabledBorderColor;
    if (_focusNode.hasFocus) {
      return s.doubleFocusedBorderColor ?? s.doubleBorderColor ?? s.getFocusedBorderColor;
    }
    if (hasError) {
      return s.doubleErrorBorderColor ?? s.doubleBorderColor ?? s.getErrorBorderColor;
    }
    return s.doubleBorderColor ?? s.getBorderColor;
  }

  /// Builds the suffix icon:
  /// - **Password field** → tap-to-toggle visibility using custom icons from
  ///   the config or default Material eye icons.
  /// - **Otherwise** → [HybridCustomBaseTextField.suffixIcon] or `null`.
  Widget? _suffixIcon() {
    if (widget.parent.isPassword) {
      return Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
        child: Material(
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            child: isObscuringText
                ? widget.parent.config.passwordHiddenImage ??
                      Icon(Icons.visibility_off_outlined, color: Color(0xFFBDBDBD))
                : widget.parent.config.passwordVisibleImage ??
                      Icon(Icons.visibility_outlined, color: Color(0xFFBDBDBD)),
            onTap: () => setState(() => isObscuringText = !isObscuringText),
          ),
        ),
      );
    }
    if (widget.parent.suffixIcon != null) return widget.parent.suffixIcon;
    return null;
  }

  /// Supporting text shown below the field when there is no validation error.
  Widget _bottomMessage() {
    return SizedBox(
      height: 16,
      child: Text(
        widget.parent.bottom!,
        style: widget.parent.style.supportingTextStyle.copyWith(
          color: widget.parent.style.supportingTextColor,
        ),
      ),
    );
  }

  /// Renders the validation error message below the field.
  Widget? _errorMessage(HybridCustomBaseTextFieldState state) {
    return state.data.hasError && !widget.parent.config.shouldDisplayErrorWhenClicked ||
            state.data.hasError && widget.parent.config.shouldDisplayErrorWhenClicked && _focusNode.hasFocus
        ? SizedBox(
            height: 16,
            child: Text(state.data.errorMessage!, style: widget.parent.style.errorStyle),
          )
        : null;
  }
}
