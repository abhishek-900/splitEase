import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color primaryBlue = Color(0xFF2563EB); // indigo-blue
  static const Color primaryLight = Color(0xFF3B82F6); // lighter blue
  static const Color primaryDark = Color(0xFF1D4ED8); // darker blue
  static const Color accent = Color(0xFF06B6D4); // cyan accent

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ── Neutral palette ────────────────────────────────────────────────────────
  static const Color neutral50 = Color(0xFFF8FAFC);
  static const Color neutral100 = Color(0xFFF1F5F9);
  static const Color neutral200 = Color(0xFFE2E8F0);
  static const Color neutral300 = Color(0xFFCBD5E1);
  static const Color neutral400 = Color(0xFF94A3B8);
  static const Color neutral500 = Color(0xFF64748B);
  static const Color neutral600 = Color(0xFF475569);
  static const Color neutral700 = Color(0xFF334155);
  static const Color neutral800 = Color(0xFF1E293B);
  static const Color neutral900 = Color(0xFF0F172A);

  // ── Legacy alias (used across the app) ────────────────────────────────────
  // Keep these pointing to blue so existing references compile
  static const Color primaryGreen = primaryBlue;

  // ── Light theme ────────────────────────────────────────────────────────────
  static ThemeData get light => _build(Brightness.light);

  // ── Dark theme ─────────────────────────────────────────────────────────────
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final surface = isDark ? const Color(0xFF1E293B) : Colors.white;
    final onSurface = isDark ? Colors.white : neutral900;
    final border = isDark ? const Color(0xFF334155) : neutral200;
    final subtext = isDark ? neutral400 : neutral500;
    final inputFill = isDark ? const Color(0xFF1E293B) : neutral50;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primaryBlue,
      onPrimary: Colors.white,
      primaryContainer: isDark ? primaryDark : const Color(0xFFDBEAFE),
      onPrimaryContainer: isDark ? Colors.white : primaryDark,
      secondary: accent,
      onSecondary: Colors.white,
      secondaryContainer:
          isDark ? const Color(0xFF164E63) : const Color(0xFFCFFAFE),
      onSecondaryContainer: isDark ? Colors.white : const Color(0xFF164E63),
      error: error,
      onError: Colors.white,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: isDark ? const Color(0xFF334155) : neutral100,
      outline: border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.nunitoTextTheme(
        ThemeData(brightness: brightness).textTheme,
      ),
      scaffoldBackgroundColor: bg,

      // ── AppBar ─────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: onSurface,
        ),
        iconTheme: IconThemeData(color: onSurface),
      ),

      // ── Card ───────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border),
        ),
      ),

      // ── ElevatedButton ─────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ── OutlinedButton ─────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: const BorderSide(color: primaryBlue, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ── TextButton ─────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          textStyle: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ── InputDecoration ────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        hintStyle: TextStyle(color: subtext, fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error),
        ),
      ),

      // ── NavigationBar ──────────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primaryBlue.withValues(alpha: 0.12),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryBlue);
          }
          return IconThemeData(color: subtext);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.nunito(
                fontSize: 12, fontWeight: FontWeight.w700, color: primaryBlue);
          }
          return GoogleFonts.nunito(
              fontSize: 12, fontWeight: FontWeight.w600, color: subtext);
        }),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.08),
      ),

      // ── FloatingActionButton ───────────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // ── Divider ────────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),

      // ── SnackBar ───────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? const Color(0xFF1E293B) : neutral800,
        contentTextStyle: GoogleFonts.nunito(color: Colors.white, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // ── Chip ───────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: inputFill,
        selectedColor: primaryBlue.withValues(alpha: 0.15),
        labelStyle: GoogleFonts.nunito(fontSize: 13),
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),

      // ── ListTile ───────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        iconColor: subtext,
        tileColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
