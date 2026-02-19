import 'package:flutter/material.dart';
import 'models/hybrid_text_field_config.dart';
import 'style/custom_text_field_style.dart';
import 'utils/floating_label_outline_input_border.dart';

class BaseTextField extends StatefulWidget {
  final String hint;
  final String? label;
  final String? bottom;
  final String? info;
  final TextDirection? hintTextDirection;
  final int? hintMaxLines;
  final TextAlign textAlign;
  final TextAlignVertical textAlignVertical;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final bool isPassword;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onTapOutside;
  final bool hasError;
  final String? errorText;
  final TextStyle? errorStyle;
  final bool enable;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final HybridTextFieldConfig config;
  final HybridTextFieldStyle style;
  // final ValidationsState? validationState;
  final bool validateOnChange;
  final FocusNode? focusNode;

  const BaseTextField({
    super.key,
    required this.hint,
    this.label,
    this.bottom,
    this.info,
    this.hintTextDirection,
    this.hintMaxLines,
    this.textAlign = TextAlign.start,
    this.textAlignVertical = TextAlignVertical.center,
    this.controller,
    this.validator,
    this.isPassword = false,
    this.onChanged,
    this.onTap,
    this.onTapOutside,
    this.hasError = false,
    this.errorText,
    this.errorStyle,
    this.enable = true,
    this.suffixIcon,
    this.prefixIcon,
    required this.config,
    this.style = const HybridTextFieldStyle(),
    //  this.validationState,
    this.validateOnChange = true,
    this.focusNode,
  });

  @override
  State<BaseTextField> createState() => _BaseTextFieldState();
}

class _BaseTextFieldState extends State<BaseTextField> {
  bool isObscuringText = false;
  late final FocusNode _focusNode;
  Offset _lastTapPosition = Offset.zero;

  @override
  void initState() {
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    isObscuringText = widget.isPassword;
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() => setState(() {});

  // ── FloatingLabelOutlineInputBorder helpers ────────────────────────────────

  FloatingLabelOutlineInputBorder _border(Color color, double width) {
    return FloatingLabelOutlineInputBorder(
      borderRadius: widget.style.borderRadius,
      borderSide: BorderSide(color: color, width: width),
    );
  }

  FloatingLabelOutlineInputBorder _enabledBorder() => _border(widget.style.borderColor, widget.style.borderWidth);
  FloatingLabelOutlineInputBorder _focusedBorder() =>
      _border(widget.style.focusedBorderColor, widget.style.focusedBorderWidth);
  FloatingLabelOutlineInputBorder _disabledBorder() =>
      _border(widget.style.disabledBorderColor, widget.style.borderWidth);
  FloatingLabelOutlineInputBorder _errorBorder() => _border(widget.style.errorBorderColor, widget.style.borderWidth);

  // ── Outer border helpers ──────────────────────────────────────────────────

  bool _shouldShowOuter(bool hasError) {
    final s = widget.style;
    if (s.outerBorderColor == null) return false;
    if (hasError) return s.showOuterBorderOnError;
    if (s.showOuterBorderOnFocus) return _focusNode.hasFocus;
    return true;
  }

  Color _outerColor(bool hasError) {
    final s = widget.style;
    if (hasError) return s.outerErrorBorderColor ?? s.errorBorderColor;
    if (_focusNode.hasFocus) return s.outerFocusedBorderColor ?? s.outerBorderColor!;
    return s.outerBorderColor!;
  }

  // ── Label color ───────────────────────────────────────────────────────────

  Color _labelColor(bool hasError) {
    if (hasError) return widget.style.errorLabelColor;
    if (_focusNode.hasFocus) return widget.style.focusedLabelColor;
    return widget.style.labelColor;
  }

  // ── Suffix icon ───────────────────────────────────────────────────────────

  Widget? _suffixIcon() {
    if (widget.suffixIcon != null) return widget.suffixIcon;
    if (widget.isPassword) {
      return IconButton(
        icon: isObscuringText
            ? Icon(Icons.visibility_outlined, color: widget.style.hintColor)
            : Icon(Icons.visibility_off_outlined, color: widget.style.hintColor),
        onPressed: () => setState(() => isObscuringText = !isObscuringText),
      );
    }
    return null;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _DummyListenable(), //widget.validationState ??
      builder: (context, _) {
        final bool hasError = widget.hasError; //|| widget.validationState?.hasError == true;
        final String? errorMsg = widget.errorText; //?? widget.validationState?.errorMessage;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _label(),
            if (widget.info != null) ...[
              const SizedBox(height: 4),
              _info(hasError),
            ],
            const SizedBox(height: 8),
            _textField(hasError),
            const SizedBox(height: 5),
            if (hasError && _focusNode.hasFocus)
              SizedBox(
                height: 16,
                child: errorMsg != null
                    ? Text(
                        errorMsg,
                        style:
                            widget.errorStyle ??
                            widget.style.supportingTextStyle.copyWith(
                              color: widget.style.errorTextColor,
                            ),
                      )
                    : null,
              )
            else if (widget.bottom != null)
              SizedBox(
                height: 16,
                child: Text(
                  widget.bottom!,
                  style: widget.style.supportingTextStyle.copyWith(
                    color: widget.style.supportingTextColor,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _label() {
    if (widget.label == null) return const SizedBox.shrink();
    return Text(widget.label!, style: widget.style.labelStyle);
  }

  Widget _info(bool hasError) {
    return Text(
      widget.info!,
      style: widget.style.descriptionStyle.copyWith(
        color: hasError ? widget.style.errorTextColor : widget.style.descriptionColor,
      ),
    );
  }

  Widget _textField(bool hasError) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: _shouldShowOuter(hasError)
          ? BoxDecoration(
              borderRadius: widget.style.resolvedOuterBorderRadius,
              border: Border.all(
                color: _outerColor(hasError),
                width: widget.style.outerBorderWidth,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
            )
          : const BoxDecoration(),
      child: SizedBox(
        height: widget.style.height,
        child: TextFormField(
          focusNode: _focusNode,
          controller: widget.controller,
          validator: widget.validator,
          enabled: widget.enable,
          obscureText: isObscuringText,
          textAlign: widget.textAlign,
          textAlignVertical: widget.textAlignVertical,
          keyboardType: widget.config.keyboardType,
          textInputAction: widget.config.textInputAction,
          textCapitalization: widget.config.textCapitalization,
          inputFormatters: widget.config.inputFormatters,
          maxLines: widget.config.singleLine ? 1 : widget.config.maxLines,
          minLines: widget.config.singleLine ? 1 : widget.config.minLines,
          cursorColor: widget.style.cursorColor,
          style: widget.style.textStyle.copyWith(
            color: widget.enable ? widget.style.textColor : widget.style.disabledTextColor,
          ),
          onChanged: (value) {
            widget.onChanged?.call(value);
            // if (widget.validateOnChange) widget.validationState?.validate(value);
          },
          onTap: widget.onTap,
          onTapOutside: (event) => _lastTapPosition = event.position,
          onTapUpOutside: (event) {
            if (_lastTapPosition == event.position) {
              FocusScope.of(context).unfocus();
              widget.onTapOutside?.call();
            }
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: widget.enable ? widget.style.fillColor : widget.style.disabledFillColor,
            // error: SizedBox.shrink() suppresses the built-in error space
            // when hasError is true, matching the second widget's pattern
            error: hasError ? const SizedBox.shrink() : null,
            label: widget.hint.isNotEmpty
                ? Text(
                    widget.hint,
                    style: widget.style.hintStyle.copyWith(
                      color: _focusNode.hasFocus || (widget.controller?.text.isNotEmpty == true)
                          ? widget.style.labelColor
                          : widget.style.hintColor,
                    ),
                  )
                : null,
            hintTextDirection: widget.hintTextDirection,
            hintMaxLines: widget.hintMaxLines,
            prefixIcon: widget.prefixIcon,
            suffixIcon: _suffixIcon(),
            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            contentPadding: widget.style.contentPadding,
            // ── Borders via FloatingLabelOutlineInputBorder ────────────────
            border: _enabledBorder(),
            enabledBorder: _enabledBorder(),
            focusedBorder: _focusedBorder(),
            disabledBorder: _disabledBorder(),
            errorBorder: _errorBorder(),
            focusedErrorBorder: _errorBorder(),
            errorText: null,
            errorStyle: const TextStyle(height: 0, fontSize: 0),
          ),
        ),
      ),
    );
  }
}

class _DummyListenable extends ChangeNotifier {}
