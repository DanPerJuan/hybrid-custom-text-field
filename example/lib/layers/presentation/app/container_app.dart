import 'package:flutter/material.dart';
import 'default_home.dart';

class ContainerApp extends StatefulWidget {
  const ContainerApp({super.key});

  @override
  State<ContainerApp> createState() => _ContainerAppState();
}

class _ContainerAppState extends State<ContainerApp> {
  late ThemeMode themeMode;

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  void _initialize() {
    themeMode = ThemeMode.system;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: _defaultHome(),
    );
  }

  Widget _defaultHome() {
    return const DefaultHome();
  }
}
