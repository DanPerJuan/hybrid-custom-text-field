import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hybrid_custom_text_field/hybrid_custom_text_field.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'layers/presentation/app/container_app.dart';

void main() async {
  await _initialize();

  HybridTextField.config(
    style: HybridTextFieldStyle(
      labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey),
      borderColor: Colors.black,
      doubleBorderWidth: 2,
      doubleBorderRadius: 20,
      doubleFocusedBorderColor: Colors.lightBlue,
      focusedBorderColor: Colors.blueGrey,
      errorBorderColor: Colors.red[900],
      doubleErrorBorderColor: Colors.red,
      borderRadius: BorderRadius.circular(30),
    ),
    baseConfig: HybridBaseTextFieldConfig(),
    phoneConfig: HybridPhoneTextFieldConfig(),
  );

  runApp(
    ContainerApp(),
  );
}

/// Initialize application
Future<void> _initialize() async {
  /// Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  /// Set device orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await initializeDateFormatting();

  /// Set system UI mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  /// Restart animations on hot reload
  Animate.restartOnHotReload = true;
}
