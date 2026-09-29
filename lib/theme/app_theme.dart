import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// Font families bundled with the app (see `pubspec.yaml`).
const String kBodyFont = 'Poppins';
const String kDisplayFont = 'Fredoka';

TextStyle _display({
  required double size,
  FontWeight weight = FontWeight.w600,
  Color color = Colors.black,
  double? height,
  double letterSpacing = -0.2,
}) =>
    TextStyle(
      fontFamily: kDisplayFont,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontVariations: const [FontVariation('wght', 600)],
    );

TextStyle _body({
  required double size,
  FontWeight weight = FontWeight.w400,
  Color color = Colors.black,
  double? height,
  double letterSpacing = 0,
}) =>
    TextStyle(
      fontFamily: kBodyFont,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );

class AppTheme {
  static ThemeData get light {
    const ColorScheme scheme = ColorScheme.light(
      primary: brandPrimary,
      onPrimary: Colors.white,
      primaryContainer: brandPrimarySoft,
      onPrimaryContainer: brandPrimaryDark,
      secondary: brandSecondary,
      onSecondary: Colors.white,
      secondaryContainer: brandSecondarySoft,
      onSecondaryContainer: Color(0xFF00695A),
      tertiary: brandAccent,
      onTertiary: Colors.white,
      error: Color(0xFFE04F5F),
      onError: Colors.white,
      surface: surfaceLight,
      onSurface: Color(0xFF1B1A2E),
      onSurfaceVariant: Color(0xFF6B6A80),
      outline: Color(0xFFD9D6EC),
      outlineVariant: Color(0xFFEDEBF7),
    );

    return _base(scheme, scaffoldBackgroundLight).copyWith(
      textTheme: _textTheme(const Color(0xFF1B1A2E)),
    );
  }

  static ThemeData get dark {
    const ColorScheme scheme = ColorScheme.dark(
      primary: Color(0xFFB7A5FF),
      onPrimary: Color(0xFF241046),
      primaryContainer: Color(0xFF3A2C6B),
      onPrimaryContainer: Color(0xFFE7DEFF),
      secondary: Color(0xFF5FE6D0),
      onSecondary: Color(0xFF00382F),
      secondaryContainer: Color(0xFF11534A),
      onSecondaryContainer: Color(0xFFB6FFF2),
      tertiary: Color(0xFFFF9A9A),
      onTertiary: Color(0xFF5A0B0B),
      error: Color(0xFFFF8A80),
      onError: Color(0xFF3A0906),
      surface: surfaceDark,
      onSurface: Color(0xFFECE9FA),
      onSurfaceVariant: Color(0xFFB4B0CC),
      outline: Color(0xFF3A3757),
      outlineVariant: Color(0xFF2A2842),
    );

    return _base(scheme, scaffoldBackgroundDark).copyWith(
      textTheme: _textTheme(const Color(0xFFECE9FA)),
    );
  }

  static ThemeData _base(ColorScheme scheme, Color scaffold) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      fontFamily: kBodyFont,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: scaffold,
        foregroundColor: scheme.onSurface,
        titleTextStyle: _display(size: 20, color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1.2,
        space: 1.2,
      ),
      iconTheme: IconThemeData(color: scheme.onSurfaceVariant),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: _body(size: 14, color: scheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 1.8),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          textStyle: _body(size: 15, weight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: _body(size: 14, weight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.outline),
          textStyle: _body(size: 14, weight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surface,
        selectedColor: scheme.primaryContainer,
        side: BorderSide(color: scheme.outlineVariant),
        labelStyle: _body(size: 13, weight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.onSurface,
        contentTextStyle: _body(size: 14, color: scheme.surface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: _body(size: 15, weight: FontWeight.w500),
        iconColor: scheme.onSurfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.outlineVariant,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.onSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: _body(size: 12, color: scheme.surface),
      ),
    );
  }

  static TextTheme _textTheme(Color onSurface) {
    return TextTheme(
      displayLarge: _display(size: 40, color: onSurface, letterSpacing: -1),
      displayMedium: _display(size: 32, color: onSurface, letterSpacing: -0.8),
      displaySmall: _display(size: 28, color: onSurface, letterSpacing: -0.6),
      headlineLarge:
          _display(size: 26, color: onSurface, weight: FontWeight.w600),
      headlineMedium: _display(size: 22, color: onSurface),
      headlineSmall: _display(size: 19, color: onSurface),
      titleLarge: _body(size: 18, weight: FontWeight.w600, color: onSurface),
      titleMedium: _body(size: 15.5, weight: FontWeight.w600, color: onSurface),
      titleSmall: _body(size: 14, weight: FontWeight.w600, color: onSurface),
      bodyLarge: _body(size: 15, color: onSurface, height: 1.45),
      bodyMedium: _body(size: 13.5, color: onSurface, height: 1.45),
      bodySmall: _body(size: 12, color: onSurface, height: 1.4),
      labelLarge: _body(size: 14, weight: FontWeight.w600, color: onSurface),
      labelMedium: _body(size: 12.5, weight: FontWeight.w500, color: onSurface),
      labelSmall: _body(size: 11, weight: FontWeight.w500, color: onSurface),
    );
  }
}

/// Exposed for widgets that need the same "Fredoka" display face.
TextStyle displayStyle(double size, {Color? color, FontWeight weight = FontWeight.w600}) =>
    _display(size: size, color: color ?? Colors.black, weight: weight);
