import 'package:flutter/material.dart';

/// Shared gain/loss colors used across summary cards, ticker chips, and
/// holdings rows so green/red semantics stay consistent everywhere.
class AppSemanticColors {
  final Color gain;
  final Color loss;
  final Color neutral;

  const AppSemanticColors({
    required this.gain,
    required this.loss,
    required this.neutral,
  });

  static const light = AppSemanticColors(
    gain: Color(0xFF17803D),
    loss: Color(0xFFD62839),
    neutral: Color(0xFF6B7280),
  );

  static const dark = AppSemanticColors(
    gain: Color(0xFF3DDC84),
    loss: Color(0xFFFF6B6B),
    neutral: Color(0xFF9CA3AF),
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData light() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B5BFD),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B5BFD),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F1115),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
      );
}
