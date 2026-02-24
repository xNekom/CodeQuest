import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PixelTheme {
  // Colores principales del tema moderno y atractivo
  static const Color pixel1 = Color(0xFF6366F1); // Índigo vibrante (primaryColor)
  static const Color pixel2 = Color(0xFF10B981); // Verde esmeralda (secondaryColor)
  static const Color pixel3 = Color(0xFFF59E0B); // Ámbar dorado (accentColor)
  static const Color pixel4 = Color(0xFFEF4444); // Rojo coral (errorColor)

  // Colores adicionales
  static const Color primaryColor = pixel1;
  static const Color secondaryColor = pixel2;
  static const Color accentColor = pixel3;
  static const Color errorColor = pixel4;

  // Colores para modo claro - Fondo más limpio y moderno
  static const Color lightScaffoldBackgroundColor = Color(0xFFF8FAFC); // Gris muy claro
  static const Color lightSurfaceColor = Color(0xFFFFFFFF);          // Blanco puro
  static const Color lightTextColor = Color(0xFF1E293B);             // Gris oscuro para mejor legibilidad

  // Colores para modo oscuro
  static const Color darkBackgroundColor = Color(0xFF0F172A);        // Azul oscuro profundo
  static const Color darkDialogSurfaceColor = Color(0xFF1E293B);     // Gris azulado / Glass
  static const Color darkTextColor = Color(0xFFF1F5F9);              // Gris muy claro

  // Constantes de diseño estandarizadas
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 16.0;
  static const double borderRadiusLarge = 24.0;
  static const double borderRadiusXLarge = 32.0;
  
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 18.0;
  static const double fontSizeXXLarge = 20.0;

  // Tema claro (principal)
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor, // Amarillo
      surface: lightSurfaceColor, // Muy light green
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onTertiary: Colors.black,
      onSurface: lightTextColor, // Negro sobre light green
      onError: Colors.black,
    ),
    scaffoldBackgroundColor: lightScaffoldBackgroundColor,
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.light().textTheme.copyWith(
            bodyLarge: const TextStyle(fontSize: 16, color: lightTextColor, fontWeight: FontWeight.w400),
            bodyMedium: const TextStyle(fontSize: 14, color: lightTextColor, fontWeight: FontWeight.w400),
            titleLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: lightTextColor),
          ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: spacingMedium, vertical: spacingSmall),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurfaceColor.withValues(alpha: 0.8),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(borderRadiusMedium),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(borderRadiusMedium),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: primaryColor, width: 2),
        borderRadius: BorderRadius.circular(borderRadiusMedium),
      ),
      labelStyle: TextStyle(color: lightTextColor.withValues(alpha: 0.7)),
      contentPadding: const EdgeInsets.symmetric(horizontal: spacingMedium, vertical: spacingSmall),
    ),
  );

  // Tema oscuro
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor, // Amarillo
      surface: darkDialogSurfaceColor, // Gris oscuro para scaffold background
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onTertiary: Colors.black,
      onSurface: darkTextColor, // Blanco sobre gris oscuro
      onError: Colors.black,
    ),
    scaffoldBackgroundColor: darkBackgroundColor,
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme.copyWith(
            bodyLarge: const TextStyle(fontSize: 16, color: darkTextColor, fontWeight: FontWeight.w400),
            bodyMedium: const TextStyle(fontSize: 14, color: darkTextColor, fontWeight: FontWeight.w400),
            titleLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: darkTextColor),
          ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: spacingMedium, vertical: spacingSmall),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkDialogSurfaceColor.withValues(alpha: 0.8),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(borderRadiusMedium),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(borderRadiusMedium),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: primaryColor, width: 2),
        borderRadius: BorderRadius.circular(borderRadiusMedium),
      ),
      labelStyle: TextStyle(color: darkTextColor.withValues(alpha: 0.7)),
      contentPadding: const EdgeInsets.symmetric(horizontal: spacingMedium, vertical: spacingSmall),
    ),
  );
}