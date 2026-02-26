/// Represents a country with relevant phone and region information.
///
/// This entity is used for phone input fields, country pickers, and
/// formatting/displaying international dialing codes.
class CountryEntity {
  /// The full name of the country, e.g., "United States".
  String name;

  /// The emoji flag representing the country, e.g., "🇺🇸".
  String flag;

  /// The ISO country code, e.g., "US".
  String code;

  /// The international dialing code, e.g., "1" for the United States.
  String dialCode;

  /// The optional region code for more specific dialing, e.g., "CA" for California.
  String regionCode;

  /// The minimum length allowed for phone numbers in this country.
  int minLength;

  /// The maximum length allowed for phone numbers in this country.
  int maxLength;

  /// Creates a [CountryEntity] with required country information.
  ///
  /// [name], [flag], [code], [dialCode], [minLength], and [maxLength] are required.
  /// [regionCode] is optional and defaults to an empty string.
  CountryEntity({
    required this.name,
    required this.flag,
    required this.code,
    required this.dialCode,
    required this.minLength,
    required this.maxLength,
    this.regionCode = '',
  });

  /// Returns the full country code including [dialCode] and [regionCode].
  ///
  /// For example, if dialCode is "1" and regionCode is "CA", returns "1CA".
  String get fullCountryCode {
    return dialCode + regionCode;
  }

  /// Returns a display-friendly version of the country code.
  ///
  /// If [regionCode] is not empty, returns "dialCode regionCode" (e.g., "1 CA").
  /// Otherwise, returns just [dialCode].
  String get displayCC {
    if (regionCode != '') {
      return '$dialCode $regionCode';
    }
    return dialCode;
  }
}
