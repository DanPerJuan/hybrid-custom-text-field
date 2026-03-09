import 'models/configs/hybrid_base_text_field_config.dart';
import 'models/configs/hybrid_phone_text_field_config.dart';
import 'models/configs/hybrid_search_text_field_config.dart';
import 'theme/hybrid_phone_text_field_theme.dart';
import 'theme/hybrid_search_text_field_theme.dart';
import 'theme/hybrid_text_field_theme.dart';

export 'theme/country_picker_dialog_theme.dart';
export 'theme/custom_prefixes_list_theme.dart';
export 'theme/hybrid_phone_text_field_theme.dart';
export 'theme/hybrid_search_text_field_theme.dart';
export 'theme/hybrid_text_field_theme.dart';

/// Singleton class providing global theme and config defaults
/// for hybrid text fields.
class HybridTextField {
  /// Private constructor to prevent instantiation.
  HybridTextField._();

  // ── Themes ──────────────────────────────────────────────────────────────────

  static HybridTextFieldTheme _theme = HybridTextFieldTheme();
  static HybridPhoneTextFieldTheme _phoneTheme = HybridPhoneTextFieldTheme();
  static HybridSearchTextFieldTheme _searchTheme = HybridSearchTextFieldTheme();

  // ── Configs ─────────────────────────────────────────────────────────────────

  static HybridBaseTextFieldConfig _baseConfig = HybridBaseTextFieldConfig();
  static HybridPhoneTextFieldConfig _phoneConfig = HybridPhoneTextFieldConfig();
  static HybridSearchTextFieldConfig _searchConfig = HybridSearchTextFieldConfig();

  /// Overrides the global defaults for themes and/or configs.
  ///
  /// Only non-null arguments are applied; others keep their current values.
  static void config({
    HybridTextFieldTheme? theme,
    HybridPhoneTextFieldTheme? phoneTheme,
    HybridSearchTextFieldTheme? searchTheme,
    HybridBaseTextFieldConfig? baseConfig,
    HybridPhoneTextFieldConfig? phoneConfig,
    HybridSearchTextFieldConfig? searchConfig,
  }) {
    if (theme != null) _theme = theme;
    if (phoneTheme != null) _phoneTheme = phoneTheme;
    if (searchTheme != null) _searchTheme = searchTheme;
    if (baseConfig != null) _baseConfig = baseConfig;
    if (phoneConfig != null) _phoneConfig = phoneConfig;
    if (searchConfig != null) _searchConfig = searchConfig;
  }

  /// Returns the current global theme for text fields.
  static HybridTextFieldTheme get theme => _theme;

  /// Returns the current theme for phone number text fields.
  static HybridPhoneTextFieldTheme get phoneTheme => _phoneTheme;

  /// Returns the current theme for search text fields.
  static HybridSearchTextFieldTheme get searchTheme => _searchTheme;

  /// Returns the current global config for base text fields.
  static HybridBaseTextFieldConfig get baseConfig => _baseConfig;

  /// Returns the current global config for phone text fields.
  static HybridPhoneTextFieldConfig get phoneConfig => _phoneConfig;

  /// Returns the current global config for search text fields.
  static HybridSearchTextFieldConfig get searchConfig => _searchConfig;
}
