import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  // Base unit (8px grid system)
  static const double unit = 8.0;

  // Spacing values
  static const double xxs = 4.0;   // 0.5x - Minimal spacing
  static const double xs = 8.0;    // 1x - Tight spacing
  static const double sm = 12.0;   // 1.5x - Small spacing
  static const double md = 16.0;   // 2x - Default spacing
  static const double lg = 24.0;   // 3x - Comfortable spacing
  static const double xl = 32.0;   // 4x - Generous spacing
  static const double xxl = 48.0;  // 6x - Section spacing
  static const double xxxl = 64.0; // 8x - Large section spacing

  // Screen padding (horizontal)
  static const double screenPadding = 20.0;

  // Card internal padding
  static const double cardPadding = 16.0;

  // List item spacing
  static const double listItemSpacing = 12.0;

  // Section spacing
  static const double sectionSpacing = 32.0;
}

class AppPadding {
  AppPadding._();

  // Screen padding
  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: 20.0);
  static const EdgeInsets screenAll = EdgeInsets.all(20.0);
  static const EdgeInsets screenWithTop = EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 0);
  static const EdgeInsets horizontal = EdgeInsets.symmetric(horizontal: 20.0);

  // Card padding
  static const EdgeInsets card = EdgeInsets.all(16.0);
  static const EdgeInsets cardCompact = EdgeInsets.all(12.0);
  static const EdgeInsets cardLarge = EdgeInsets.all(20.0);

  // Button padding
  static const EdgeInsets buttonLarge = EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0);
  static const EdgeInsets buttonMedium = EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0);
  static const EdgeInsets buttonSmall = EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);

  // Input field padding
  static const EdgeInsets inputField = EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0);

  // List tile padding
  static const EdgeInsets listTile = EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);
}

class AppRadius {
  AppRadius._();

  // Small elements (chips, tags, small buttons)
  static const double xs = 4.0;
  static const double sm = 8.0;

  // Medium elements (cards, buttons, inputs)
  static const double md = 12.0;
  static const double lg = 16.0;

  // Large elements (modals, sheets, large cards)
  static const double xl = 20.0;
  static const double xxl = 24.0;

  // Fully rounded (pills, avatars, FAB)
  static const double full = 100.0;

  // BorderRadius presets
  static BorderRadius small = BorderRadius.circular(8.0);
  static BorderRadius medium = BorderRadius.circular(12.0);
  static BorderRadius large = BorderRadius.circular(16.0);
  static BorderRadius extraLarge = BorderRadius.circular(24.0);
  static BorderRadius pill = BorderRadius.circular(100.0);

  // Top-only radius (bottom sheets)
  static BorderRadius bottomSheet = const BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  );
}

class AppShadows {
  AppShadows._();

  // Subtle shadow (cards at rest)
  static List<BoxShadow> subtle = [
    const BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  // Medium shadow (elevated cards, buttons)
  static List<BoxShadow> medium = [
    const BoxShadow(
      color: Color(0x14000000),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
    const BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  // Strong shadow (modals, dialogs)
  static List<BoxShadow> strong = [
    const BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 30,
      offset: Offset(0, 16),
    ),
    const BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  // Colored shadow (primary buttons, FAB)
  static List<BoxShadow> primaryGlow = [
    const BoxShadow(
      color: Color(0x40FF6B6B),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  // Bottom navigation shadow
  static List<BoxShadow> bottomNav = [
    const BoxShadow(
      color: Color(0x14000000),
      blurRadius: 20,
      offset: Offset(0, -4),
    ),
  ];
}
