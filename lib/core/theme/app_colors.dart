import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors (Coral/Pink Family)
  static const Color primary = Color(0xFFFF6B6B);
  static const Color primaryLight = Color(0xFFFF8E8E);
  static const Color primaryDark = Color(0xFFE85555);
  static const Color blushPink = Color(0xFFFFB5BA);
  static const Color peach = Color(0xFFFFAB91);
  static const Color softRose = Color(0xFFF8BBD9);

  // Secondary Colors
  static const Color lavender = Color(0xFFB39DDB);
  static const Color lavenderLight = Color(0xFFD1C4E9);
  static const Color mintFresh = Color(0xFF80CBC4);
  static const Color mintLight = Color(0xFFB2DFDB);
  static const Color sunnyYellow = Color(0xFFFFE082);
  static const Color skyBlue = Color(0xFF81D4FA);

  // Background Colors
  static const Color bgWhite = Color(0xFFFFFFFF);
  static const Color bgCream = Color(0xFFFFF8F6);
  static const Color bgBlush = Color(0xFFFFF0F3);
  static const Color bgLavender = Color(0xFFF5F0FF);
  static const Color bgPeach = Color(0xFFFFF5F0);
  static const Color bgMint = Color(0xFFE0F2F1);

  // Text Colors
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF5A5A5A);
  static const Color textMuted = Color(0xFF8E8E8E);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Border Colors
  static const Color borderLight = Color(0xFFFFE0E3);
  static const Color borderMedium = Color(0xFFFFB5BA);
  static const Color borderDark = Color(0xFFFF8E8E);

  // Semantic Colors
  static const Color success = Color(0xFF66BB6A);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFEF5350);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFFFA726);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color info = Color(0xFF42A5F5);
  static const Color infoLight = Color(0xFFE3F2FD);

  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, peach],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [primary, blushPink, lavender],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softPeachGradient = LinearGradient(
    colors: [bgCream, bgBlush],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient energyGradient = LinearGradient(
    colors: [primary, sunnyYellow],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient calmGradient = LinearGradient(
    colors: [lavender, skyBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mintGradient = LinearGradient(
    colors: [mintFresh, Color(0xFFA5D6A7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
