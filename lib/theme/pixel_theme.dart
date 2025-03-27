import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PixelTheme {
  // Colores principales
  static const Color primaryColor = Color(0xFF4285F4);    // Azul
  static const Color secondaryColor = Color(0xFFFF7F00);  // Naranja
  static const Color backgroundColor = Color(0xFF202124); // Negro/gris oscuro
  static const Color accentColor = Color(0xFF4CAF50);    // Verde
  static const Color textColor = Color(0xFFFFFFFF);      // Blanco
  static const Color errorColor = Color(0xFFFF5252);     // Rojo

  // Colores para pixel art
  static const Color pixel1 = Color(0xFF2D93AD); // Azul claro
  static const Color pixel2 = Color(0xFF8FCC8F); // Verde claro
  static const Color pixel3 = Color(0xFFFFD700); // Amarillo
  static const Color pixel4 = Color(0xFFE76F51); // Naranja rojizo

  // Tema claro (principal)
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: Colors.white,
      error: errorColor,
    ),
    scaffoldBackgroundColor: const Color(0xFFF0F0F0),
    textTheme: GoogleFonts.pressStart2pTextTheme(
      ThemeData.light().textTheme.copyWith(
            bodyLarge: const TextStyle(fontSize: 14),
            bodyMedium: const TextStyle(fontSize: 12),
            titleLarge: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
    ),
    // Configuración para botones y inputs
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
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black, width: 2),
        borderRadius: BorderRadius.zero,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black, width: 2),
        borderRadius: BorderRadius.zero,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor, width: 2),
        borderRadius: BorderRadius.zero,
      ),
    ),
  );

  // Tema oscuro
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: backgroundColor,
      error: errorColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    textTheme: GoogleFonts.pressStart2pTextTheme(
      ThemeData.dark().textTheme.copyWith(
            bodyLarge: const TextStyle(fontSize: 14),
            bodyMedium: const TextStyle(fontSize: 12),
            titleLarge: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
    ),
    // Configuración para botones y inputs
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
      fillColor: const Color(0xFF303134),
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white70, width: 2),
        borderRadius: BorderRadius.zero,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white70, width: 2),
        borderRadius: BorderRadius.zero,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor, width: 2),
        borderRadius: BorderRadius.zero,
      ),
    ),
  );
}