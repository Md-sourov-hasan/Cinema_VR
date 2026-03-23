import 'package:flutter/material.dart';

class TheaterTheme {
  // Color Palette — Deep Cinema Noir
  static const Color background = Color(0xFF050810);
  static const Color surface = Color(0xFF0D1117);
  static const Color surfaceElevated = Color(0xFF161B27);
  static const Color surfaceGlass = Color(0x1AFFFFFF);
  static const Color accent = Color(0xFFD4AF37); // Gold
  static const Color accentGlow = Color(0x40D4AF37);
  static const Color accentSecondary = Color(0xFFE8C76A);
  static const Color crimson = Color(0xFF8B1A1A);
  static const Color crimsonGlow = Color(0x508B1A1A);
  static const Color textPrimary = Color(0xFFF5F0E8);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textMuted = Color(0xFF5C5C5C);
  static const Color border = Color(0xFF1E2533);
  static const Color borderGold = Color(0x60D4AF37);

  // VR Specific
  static const Color vrLeft = Color(0xFF050810);
  static const Color vrRight = Color(0xFF050810);
  static const Color vrSplit = Color(0xFF0A0F1A);

  static ThemeData get theme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: crimson,
          surface: surface,
          onPrimary: background,
          onSurface: textPrimary,
        ),
        fontFamily: 'Raleway',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Cinzel',
            fontSize: 42,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: 4,
          ),
          displayMedium: TextStyle(
            fontFamily: 'Cinzel',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: 3,
          ),
          titleLarge: TextStyle(
            fontFamily: 'Cinzel',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: 2,
          ),
          titleMedium: TextStyle(
            fontFamily: 'Raleway',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
            letterSpacing: 1,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Raleway',
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: textSecondary,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Raleway',
            fontSize: 13,
            fontWeight: FontWeight.w300,
            color: textMuted,
            letterSpacing: 0.5,
          ),
        ),
        iconTheme: const IconThemeData(color: textSecondary, size: 24),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: textPrimary),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: accent,
          inactiveTrackColor: border,
          thumbColor: accent,
          overlayColor: accentGlow,
          trackHeight: 2,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        ),
      );
}

// Gradient helpers
class TheaterGradients {
  static const LinearGradient goldShimmer = LinearGradient(
    colors: [
      Color(0xFFB8960C),
      Color(0xFFD4AF37),
      Color(0xFFE8C76A),
      Color(0xFFD4AF37),
      Color(0xFFB8960C),
    ],
  );

  static const LinearGradient backgroundFade = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF050810),
      Color(0xFF08091A),
      Color(0xFF050810),
    ],
  );

  static const RadialGradient spotlightGold = RadialGradient(
    colors: [Color(0x30D4AF37), Colors.transparent],
    radius: 0.8,
  );

  static const LinearGradient controlBar = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xE6050810)],
  );
}
