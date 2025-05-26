import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PixelTheme {
  // Colores para pixel art (usados como base para el tema)
  static const Color pixel1 = Color(0xFF2D93AD); // Azul claro (Nueva primaryColor)
  static const Color pixel2 = Color(0xFF8FCC8F); // Verde claro (Nueva secondaryColor)
  static const Color pixel3 = Color(0xFFFFD700); // Amarillo (Nueva accentColor)
  static const Color pixel4 = Color(0xFFE76F51); // Naranja rojizo (No usado directamente en el tema base)

  // Definiciones de colores base
  static const Color primaryColor = pixel1;
  static const Color secondaryColor = pixel2;
  static const Color accentColor = pixel3; // Usado como tertiary
  static const Color errorColor = Color(0xFFFF5252);     // Rojo

  // Colores para Light Theme
  static const Color lightScaffoldBackgroundColor = Color(0xFFE4F4E4); // Muy light green (de pixel2)
  static const Color lightSurfaceColor = Color(0xFFFFF9C4);          // Muy light yellow (de pixel3)
  static const Color lightTextColor = Colors.black;

  // Colores para Dark Theme
  static const Color darkBackgroundColor = Color(0xFF202124); // Negro/gris oscuro (para scaffold)
  static const Color darkDialogSurfaceColor = Color(0xFF303134); // Gris más claro (para cards/dialogs)
  static const Color darkTextColor = Colors.white;

  // Tema claro (principal)
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      // background: Colors.white, // Deprecated
      surface: Colors.white, // Usar surface en lugar de background
      onSurface: Colors.black, // Usar onSurface en lugar de onBackground
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
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      // background: const Color(0xFF121212), // Deprecated
      surface: const Color(0xFF121212), // Usar surface en lugar de background
      onSurface: Colors.white, // Usar onSurface en lugar de onBackground
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