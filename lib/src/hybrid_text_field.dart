import '../hybrid_custom_text_field.dart';

/// Singleton class providing global configuration and styles
/// for hybrid text fields in init.
class HybridTextField {
  /// Private constructor to prevent instantiation.
  HybridTextField._();

  /// Default global style for text fields.
  static HybridTextFieldStyle _style = HybridTextFieldStyle();

  /// Default base configuration for simple text fields.
  static HybridBaseTextFieldConfig _baseConfig = HybridBaseTextFieldConfig();

  /// Default configuration for phone number text fields.
  static HybridPhoneTextFieldConfig _phoneConfig = HybridPhoneTextFieldConfig();

  /// Default configuration for search text fields.
  static HybridSearchTextFieldConfig _searchConfig = HybridSearchTextFieldConfig();

  /// Allows overriding the global configuration of hybrid text fields.
  ///
  /// [style] – Global visual style.
  /// [baseConfig] – Configuration for simple text fields.
  /// [phoneConfig] – Configuration for phone number fields.
  /// [searchConfig] – Configuration for search fields.
  static void config({
    HybridTextFieldStyle? style,
    HybridBaseTextFieldConfig? baseConfig,
    HybridPhoneTextFieldConfig? phoneConfig,
    HybridSearchTextFieldConfig? searchConfig,
  }) {
    if (style != null) _style = style;
    if (baseConfig != null) _baseConfig = baseConfig;
    if (phoneConfig != null) _phoneConfig = phoneConfig;
    if (searchConfig != null) _searchConfig = searchConfig;
  }

  /// Returns the current global style for text fields.
  static HybridTextFieldStyle get style => _style;

  /// Returns the current base configuration for simple text fields.
  static HybridBaseTextFieldConfig get baseConfig => _baseConfig;

  /// Returns the current configuration for phone number text fields.
  static HybridPhoneTextFieldConfig get phoneConfig => _phoneConfig;

  /// Returns the current configuration for search text fields.
  static HybridSearchTextFieldConfig get searchConfig => _searchConfig;
}
