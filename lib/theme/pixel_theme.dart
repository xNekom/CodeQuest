import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PixelTheme {
  // Colores principales del tema pixel
  static const Color pixel1 = Color(0xFF2D93AD); // Azul claro (Nueva primaryColor)
  static const Color pixel2 = Color(0xFF8FCC8F); // Verde claro (Nueva secondaryColor)
  static const Color pixel3 = Color(0xFFFFD700); // Amarillo (Nueva accentColor)
  static const Color pixel4 = Color(0xFFE76F51); // Naranja rojizo (No usado directamente en el tema base)

  // Colores adicionales
  static const Color primaryColor = pixel1;
  static const Color secondaryColor = pixel2;
  static const Color accentColor = pixel3;
  static const Color errorColor = Color(0xFFFF5252);     // Rojo

  // Colores para modo claro
  static const Color lightScaffoldBackgroundColor = Color(0xFFE4F4E4); // Muy light green (de pixel2)
  static const Color lightSurfaceColor = Color(0xFFFFF9C4);          // Muy light yellow (de pixel3)
  static const Color lightTextColor = Colors.black;

  // Colores para modo oscuro
  static const Color darkBackgroundColor = Color(0xFF202124); // Negro/gris oscuro (para scaffold)
  static const Color darkDialogSurfaceColor = Color(0xFF303134); // Gris más claro (para cards/dialogs)
  static const Color darkTextColor = Colors.white;

  // Constantes de diseño estandarizadas
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusXLarge = 16.0;
  
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
    scaffoldBackgroundColor: lightScaffoldBackgroundColor, // Muy light green
    textTheme: GoogleFonts.pressStart2pTextTheme(
      ThemeData.light().textTheme.copyWith(
            bodyLarge: const TextStyle(fontSize: 14, color: lightTextColor),
            bodyMedium: const TextStyle(fontSize: 12, color: lightTextColor),
            titleLarge: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: lightTextColor),
          ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: const BeveledRectangleBorder(),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFFFFFE0), // Lighter yellow para inputs
      border: OutlineInputBorder(
        borderSide: BorderSide(color: lightTextColor.withAlpha(128), width: 2),
        borderRadius: BorderRadius.zero,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: lightTextColor.withAlpha(128), width: 2),
        borderRadius: BorderRadius.zero,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: secondaryColor, width: 2),
        borderRadius: BorderRadius.zero,
      ),
      labelStyle: const TextStyle(color: lightTextColor),
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
    scaffoldBackgroundColor: darkBackgroundColor, // Gris oscuro
    textTheme: GoogleFonts.pressStart2pTextTheme(
      ThemeData.dark().textTheme.copyWith(
            bodyLarge: const TextStyle(fontSize: 14, color: darkTextColor),
            bodyMedium: const TextStyle(fontSize: 12, color: darkTextColor),
            titleLarge: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkTextColor),
          ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: const BeveledRectangleBorder(),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF303134), // Mantenido como darkDialogSurfaceColor
      border: OutlineInputBorder(
        borderSide: BorderSide(color: darkTextColor.withAlpha(179), width: 2),
        borderRadius: BorderRadius.zero,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: darkTextColor.withAlpha(179), width: 2),
        borderRadius: BorderRadius.zero,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: secondaryColor, width: 2),
        borderRadius: BorderRadius.zero,
      ),
      labelStyle: const TextStyle(color: darkTextColor),
    ),
  );
}