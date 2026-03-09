import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hybrid_custom_text_field/hybrid_custom_text_field.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'layers/presentation/app/container_app.dart';

void main() async {
  await _initialize();

  // ── Global config (Phase 2) ──────────────────────────────────────────────
  // These values apply to every field unless overridden at widget level.
  HybridTextField.config(
    // Base config: errors shown only while the field has focus
    baseConfig: HybridBaseTextFieldConfig(
      shouldDisplayErrorWhenClicked: false,
      textInputAction: TextInputAction.next,
    ),
    // Phone config: flag + dial code prefix in all phone fields by default
    phoneConfig: HybridPhoneTextFieldConfig(
      shouldDisplayErrorWhenClicked: true,
      countryViewOptions: CountryViewOptions.countryCodeWithFlag,
    ),
    // Search config: alphabetical sort by default
    searchConfig: HybridSearchTextFieldConfig(
      shouldDisplayErrorWhenClicked: true,
      sortOrder: SearchSortOrder.alphabetical,
    ),

    // ── Global themes ────────────────────────────────────────────────────────
    theme: HybridTextFieldTheme(
      borderColor: const Color(0xFFD1D5DB),
      borderRadius: BorderRadius.circular(12),
      focusedBorderColor: const Color(0xFF2563EB),
      focusedBorderWidth: 2,
      errorBorderColor: const Color(0xFFEF4444),
      doubleFocusedBorderColor: const Color(0xFF93C5FD),
      doubleErrorBorderColor: const Color(0xFFFCA5A5),
      doubleBorderWidth: 2,
    ),
    phoneTheme: HybridPhoneTextFieldTheme(
      borderColor: const Color(0xFFD1D5DB),
      borderRadius: BorderRadius.circular(12),
      focusedBorderColor: const Color(0xFF2563EB),
      focusedBorderWidth: 2,
      errorBorderColor: const Color(0xFFEF4444),
      doubleFocusedBorderColor: const Color(0xFF93C5FD),
      doubleErrorBorderColor: const Color(0xFFFCA5A5),
      doubleBorderWidth: 2,
      containerHeight: 58,
      prefixesListTheme: CustomPrefixesListTheme(
        radioColor: const Color(0xFF2563EB),
      ),
    ),
    searchTheme: HybridSearchTextFieldTheme(
      borderColor: const Color(0xFFD1D5DB),
      borderRadius: BorderRadius.circular(12),
      focusedBorderColor: const Color(0xFF2563EB),
      focusedBorderWidth: 2,
      errorBorderColor: const Color(0xFFEF4444),
      containerHeight: 58,
      shouldShowDivider: true,
    ),
  );

  runApp(const ContainerApp());
}

Future<void> _initialize() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await initializeDateFormatting();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  Animate.restartOnHotReload = true;
}
