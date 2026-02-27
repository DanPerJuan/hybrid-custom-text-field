import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../hybrid_custom_text_field.dart';
import '../../bloc/hybrid_custom_text_field_bloc.dart';
import 'county_picker_dialog.dart';
import 'custom_phone_prefixes_list.dart';

/// A phone number input field with a country-prefix selector.
///
/// The field combines a tappable prefix button (showing the selected country's
/// dial code, flag, or name according to [HybridPhoneTextFieldConfig.countryViewOptions])
/// with a plain number input. Tapping the prefix opens a country picker either
/// as a modal bottom sheet (default) or as a dialog, controlled by [showDialog].
///
/// The field is backed by an internal [HybridCustomTextFieldBloc] that:
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
class HybridCustomPhoneTextField extends StatelessWidget {
  /// Floating label displayed inside the [InputDecoration].
  final String? label;

  /// Supporting text rendered below the field when there is no error.
  final String? bottom;

  /// Descriptive text rendered above the field.
  /// Color switches to [HybridTextFieldStyle.errorTextColor] on error.
  final String? info;

  /// Optional external controller. An internal instance is created when `null`.
  final TextEditingController? controller;

  /// Optional override of the full country list used in the prefix picker.
  /// Defaults to [CountriesHelper.countries] when `null`.
  final List<CountryEntity>? countries;

  /// Country pre-selected when the field mounts. When `null`, the first
  /// country in the list is used.
  final CountryEntity? selectedCountry;

  /// Called when the user picks a new country prefix from the picker.
  final Function(CountryEntity country)? onPrefixSelected;

  /// Called on every keystroke with the current field value.
  final ValueChanged<String>? onChanged;

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
  /// Falls back to [HybridTextField.phoneConfig] when not provided.
  final HybridPhoneTextFieldConfig config;

  /// Visual style tokens (colors, borders, typography, etc.).
  /// Falls back to [HybridTextField.style] when not provided.
  final HybridTextFieldStyle style;

  /// Optional external [FocusNode] for the phone number input.
  /// An internal node is created when `null`.
  final FocusNode? focusNode;

  /// Fixed height of the field container in logical pixels. Defaults to `62`.
  final double containerHeight;

  /// Creates a [HybridCustomPhoneTextField].
  HybridCustomPhoneTextField({
    super.key,
    this.label,
    this.bottom,
    this.info,
    this.controller,
    this.countries,
    this.selectedCountry,
    this.onPrefixSelected,
    this.onChanged,
    this.onTap,
    this.onTapOutside,
    this.enable = true,
    this.suffixIcon,
    this.focusNode,
    HybridPhoneTextFieldConfig? config,
    HybridTextFieldStyle? style,
    this.containerHeight = 62,
  }) : style = style ?? HybridTextField.style,
       config = config ?? HybridTextField.phoneConfig;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Provide an isolated bloc instance. HybridCustomTextFieldPhoneStarted
      // loads the country list and validation rules.
      create: (context) =>
          HybridCustomTextFieldBloc(config: config)
            ..add(HybridCustomTextFieldPhoneStarted(selectedCountry: selectedCountry)),
      child: _CustomPhoneTextFieldView(parent: this),
    );
  }
}

class _CustomPhoneTextFieldView extends StatefulWidget {
  final HybridCustomPhoneTextField parent;

  const _CustomPhoneTextFieldView({required this.parent});

  @override
  State<_CustomPhoneTextFieldView> createState() => _CustomPhoneTextFieldViewState();
}

class _CustomPhoneTextFieldViewState extends State<_CustomPhoneTextFieldView> {
  /// Focus node for the phone number input.
  late final FocusNode _focusNode;

  /// Stores the pointer-down position to distinguish real taps from drags.
  Offset _lastTapPosition = Offset.zero;

  /// Shortcut to the bloc without subscribing to rebuilds.
  HybridCustomTextFieldBloc get _bloc => context.read<HybridCustomTextFieldBloc>();

  /// Controller — either provided by the parent or created locally.
  late TextEditingController _controller;

  @override
  void initState() {
    _focusNode = widget.parent.focusNode ?? FocusNode();
    _controller = widget.parent.controller ?? TextEditingController();
    // Rebuild on focus changes so the border color updates immediately.
    _focusNode.addListener(_onFocusChange);
    // Rebuild when text changes so the suffix icon can react.
    _controller.addListener(() => setState(() {}));
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
    return BlocListener<HybridCustomTextFieldBloc, HybridCustomTextFieldState>(
      listener: (context, state) {
        _controller;
      },
      child: BlocBuilder<HybridCustomTextFieldBloc, HybridCustomTextFieldState>(
        builder: (context, state) {
          return Column(
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
                child: _phoneField(state),
              ),
              if (widget.parent.bottom != null) _bottomMessage(),
              ?_errorMessage(state),
            ],
          );
        },
      ),
    );
  }

  /// Renders the [info] label above the field.
  Widget _info({required bool hasError}) {
    return Text(
      widget.parent.info!,
      style: widget.parent.style.descriptionStyle.copyWith(
        color: hasError ? widget.parent.style.errorTextColor : widget.parent.style.descriptionColor,
      ),
    );
  }

  /// Builds the phone field container: an [AnimatedContainer] for the optional
  /// double-border, wrapping a [Row] with the prefix button and the text input.
  Widget _phoneField(HybridCustomTextFieldState state) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: _shouldShowDouble(state.data.hasError)
          ? BoxDecoration(
              borderRadius: widget.parent.style.resolvedDoubleBorderRadius,
              border: Border.all(
                color: _doubleColor(state.data.hasError),
                width: widget.parent.style.doubleBorderWidth,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
            )
          : const BoxDecoration(),
      child: Container(
        height: widget.parent.containerHeight + 2,
        decoration: BoxDecoration(
          color: widget.parent.style.fillColor,
          border: Border.all(color: _borderColor(state.data.hasError), width: 1),
          borderRadius: widget.parent.style.borderRadius,
        ),
        child: Row(
          children: [
            _prefix(),
            Expanded(
              child: Container(
                height: widget.parent.containerHeight - 3,
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

  /// Returns `true` when the outer double-border decoration should be visible.
  bool _shouldShowDouble(bool hasError) {
    final s = widget.parent.style;
    if (!widget.parent.enable) return s.doubleBorderColor != null;
    if (_focusNode.hasFocus) {
      return s.doubleFocusedBorderColor != null || s.doubleBorderColor != null;
    }
    if (hasError) {
      return s.doubleErrorBorderColor != null || s.doubleBorderColor != null;
    }
    return s.doubleBorderColor != null;
  }

  /// Resolves the outer double-border color.
  Color _doubleColor(bool hasError) {
    final s = widget.parent.style;
    if (!widget.parent.enable) return s.doubleBorderColor ?? s.getDisabledBorderColor;
    if (_focusNode.hasFocus) {
      return s.doubleFocusedBorderColor ?? s.doubleBorderColor ?? s.getFocusedBorderColor;
    }
    if (hasError) {
      return s.doubleErrorBorderColor ?? s.doubleBorderColor ?? s.getErrorBorderColor;
    }
    return s.doubleBorderColor ?? s.getBorderColor;
  }

  /// Resolves the inner border color of the phone container based on state.
  Color _borderColor(bool hasError) {
    final s = widget.parent.style;
    if (!widget.parent.enable) return s.getDisabledBorderColor;
    if (_focusNode.hasFocus) return s.getFocusedBorderColor;
    if (hasError) return s.getErrorBorderColor;
    return s.getBorderColor;
  }

  /// Builds the tappable country-prefix button on the left side of the field.
  ///
  /// Displays the selected country using [buttonResult] according to
  /// [HybridPhoneTextFieldConfig.countryViewOptions]. Tapping opens the
  /// country picker via [_showPrefixesList].
  Widget _prefix() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: ShapeBorder.lerp(
          null,
          RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(widget.parent.style.borderRadius.topLeft.x),
              bottomLeft: Radius.circular(widget.parent.style.borderRadius.bottomLeft.x),
            ),
          ),
          1,
        ),
        onTap: () => _showPrefixesList(),
        child: Container(
          height: widget.parent.containerHeight,
          padding: EdgeInsets.only(left: 16),
          decoration: BoxDecoration(
            color: widget.parent.style.fillColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(widget.parent.style.borderRadius.topLeft.x),
              bottomLeft: Radius.circular(widget.parent.style.borderRadius.bottomLeft.x),
            ),
          ),
          child: Row(
            spacing: 8,
            children: [
              FittedBox(
                child: Text(
                  buttonResult(
                    countryViewOptions: widget.parent.config.countryViewOptions,
                    selectedCountry: _bloc.state.data.selectedCountry,
                  ),
                ),
              ),
              Icon(Icons.arrow_drop_down),
              Container(
                margin: EdgeInsets.only(right: 8),
                height: widget.parent.containerHeight / 2,
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
  /// [HybridCustomPhoneTextField.showDialog].
  void _showPrefixesList() async {
    return !widget.parent.config.showDialog
        ? showModalBottomSheet(
            context: context,
            builder: (context) => _bodyModalBottomSheet(),
          )
        : showDialog(
            context: context,
            useRootNavigator: false,
            builder: (context) => StatefulBuilder(
              builder: (ctx, setState) => CountryPickerDialog(
                filteredCountries: _bloc.state.data.filteredCountries,
                countryList: _bloc.state.data.countries,
                selectedCountry: _bloc.state.data.selectedCountry,
                dialogBackgroundColor: widget.parent.style.fillColor,
                dialogTitle: 'Selecciona el prefijo del pais',
                searchTextStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                onCountryChanged: (CountryEntity country) {
                  _bloc.add(HybridCustomTextFieldCountryChanged(country: country));
                },
              ),
            ),
          );
  }

  /// Builds the body of the modal bottom sheet that contains the country list.
  Widget _bodyModalBottomSheet() {
    return Container(
      decoration: BoxDecoration(
        color: widget.parent.style.fillColor,
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
              onPrefixSelected: (country) {
                _bloc.add(HybridCustomTextFieldCountryChanged(country: country));
                widget.parent.onPrefixSelected;
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Converts the [selectedCountry] to a display string based on
  /// [countryViewOptions].
  ///
  /// | Option | Example |
  /// |---|---|
  /// | countryCodeOnly | `+34` |
  /// | countryNameOnly | `Spain` |
  /// | countryFlagOnly | `🇪🇸` |
  /// | countryCodeWithFlag | `🇪🇸 +34` |
  /// | countryNameWithFlag | `🇪🇸 Spain` |
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

  /// Builds the phone number [TextFormField] without any border decoration
  /// (borders are handled by [_phoneField]).
  Widget _textfield(HybridCustomTextFieldState state) {
    return TextFormField(
      focusNode: _focusNode,
      controller: _controller,
      // Surfaces the bloc error message so Form.validate() works correctly.
      validator: (value) {
        if (state.data.hasError) {
          return state.data.errorMessage;
        }
        return null;
      },
      enabled: widget.parent.enable,
      textAlign: widget.parent.style.textAlign,
      textAlignVertical: widget.parent.style.textAlignVertical,
      keyboardType: TextInputType.phone,
      textInputAction: widget.parent.config.textInputAction,
      cursorColor: widget.parent.style.cursorColor,
      style: widget.parent.style.textStyle.copyWith(
        color: widget.parent.enable ? widget.parent.style.textColor : widget.parent.style.disabledTextColor,
      ),
      onChanged: (value) {
        _bloc.add(HybridCustomTextFieldChanged(value: value));
        widget.parent.onChanged?.call(value);
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

  /// Builds the [InputDecoration] for the phone input — borderless, since
  /// the outer [_phoneField] container draws the border.
  InputDecoration _inputDecoration(HybridCustomTextFieldState state) {
    return InputDecoration(
      isDense: true,
      border: InputBorder.none,
      filled: true,
      fillColor: widget.parent.enable ? widget.parent.style.fillColor : widget.parent.style.disabledFillColor,
      error: state.data.hasError ? const SizedBox.shrink() : null,
      hintTextDirection: widget.parent.style.hintTextDirection,
      hintMaxLines: widget.parent.style.hintMaxLines,
      enabled: widget.parent.enable,
      hintStyle: widget.parent.style.hintStyle,
      prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
      suffixIcon: _suffixIcon(),
      labelText: widget.parent.label,
      suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      contentPadding: EdgeInsets.all(widget.parent.containerHeight / 4),
      errorText: null,
      errorStyle: const TextStyle(height: 0, fontSize: 0),
    );
  }

  /// Renders the validation error message below the field.
  ///
  /// Visibility follows [HybridPhoneTextFieldConfig.shouldDisplayErrorWhenClicked]:
  /// - `false` → always visible when there is an active error.
  /// - `true`  → visible only while the field has focus.
  Widget? _errorMessage(HybridCustomTextFieldState state) {
    return state.data.hasError && !widget.parent.config.shouldDisplayErrorWhenClicked ||
            state.data.hasError && widget.parent.config.shouldDisplayErrorWhenClicked && _focusNode.hasFocus
        ? SizedBox(
            height: 16,
            child: Text(state.data.errorMessage!, style: widget.parent.style.errorStyle),
          )
        : null;
  }

  /// Trailing icon for the phone number input.
  Widget? _suffixIcon() {
    if (widget.parent.suffixIcon != null) return widget.parent.suffixIcon;
    return null;
  }

  /// Supporting text shown below the field when there is no error.
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
}
