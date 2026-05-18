import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette
  static const Color primary = Color(0xFF1A237E);
  static const Color primaryLight = Color(0xFF3949AB);
  static const Color primaryDark = Color(0xFF0D1453);
  static const Color primarySurface = Color(0xFF1E2A78);

  // Accent
  static const Color accent = Color(0xFF00BFA5);
  static const Color accentLight = Color(0xFF64FFDA);
  static const Color accentDark = Color(0xFF00897B);

  // Backgrounds
  static const Color background = Color(0xFF0A0E27);
  static const Color surface = Color(0xFF121638);
  static const Color surfaceLight = Color(0xFF1A1F4A);
  static const Color card = Color(0xFF161B45);
  static const Color cardHover = Color(0xFF1E2455);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B8D1);
  static const Color textHint = Color(0xFF6B7394);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF42A5F5);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF283593)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1F4A), Color(0xFF121638)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, Color(0xFF26C6DA)],
  );

  // Shimmer
  static const Color shimmerBase = Color(0xFF1A1F4A);
  static const Color shimmerHighlight = Color(0xFF252B5E);

  // Borders
  static const Color border = Color(0xFF2A2F5A);
  static const Color borderLight = Color(0xFF3A3F6A);

  // Star rating
  static const Color starFilled = Color(0xFFFFD700);
  static const Color starEmpty = Color(0xFF3A3F6A);
}
