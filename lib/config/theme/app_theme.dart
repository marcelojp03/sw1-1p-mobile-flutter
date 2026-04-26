import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ===== Colores de marca =====
  static const Color primaryColor = Color(0xFF4F46E5); // Indigo profesional
  static const Color secondaryColor = Color(0xFF0EA5E9); // Sky blue
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF22C55E);
  static const Color warningColor = Color(0xFFF59E0B);

  // Superficies
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color surfaceCardLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF0F172A);
  static const Color surfaceCardDark = Color(0xFF1E293B);

  // Gradiente principal
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, secondaryColor],
  );

  // Colores auxiliares para inputs
  static const Color grey1 = Color(0xFF94A3B8);
  static const Color greyInputBg = Color(0xFFF1F5F9);
  static const Color bodyFontColor = Color(0xFF1E293B);

  // ===== Tema claro =====
  static ThemeData lightTheme() {
    return FlexThemeData.light(
      colors: const FlexSchemeColor(
        primary: primaryColor,
        primaryContainer: Color(0xFFE0E7FF),
        secondary: secondaryColor,
        secondaryContainer: Color(0xFFBAE6FD),
        tertiary: Color(0xFF6366F1),
        tertiaryContainer: Color(0xFFEEF2FF),
        error: errorColor,
      ),
      useMaterial3: true,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 6,
      visualDensity: VisualDensity.standard,
      scaffoldBackground: surfaceLight,
      surface: surfaceCardLight,
      appBarStyle: FlexAppBarStyle.background,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
        bottomNavigationBarMutedUnselectedLabel: false,
        bottomNavigationBarMutedUnselectedIcon: false,
        bottomNavigationBarShowSelectedLabels: true,
        bottomNavigationBarShowUnselectedLabels: true,
        bottomNavigationBarType: BottomNavigationBarType.fixed,
        bottomNavigationBarBackgroundSchemeColor: SchemeColor.surface,
        bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        bottomNavigationBarUnselectedLabelSchemeColor: SchemeColor.onSurface,
        bottomNavigationBarSelectedIconSchemeColor: SchemeColor.primary,
        bottomNavigationBarUnselectedIconSchemeColor: SchemeColor.onSurface,
        cardRadius: 14.0,
        elevatedButtonRadius: 12.0,
        filledButtonRadius: 12.0,
        outlinedButtonRadius: 12.0,
        textButtonRadius: 12.0,
        inputDecoratorRadius: 10.0,
        fabRadius: 16.0,
        chipRadius: 8.0,
        dialogRadius: 18.0,
        snackBarRadius: 8.0,
        tabBarIndicatorWeight: 3.0,
        tabBarIndicatorTopRadius: 3.0,
        tabBarDividerColor: Colors.transparent,
      ),
      keyColors: const FlexKeyColors(
        useSecondary: true,
        useTertiary: true,
        keepPrimary: true,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      primaryTextTheme: GoogleFonts.interTextTheme(),
    );
  }

  // ===== Tema oscuro =====
  static ThemeData darkTheme() {
    return FlexThemeData.dark(
      colors: const FlexSchemeColor(
        primary: primaryColor,
        primaryContainer: Color(0xFF3730A3),
        secondary: secondaryColor,
        secondaryContainer: Color(0xFF0369A1),
        tertiary: Color(0xFF818CF8),
        tertiaryContainer: Color(0xFF1E1B4B),
        error: errorColor,
      ),
      useMaterial3: true,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 12,
      visualDensity: VisualDensity.standard,
      scaffoldBackground: surfaceDark,
      surface: surfaceCardDark,
      appBarStyle: FlexAppBarStyle.background,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 18,
        blendOnColors: false,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
        bottomNavigationBarMutedUnselectedLabel: false,
        bottomNavigationBarMutedUnselectedIcon: false,
        bottomNavigationBarShowSelectedLabels: true,
        bottomNavigationBarShowUnselectedLabels: true,
        bottomNavigationBarType: BottomNavigationBarType.fixed,
        bottomNavigationBarBackgroundSchemeColor: SchemeColor.surface,
        bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        bottomNavigationBarUnselectedLabelSchemeColor: SchemeColor.onSurface,
        bottomNavigationBarSelectedIconSchemeColor: SchemeColor.primary,
        bottomNavigationBarUnselectedIconSchemeColor: SchemeColor.onSurface,
        cardRadius: 14.0,
        elevatedButtonRadius: 12.0,
        filledButtonRadius: 12.0,
        outlinedButtonRadius: 12.0,
        textButtonRadius: 12.0,
        inputDecoratorRadius: 10.0,
        fabRadius: 16.0,
        chipRadius: 8.0,
        dialogRadius: 18.0,
        snackBarRadius: 8.0,
        tabBarIndicatorWeight: 3.0,
        tabBarIndicatorTopRadius: 3.0,
        tabBarDividerColor: Colors.transparent,
      ),
      keyColors: const FlexKeyColors(
        useSecondary: true,
        useTertiary: true,
        keepPrimary: true,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      primaryTextTheme: GoogleFonts.interTextTheme(),
    );
  }
}
