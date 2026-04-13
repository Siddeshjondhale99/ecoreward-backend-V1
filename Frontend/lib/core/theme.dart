import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Sporty / Racing inspired colors
  static const Color primaryColor = Color(0xFFCCFF00); // Neon Lime
  static const Color accentColor = Color(0xFF00A3FF); // Electric Blue
  static const Color backgroundColor = Color(0xFF0D0D0D); // Pure Carbon Black
  static const Color surfaceColor = Color(0xFF1A1A1A); // Carbon Grey
  static const Color cardColor = Color(0xFF222222);
  static const Color errorColor = Color(0xFFFF3D00); // Racing Red
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF888888);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFCCFF00), Color(0xFF00A3FF)],
  );

  static const LinearGradient sportyGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFCCFF00), Color(0xFF00A3FF)],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF222222), Color(0xFF1A1A1A)],
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        error: errorColor,
        surface: surfaceColor,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.w900, color: textPrimary, fontStyle: FontStyle.italic),
        headlineMedium: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w800, color: textPrimary, letterSpacing: -0.5),
        titleLarge: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary),
        bodyLarge: GoogleFonts.manrope(fontSize: 16, color: textPrimary, height: 1.5, fontWeight: FontWeight.w500),
        bodyMedium: GoogleFonts.manrope(fontSize: 14, color: textSecondary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, fontStyle: FontStyle.italic),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.black,
          elevation: 4,
          shadowColor: primaryColor.withOpacity(0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Sharper, sportier
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 8,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // More geometric
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: Color(0xFF444444)),
      ),
    );
  }

  static ThemeData get lightTheme => darkTheme; 
}
