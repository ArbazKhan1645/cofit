import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.bgBlush,
        onPrimaryContainer: AppColors.primaryDark,
        secondary: AppColors.lavender,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.bgLavender,
        onSecondaryContainer: const Color(0xFF6A4C93),
        tertiary: AppColors.mintFresh,
        onTertiary: Colors.white,
        tertiaryContainer: AppColors.bgMint,
        onTertiaryContainer: const Color(0xFF00695C),
        error: AppColors.error,
        onError: Colors.white,
        errorContainer: AppColors.errorLight,
        onErrorContainer: const Color(0xFFC62828),
        surface: AppColors.bgWhite,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.bgCream,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.borderLight,
        outlineVariant: AppColors.borderMedium,
        shadow: const Color(0x1A000000),
        scrim: const Color(0x80000000),
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.bgCream,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgWhite,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(
          fontSize: 57, fontWeight: FontWeight.w700,
          height: 1.12, letterSpacing: -0.25, color: AppColors.textPrimary,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 45, fontWeight: FontWeight.w600,
          height: 1.16, color: AppColors.textPrimary,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 36, fontWeight: FontWeight.w600,
          height: 1.22, color: AppColors.textPrimary,
        ),
        headlineLarge: GoogleFonts.poppins(
          fontSize: 32, fontWeight: FontWeight.w600,
          height: 1.25, color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 28, fontWeight: FontWeight.w600,
          height: 1.29, color: AppColors.textPrimary,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 24, fontWeight: FontWeight.w600,
          height: 1.33, color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 22, fontWeight: FontWeight.w600,
          height: 1.27, color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16, fontWeight: FontWeight.w600,
          height: 1.50, letterSpacing: 0.15, color: AppColors.textPrimary,
        ),
        titleSmall: GoogleFonts.poppins(
          fontSize: 14, fontWeight: FontWeight.w600,
          height: 1.43, letterSpacing: 0.1, color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 16, fontWeight: FontWeight.w400,
          height: 1.50, letterSpacing: 0.5, color: AppColors.textSecondary,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 14, fontWeight: FontWeight.w400,
          height: 1.43, letterSpacing: 0.25, color: AppColors.textSecondary,
        ),
        bodySmall: GoogleFonts.nunito(
          fontSize: 12, fontWeight: FontWeight.w400,
          height: 1.33, letterSpacing: 0.4, color: AppColors.textSecondary,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 14, fontWeight: FontWeight.w600,
          height: 1.43, letterSpacing: 0.1, color: AppColors.textPrimary,
        ),
        labelMedium: GoogleFonts.poppins(
          fontSize: 12, fontWeight: FontWeight.w600,
          height: 1.33, letterSpacing: 0.5, color: AppColors.textPrimary,
        ),
        labelSmall: GoogleFonts.poppins(
          fontSize: 11, fontWeight: FontWeight.w600,
          height: 1.45, letterSpacing: 0.5, color: AppColors.textMuted,
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return AppColors.textDisabled;
            if (states.contains(WidgetState.pressed)) return AppColors.primaryDark;
            return AppColors.primary;
          }),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          elevation: WidgetStateProperty.all(0),
          minimumSize: WidgetStateProperty.all(const Size(120, 56)),
          textStyle: WidgetStateProperty.all(GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1,
          )),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return AppColors.textDisabled;
            return AppColors.primary;
          }),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return const BorderSide(color: AppColors.textDisabled, width: 1.5);
            }
            return const BorderSide(color: AppColors.primary, width: 1.5);
          }),
          minimumSize: WidgetStateProperty.all(const Size(120, 56)),
          textStyle: WidgetStateProperty.all(GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1,
          )),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return AppColors.textDisabled;
            if (states.contains(WidgetState.pressed)) return AppColors.primaryDark;
            return AppColors.primary;
          }),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          overlayColor: WidgetStateProperty.all(AppColors.primary.withValues(alpha: 0.1)),
          textStyle: WidgetStateProperty.all(GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1,
          )),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgCream,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: GoogleFonts.nunito(fontSize: 14, color: AppColors.textMuted),
        floatingLabelStyle: GoogleFonts.poppins(
          fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary,
        ),
        hintStyle: GoogleFonts.nunito(fontSize: 14, color: AppColors.textDisabled),
        errorStyle: GoogleFonts.nunito(fontSize: 12, color: AppColors.error),
        prefixIconColor: AppColors.textMuted,
        suffixIconColor: AppColors.textMuted,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.bgWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgWhite,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textDisabled,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12, fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12, fontWeight: FontWeight.w400,
        ),
      ),

      // Navigation Bar (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.bgWhite,
        indicatorColor: AppColors.bgBlush,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 80,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.poppins(
              fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary,
            );
          }
          return GoogleFonts.poppins(
            fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return const IconThemeData(color: AppColors.textMuted, size: 24);
        }),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 8,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.bgBlush,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.bgCream,
        labelStyle: GoogleFonts.poppins(
          fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary,
        ),
        secondaryLabelStyle: GoogleFonts.poppins(
          fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        side: BorderSide.none,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 1,
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.bgBlush,
        circularTrackColor: AppColors.bgBlush,
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.bgBlush,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.2),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.textDisabled;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.blushPink;
          return AppColors.bgCream;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.transparent;
          return AppColors.borderLight;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: AppColors.borderMedium, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.textMuted;
        }),
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textMuted,
        labelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400),
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.primary, width: 3),
          borderRadius: BorderRadius.vertical(top: Radius.circular(3)),
        ),
        indicatorSize: TabBarIndicatorSize.label,
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.bgWhite,
        modalBackgroundColor: AppColors.bgWhite,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        dragHandleColor: AppColors.borderMedium,
        dragHandleSize: const Size(40, 4),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.bgWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
        ),
        contentTextStyle: GoogleFonts.nunito(
          fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary,
        ),
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: GoogleFonts.nunito(
          fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        actionTextColor: AppColors.primaryLight,
      ),
    );
  }
}
