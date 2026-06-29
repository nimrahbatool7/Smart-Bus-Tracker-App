import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Deep dark futuristic colors
  static const Color backgroundDark = Color(0xFF0F111A);
  static const Color backgroundLight = Color(0xFFF0F2F5);
  static const Color primaryColor = Color(0xFF00E5FF); // Neon cyan
  static const Color accentColor = Color(0xFF7C4DFF); // Deep purple
  static const Color surfaceColorDark = Color(0x1AFFFFFF); // 10% white for glass
  static const Color surfaceColorLight = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFFF5252);
  static const Color lightBlueHeader = Color(0xFF0A58CA);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColorDark,
        surfaceContainerHighest: backgroundDark,
        error: errorColor,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: Colors.white70,
        ),
      ),
    );
  }
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: lightBlueHeader,
        secondary: accentColor,
        surface: surfaceColorLight,
        error: errorColor,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1E293B),
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1E293B),
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: const Color(0xFF475569),
        ),
      ),
    );
  }
}
