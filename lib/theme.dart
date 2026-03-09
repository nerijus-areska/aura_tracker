import 'package:flutter/material.dart';

class AppTheme {
  // ── Core palette: deep, soothing, low-contrast ──
  static const Color bg = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color card = Color(0xFF1C2128);
  static const Color cardHover = Color(0xFF242B35);
  static const Color border = Color(0xFF2D333B);

  // Accents
  static const Color lavender = Color(0xFFA78BFA);
  static const Color lavenderDim = Color(0xFF7C5CBF);
  static const Color teal = Color(0xFF5EEAD4);
  static const Color coral = Color(0xFFF0ABAB);
  static const Color amber = Color(0xFFFBBF24);
  static const Color amberDim = Color(0xFFB8860F);
  static const Color sage = Color(0xFF86EFAC);

  // Text
  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textMuted = Color(0xFF545D68);

  // Severity scale colors (1-6)
  static const List<Color> severityColors = [
    Color(0xFF86EFAC), // 1 - green
    Color(0xFF5EEAD4), // 2 - teal
    Color(0xFFFBBF24), // 3 - amber
    Color(0xFFF59E0B), // 4 - orange
    Color(0xFFF0ABAB), // 5 - coral
    Color(0xFFEF4444), // 6 - red
  ];

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        primaryColor: lavender,
        colorScheme: const ColorScheme.dark(
          primary: lavender,
          secondary: teal,
          surface: surface,
          error: coral,
        ),
        fontFamily: 'Nunito',
        appBarTheme: const AppBarTheme(
          backgroundColor: bg,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
          iconTheme: IconThemeData(color: textPrimary),
        ),
        cardTheme: CardThemeData(
          color: card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: border, width: 1),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: surface,
          selectedItemColor: lavender,
          unselectedItemColor: textMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: lavender,
            foregroundColor: bg,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: lavender, width: 2),
          ),
          labelStyle: const TextStyle(color: textSecondary),
          hintStyle: const TextStyle(color: textMuted),
        ),
      );
}
