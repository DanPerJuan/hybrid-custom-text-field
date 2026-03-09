import 'country_picker_dialog_theme.dart';
import 'custom_prefixes_list_theme.dart';
import 'hybrid_text_field_theme.dart';

/// Visual theme for [HybridCustomPhoneTextField].
///
/// Extends [HybridTextFieldTheme] with phone-specific sub-themes.
class HybridPhoneTextFieldTheme extends HybridTextFieldTheme {
  final CustomPrefixesListTheme prefixesListTheme;
  final CountryPickerDialogTheme dialogTheme;

  const HybridPhoneTextFieldTheme({
    super.textStyle,
    super.hintStyle,
    super.supportingTextStyle,
    super.descriptionStyle,
    super.errorStyle,
    super.textColor,
    super.disabledTextColor,
    super.labelColor,
    super.focusedLabelColor,
    super.errorLabelColor,
    super.supportingTextColor,
    super.errorTextColor,
    super.descriptionColor,
    super.cursorColor,
    super.fillColor,
    super.disabledFillColor,
    super.borderColor,
    super.focusedBorderColor,
    super.disabledBorderColor,
    super.errorBorderColor,
    super.borderWidth,
    super.focusedBorderWidth,
    super.borderRadius,
    super.doubleBorderColor,
    super.doubleFocusedBorderColor,
    super.doubleErrorBorderColor,
    super.doubleBorderWidth,
    super.doubleBorderRadius,
    super.showDoubleBorderOnFocus,
    super.showDoubleBorderOnError,
    super.contentPadding,
    super.descriptionSpacing,
    super.supportingTextSpacing,
    super.hintTextDirection,
    super.hintMaxLines,
    super.textAlign,
    super.textAlignVertical,
    super.containerHeight,
    this.prefixesListTheme = const CustomPrefixesListTheme(),
    this.dialogTheme = const CountryPickerDialogTheme(),
  });
}
