import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../hybrid_custom_text_field.dart';
import '../hybrid_library_field_class.dart';
import 'bloc/hybrid_custom_phone_text_field_bloc.dart';
import 'widgets/country_picker_dialog.dart';
import 'widgets/custom_phone_prefixes_list.dart';

/// A phone number input field with a country-prefix selector.
///
/// The field combines a tappable prefix button (showing the selected country's
/// dial code, flag, or name according to [HybridPhoneTextFieldConfig.countryViewOptions])
/// with a plain number input. Tapping the prefix opens a country picker either
/// as a modal bottom sheet (default) or as a dialog, controlled by [showDialog].
///
/// The field is backed by an internal [HybridCustomPhoneTextFieldBloc] that:
/// - Loads the full country list and validation rules on mount.
/// - Updates the phone length validation rule whenever the user changes the
///   prefix ([HybridCustomTextFieldCountryChanged]).
/// - Runs all validation rules on every keystroke ([HybridCustomTextFieldChanged]).
///
/// ### Basic usage
/// ```dart
/// HybridCustomPhoneTextField(
///   config: HybridPhoneTextFieldConfig(
///     isRequired: true,
///     countryViewOptions: CountryViewOptions.countryCodeWithFlag,
///   ),
///   onChanged: (value) => print(value),
///   onPrefixSelected: (country) => print(country.dialCode),
/// )
/// ```
class HybridCustomPhoneTextField extends HybridLibraryField {
  /// Floating label displayed inside the [InputDecoration].
  final String? label;

  /// Supporting text rendered below the field when there is no error.
  final String? bottom;

  /// Descriptive text rendered above the field.
  /// Color switches to [HybridPhoneTextFieldTheme.errorTextColor] on error.
  final String? info;

  /// Optional external controller. An internal instance is created when `null`.
  final TextEditingController? controller;

  /// Called when the user picks a new country prefix from the picker.
  final Function(CountryEntity country)? onPrefixSelected;

  /// Callback triggered when the user changes the text.
  final void Function(HybridFieldState)? onChanged;

  /// Called when the user taps the phone number input.
  final VoidCallback? onTap;

  /// Called when the user taps outside the field and focus is lost.
  final VoidCallback? onTapOutside;

  /// Controls whether the field accepts input. When `false`, the field uses
  /// disabled colors and ignores taps.
  final bool enable;

  /// Custom trailing icon for the phone number input. `null` renders no icon.
  final Widget? suffixIcon;

  /// Validation, keyboard behaviour and country view configuration.
  /// Falls back to a default [HybridPhoneTextFieldConfig] when not provided.
  final HybridPhoneTextFieldConfig config;

  /// Visual theme tokens (colors, borders, typography, etc.).
  /// Falls back to [HybridTextField.phoneTheme] when not provided.
  final HybridPhoneTextFieldTheme theme;

  /// Optional external [FocusNode] for the phone number input.
  /// An internal node is created when `null`.
  final FocusNode? focusNode;

  /// Stable identifier used by [HybridCustomTextFieldForm] to track this
  /// field's error state. Auto-generated when `null`.
  final String? fieldId;

  /// Creates a [HybridCustomPhoneTextField].
  HybridCustomPhoneTextField({
    super.key,
    this.label,
    this.bottom,
    this.info,
    this.controller,
    this.onPrefixSelected,
    this.onChanged,
    this.onTap,
    this.onTapOutside,
    this.enable = true,
    this.suffixIcon,
    this.focusNode,
    this.fieldId,
    HybridPhoneTextFieldConfig? config,
    HybridPhoneTextFieldTheme? theme,
  }) : theme = theme ?? HybridTextField.phoneTheme,
       config = config ?? HybridPhoneTextFieldConfig();

  @override
  Widget build(BuildContext context) {
    final effectiveConfig = HybridTextField.phoneConfig.mergeWith(config);

    return BlocProvider(
      create: (_) => HybridCustomPhoneTextFieldBloc(config: effectiveConfig)
        ..add(
          HybridCustomPhoneTextFieldStarted(
            selectedCountry: effectiveConfig.selectedCountry,
            countries: effectiveConfig.countries,
          ),
        ),
      child: _CustomPhoneTextFieldView(parent: this, effectiveConfig: effectiveConfig),
    );
  }
}

class _CustomPhoneTextFieldView extends StatefulWidget {
  final HybridCustomPhoneTextField parent;
  final HybridPhoneTextFieldConfig effectiveConfig;

  const _CustomPhoneTextFieldView({required this.parent, required this.effectiveConfig});

  @override
  State<_CustomPhoneTextFieldView> createState() => _CustomPhoneTextFieldViewState();
}

class _CustomPhoneTextFieldViewState extends State<_CustomPhoneTextFieldView> {
  /// Focus node for the phone number input.
  late final FocusNode _focusNode;

  /// When `true`, error messages are shown regardless of focus state.
  bool _forceShowErrors = false;

  /// `true` once the user has typed in the field at least once.
  bool _isTouched = false;

  /// Stores the pointer-down position to distinguish real taps from drags.
  Offset _lastTapPosition = Offset.zero;

  /// Shortcut to the bloc without subscribing to rebuilds.
  HybridCustomPhoneTextFieldBloc get _bloc => context.read<HybridCustomPhoneTextFieldBloc>();

  /// Resolved config (global merged with widget-level).
  HybridPhoneTextFieldConfig get _config => widget.effectiveConfig;

  /// Controller — either provided by the parent or created locally.
  late TextEditingController _controller;

  /// Listener stored so it can be removed in [dispose].
  late final VoidCallback _controllerListener;

  /// Last value dispatched to the bloc.
  String _lastDispatchedValue = '';

  /// Stable form field id.
  late final String _formFieldId;

  /// Cached scope reference.
  HybridFormScope? _scope;

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
        _bloc.add(HybridCustomPhoneTextFieldChanged(value: text));
      }
    };
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_controllerListener);
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
    return BlocListener<HybridCustomPhoneTextFieldBloc, HybridCustomPhoneTextFieldState>(
      listenWhen: (prev, curr) => prev.data.hasError != curr.data.hasError,
      listener: (_, state) => _scope?.reportError(_formFieldId, state.data.hasError),
      child: _body(),
    );
  }

  Widget _body() {
    return BlocBuilder<HybridCustomPhoneTextFieldBloc, HybridCustomPhoneTextFieldState>(
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
                child: _phoneField(state),
              ),
              if (widget.parent.bottom != null) _bottomMessage(),
              ?_errorMessage(state),
            ],
          ),
        );
      },
    );
  }

  /// Renders the [info] label above the field.
  Widget _info({required bool hasError}) {
    return Text(
      widget.parent.info!,
      style: widget.parent.theme.descriptionStyle.copyWith(
        color: hasError ? widget.parent.theme.errorTextColor : widget.parent.theme.descriptionColor,
      ),
    );
  }

  /// Builds the phone field container: an [AnimatedContainer] for the optional
  /// double-border, wrapping a [Row] with the prefix button and the text input.
  Widget _phoneField(HybridCustomPhoneTextFieldState state) {
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
        height: widget.parent.theme.containerHeight + 2,
        decoration: BoxDecoration(
          color: widget.parent.theme.fillColor,
          border: Border.all(
            color: _borderColor(_shouldShowError(state.data.hasError)),
            width: widget.parent.theme.borderWidth,
          ),
          borderRadius: widget.parent.theme.borderRadius,
        ),
        child: Row(
          children: [
            _prefix(),
            Expanded(
              child: Container(
                height: widget.parent.theme.containerHeight - 3,
                padding: EdgeInsets.only(right: 16),
                alignment: Alignment.center,
                child: _textfield(state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowDouble(bool hasError) {
    final s = widget.parent.theme;
    if (!widget.parent.enable) return s.doubleBorderColor != null;
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
    if (!widget.parent.enable) return s.doubleBorderColor ?? s.getDisabledBorderColor;
    if (_focusNode.hasFocus) {
      return s.doubleFocusedBorderColor ?? s.doubleBorderColor ?? s.getFocusedBorderColor;
    }
    if (hasError) {
      return s.doubleErrorBorderColor ?? s.doubleBorderColor ?? s.getErrorBorderColor;
    }
    return s.doubleBorderColor ?? s.getBorderColor;
  }

  Color _borderColor(bool hasError) {
    final s = widget.parent.theme;
    if (!widget.parent.enable) return s.getDisabledBorderColor;
    if (_focusNode.hasFocus) return s.getFocusedBorderColor;
    if (hasError) return s.getErrorBorderColor;
    return s.getBorderColor;
  }

  /// Builds the tappable country-prefix button on the left side of the field.
  Widget _prefix() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: ShapeBorder.lerp(
          null,
          RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(widget.parent.theme.borderRadius.topLeft.x),
              bottomLeft: Radius.circular(widget.parent.theme.borderRadius.bottomLeft.x),
            ),
          ),
          1,
        ),
        onTap: () => _showPrefixesList(),
        child: Container(
          height: widget.parent.theme.containerHeight,
          padding: EdgeInsets.only(left: 16),
          decoration: BoxDecoration(
            color: widget.parent.theme.fillColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(widget.parent.theme.borderRadius.topLeft.x),
              bottomLeft: Radius.circular(widget.parent.theme.borderRadius.bottomLeft.x),
            ),
          ),
          child: Row(
            spacing: 8,
            children: [
              FittedBox(
                child: Text(
                  buttonResult(
                    countryViewOptions: _config.countryViewOptions,
                    selectedCountry: _bloc.state.data.selectedCountry,
                  ),
                ),
              ),
              Icon(Icons.arrow_drop_down),
              Container(
                margin: EdgeInsets.only(right: 8),
                height: widget.parent.theme.containerHeight / 2,
                width: 1,
                color: const Color(0xFFD9D9D9),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Opens the country picker as a modal bottom sheet or dialog depending on
  /// [HybridPhoneTextFieldConfig.showDialog].
  void _showPrefixesList() async {
    return !_config.showDialog
        ? showModalBottomSheet(
            context: context,
            builder: (context) => _bodyModalBottomSheet(),
          )
        : showDialog(
            context: context,
            useRootNavigator: false,
            builder: (context) => StatefulBuilder(
              builder: (ctx, setState) => CountryPickerDialog(
                style: widget.parent.theme.dialogTheme,
                filteredCountries: _bloc.state.data.filteredCountries,
                countryList: _bloc.state.data.countries,
                selectedCountry: _bloc.state.data.selectedCountry,
                dialogTitle: 'Selecciona el prefijo del pais',
                onCountryChanged: (CountryEntity country) {
                  _bloc.add(HybridCustomPhoneTextFieldCountryChanged(country: country));
                },
              ),
            ),
          );
  }

  /// Builds the body of the modal bottom sheet that contains the country list.
  Widget _bodyModalBottomSheet() {
    return Container(
      decoration: BoxDecoration(
        color: widget.parent.theme.fillColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SizedBox(
              width: 40,
              height: 30,
              child: Divider(
                color: Colors.grey,
                thickness: 4,
                radius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 12, left: 14),
            child: const Text(
              "Selecciona el prefijo del país",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: CustomPhonePrefixesList(
              countries: _bloc.state.data.countries,
              selectedPrefix: _bloc.state.data.selectedCountry,
              config: widget.parent.config,
              style: widget.parent.theme.prefixesListTheme,
              onPrefixSelected: (country) {
                _bloc.add(HybridCustomPhoneTextFieldCountryChanged(country: country));
                widget.parent.onPrefixSelected;
              },
            ),
          ),
        ],
      ),
    );
  }

  String buttonResult({
    required CountryViewOptions countryViewOptions,
    required CountryEntity selectedCountry,
  }) {
    switch (countryViewOptions) {
      case CountryViewOptions.countryCodeOnly:
        return '+${selectedCountry.dialCode}';
      case CountryViewOptions.countryNameOnly:
        return selectedCountry.name;
      case CountryViewOptions.countryFlagOnly:
        return selectedCountry.flag;
      case CountryViewOptions.countryCodeWithFlag:
        return '${selectedCountry.flag} +${selectedCountry.dialCode}';
      case CountryViewOptions.countryNameWithFlag:
        return '${selectedCountry.flag} ${selectedCountry.name}';
    }
  }

  Widget _textfield(HybridCustomPhoneTextFieldState state) {
    return TextFormField(
      focusNode: _focusNode,
      controller: _controller,
      validator: (value) {
        if (state.data.hasError) {
          return state.data.errorMessage;
        }
        return null;
      },
      enabled: widget.parent.enable,
      textAlign: widget.parent.theme.textAlign,
      textAlignVertical: widget.parent.theme.textAlignVertical,
      keyboardType: TextInputType.phone,
      textInputAction: _config.textInputAction,
      cursorColor: widget.parent.theme.cursorColor,
      style: widget.parent.theme.textStyle.copyWith(
        color: widget.parent.enable ? widget.parent.theme.textColor : widget.parent.theme.disabledTextColor,
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
    );
  }

  InputDecoration _inputDecoration(HybridCustomPhoneTextFieldState state) {
    return InputDecoration(
      isDense: true,
      border: InputBorder.none,
      filled: true,
      fillColor: widget.parent.enable ? widget.parent.theme.fillColor : widget.parent.theme.disabledFillColor,
      error: _shouldShowError(state.data.hasError) ? const SizedBox.shrink() : null,
      hintTextDirection: widget.parent.theme.hintTextDirection,
      hintMaxLines: widget.parent.theme.hintMaxLines,
      enabled: widget.parent.enable,
      hintStyle: widget.parent.theme.hintStyle,
      prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
      suffixIcon: _suffixIcon(),
      labelText: widget.parent.label,
      suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      contentPadding: EdgeInsets.all(widget.parent.theme.containerHeight / 4),
      errorText: null,
      errorStyle: const TextStyle(height: 0, fontSize: 0),
    );
  }

  bool _shouldShowError(bool hasError) {
    if (!hasError) return false;
    if (_forceShowErrors) return true;
    if (!_isTouched) return false;
    if (!_config.shouldDisplayErrorWhenClicked) return true;
    return _focusNode.hasFocus;
  }

  Widget? _errorMessage(HybridCustomPhoneTextFieldState state) {
    if (!_shouldShowError(state.data.hasError)) return null;
    return SizedBox(
      height: 16,
      child: Text(state.data.errorMessage!, style: widget.parent.theme.errorStyle),
    );
  }

  Widget? _suffixIcon() {
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
}
