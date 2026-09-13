import 'package:flutter/material.dart';

/// Shared gain/loss colors used across summary cards, ticker chips, and
/// holdings rows so green/red semantics stay consistent everywhere.
class AppSemanticColors {
  final Color gain;
  final Color loss;
  final Color neutral;
  final Color gainSurface;
  final Color lossSurface;

  const AppSemanticColors({
    required this.gain,
    required this.loss,
    required this.neutral,
    required this.gainSurface,
    required this.lossSurface,
  });

  static const light = AppSemanticColors(
    gain: Color(0xFF15803D),
    loss: Color(0xFFDC2626),
    neutral: Color(0xFF6B7280),
    gainSurface: Color(0xFFE7F6EC),
    lossSurface: Color(0xFFFCEAEA),
  );

  static const dark = AppSemanticColors(
    gain: Color(0xFF4ADE80),
    loss: Color(0xFFFF6B6B),
    neutral: Color(0xFF9CA3AF),
    gainSurface: Color(0xFF15321F),
    lossSurface: Color(0xFF3A1B1E),
  );
}

class AppTheme {
  AppTheme._();

  static const _seed = Color(0xFF4C5FF7);
  static const _radius = 18.0;

  static ThemeData light() {
    // Explicitly pin surfaceContainerLow (what cards/rows are painted with)
    // to pure white rather than trusting the seed-generated tonal palette —
    // ColorScheme.fromSeed can land it close enough to the scaffold
    // background that cards visually disappear.
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
    ).copyWith(surfaceContainerLow: Colors.white);
    return _base(scheme, const Color(0xFFF0F1FA), Colors.black);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
      surface: const Color(0xFF14151F),
    ).copyWith(surfaceContainerLow: const Color(0xFF1A1C29));
    return _base(scheme, const Color(0xFF0B0C13), Colors.black);
  }

  static ThemeData _base(ColorScheme scheme, Color background, Color shadowColor) {
    final textTheme = _textTheme(scheme);
    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      splashFactory: InkSparkle.splashFactory,
      textTheme: textTheme,
      visualDensity: VisualDensity.standard,
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shadowColor: shadowColor.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        selectedColor: scheme.primary,
        labelStyle: textTheme.labelLarge,
        secondaryLabelStyle: textTheme.labelLarge?.copyWith(color: scheme.onPrimary),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        ),
      ),
      iconTheme: IconThemeData(color: scheme.onSurfaceVariant),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static TextTheme _textTheme(ColorScheme scheme) {
    final base = Typography.material2021(colorScheme: scheme).black;
    return base.copyWith(
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.2),
      bodyMedium: base.bodyMedium?.copyWith(height: 1.4),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    ).apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
  }

  static const radius = _radius;
}
