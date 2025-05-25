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
  static const Color accentColor = pixel3;
  static const Color darkBackgroundColor = Color(0xFF202124); // Negro/gris oscuro
  static const Color lightSurfaceColor = Color(0xFFE0E0E0); // Gris claro para superficies en tema claro
  static const Color lightTextColor = Colors.black;         // Texto negro para tema claro
  static const Color darkTextColor = Colors.white;          // Texto blanco para tema oscuro
  static const Color errorColor = Color(0xFFFF5252);     // Rojo

  // Tema claro (principal)
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: lightSurfaceColor, // Superficie más clara
      background: const Color(0xFFF0F0F0), // Fondo general
      error: errorColor,
      onPrimary: Colors.white, // Texto/iconos sobre color primario
      onSecondary: Colors.black, // Texto/iconos sobre color secundario
      onSurface: lightTextColor, // Texto/iconos sobre color de superficie
      onBackground: lightTextColor, // Texto/iconos sobre color de fondo
      onError: Colors.black, // Texto/iconos sobre color de error
    ),
    scaffoldBackgroundColor: const Color(0xFFF0F0F0),
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
        foregroundColor: Colors.white, // Texto blanco sobre botones primarios
        shape: const BeveledRectangleBorder(),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white, // Fondo de inputs claro
      border: OutlineInputBorder(
        borderSide: BorderSide(color: lightTextColor.withOpacity(0.5), width: 2),
        borderRadius: BorderRadius.zero,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: lightTextColor.withOpacity(0.5), width: 2),
        borderRadius: BorderRadius.zero,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: secondaryColor, width: 2), // Borde enfocado con color secundario
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
      surface: darkBackgroundColor, // Superficie oscura
      background: darkBackgroundColor, // Fondo oscuro
      error: errorColor,
      onPrimary: Colors.white, // Texto/iconos sobre color primario
      onSecondary: Colors.black, // Texto/iconos sobre color secundario
      onSurface: darkTextColor, // Texto/iconos sobre color de superficie
      onBackground: darkTextColor, // Texto/iconos sobre color de fondo
      onError: Colors.black, // Texto/iconos sobre color de error
    ),
    scaffoldBackgroundColor: darkBackgroundColor,
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
        foregroundColor: Colors.white, // Texto blanco sobre botones primarios
        shape: const BeveledRectangleBorder(),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF303134), // Fondo de inputs oscuro
      border: OutlineInputBorder(
        borderSide: BorderSide(color: darkTextColor.withOpacity(0.7), width: 2),
        borderRadius: BorderRadius.zero,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: darkTextColor.withOpacity(0.7), width: 2),
        borderRadius: BorderRadius.zero,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: secondaryColor, width: 2), // Borde enfocado con color secundario
        borderRadius: BorderRadius.zero,
      ),
      labelStyle: const TextStyle(color: darkTextColor),
    ),
  );
}