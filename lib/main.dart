import 'package:flutter/material.dart';
import 'screens/onboardingscreen.dart';

void main() {
  runApp(const DriverOnboardingApp());
}

class DriverOnboardingApp extends StatefulWidget {
  const DriverOnboardingApp({Key? key}) : super(key: key);

  @override
  State<DriverOnboardingApp> createState() => _DriverOnboardingAppState();
}

class _DriverOnboardingAppState extends State<DriverOnboardingApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Driver Onboarding',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.light),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: OnboardingScreen(
        onToggleTheme: _toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark,
      ),
    );
  }
}