import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors based on designs
  static const Color background = Color(0xFF1E141E); // Very dark purplish
  static const Color cardColor = Color(0xFF281C2A); // Lighter purplish card
  static const Color primaryPink = Color(0xFFF93B8E);
  static const Color primaryPinkLight = Color(0xFFFF82B2);
  static const Color accentSage = Color(0xFF95B8A2);
  static const Color textLight = Color(0xFFF1F1F1);
  static const Color textMuted = Color(0xFFB0A8B9);
  static const Color borderSubtle = Color(0xFF3B2D40);
  
  // Phase Colors
  static const Color phaseMenstrual = Color(0xFFE94B73);
  static const Color phaseFollicular = Color(0xFF95B8A2);
  static const Color phaseOvulatory = Color(0xFF866CD4);
  static const Color phaseLuteal = Color(0xFFCC5A9D);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primaryPink,
      colorScheme: const ColorScheme.dark(
        primary: primaryPink,
        secondary: accentSage,
        surface: cardColor,
        background: background,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(color: textLight, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.inter(color: textLight, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.inter(color: textLight, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.inter(color: textLight),
        bodyMedium: GoogleFonts.inter(color: textMuted),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textLight),
        titleTextStyle: GoogleFonts.inter(color: textLight, fontSize: 18, fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPink,
          foregroundColor: textLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: primaryPink,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}
