import 'package:flutter/material.dart';

class AppTheme {
  // Crystal Teal Color Palette
  static const Color primaryColor = Color(0xFF00968A);   // Vibrant Teal
  static const Color accentColor = Color(0xFF004D40);    // Deep Teal
  static const Color secondaryColor = Color(0xFF00BFA5); // Bright Mint
  static const double cardRadius = 24.0;

  // ─── DARK MODE EXACT COLORS (from screenshot) ───────────────────────────
  static const Color _darkBg        = Color(0xFF0D0D0D);  // near-black bg
  static const Color _darkCard      = Color(0xFF1A1A1A);  // dark grey cards
  static const Color _darkCardDeep  = Color(0xFF141414);  // slightly deeper cards
  static const Color _darkBorder    = Color(0xFF2A2A2A);  // subtle borders
  static const Color _darkSubtext   = Color(0xFF6B6B6B);  // muted labels

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: Colors.white,
      onSurface: accentColor,
    ),
    scaffoldBackgroundColor: const Color(0xFFF1F8F9),
    cardColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      centerTitle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Color(0xFFF1F8F9),
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.teal.shade100),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.teal.shade50),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      labelStyle: const TextStyle(color: accentColor),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: primaryColor,          // teal for active/selected states
      onPrimary: Colors.white,
      secondary: secondaryColor,      // mint accent
      onSecondary: Colors.black,
      surface: _darkCard,             // card surfaces → dark grey
      onSurface: Colors.white,
      background: _darkBg,            // scaffold bg → near-black
      onBackground: Colors.white,
      error: Color(0xFFCF6679),
      onError: Colors.white,
    ),

    scaffoldBackgroundColor: _darkBg,
    cardColor: _darkCard,

    // ── AppBar: matches the dark sidebar/card shade ──────────────────────
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkCard,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    // ── Drawer: same near-black as scaffold ──────────────────────────────
    drawerTheme: const DrawerThemeData(
      backgroundColor: _darkBg,
      elevation: 0,
    ),

    // ── Cards: dark grey with subtle border ──────────────────────────────
    cardTheme: CardThemeData(
      color: _darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        side: const BorderSide(color: _darkBorder, width: 1),
      ),
    ),

    // ── ElevatedButton: deep teal bg + mint text (NOT bright teal) ───────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,       // #004D40 deep teal
        foregroundColor: secondaryColor,    // #00BFA5 mint text/icon
        surfaceTintColor: Colors.transparent,
        side: const BorderSide(
          color: Color(0x3300BFA5),         // 20% mint border
          width: 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
    ),

    // ── TextButton: mint teal label ───────────────────────────────────────
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: secondaryColor,
      ),
    ),

    // ── OutlinedButton: dark teal outline ────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: secondaryColor,
        side: const BorderSide(color: accentColor, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),

    // ── Inputs: dark card fill, subtle border ─────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkCardDeep,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      labelStyle: const TextStyle(color: _darkSubtext),
      hintStyle: const TextStyle(color: _darkSubtext),
    ),

    // ── Divider ───────────────────────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: _darkBorder,
      thickness: 1,
    ),

    // ── BottomNav ─────────────────────────────────────────────────────────
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _darkCard,
      selectedItemColor: primaryColor,
      unselectedItemColor: _darkSubtext,
      elevation: 0,
    ),

    // ── NavigationRail (sidebar like screenshot) ──────────────────────────
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: _darkBg,
      selectedIconTheme: IconThemeData(color: primaryColor),
      unselectedIconTheme: IconThemeData(color: _darkSubtext),
      selectedLabelTextStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
      unselectedLabelTextStyle: TextStyle(color: _darkSubtext),
      indicatorColor: Color(0xFF1A2E2C), // dark teal pill for active item
    ),

    // ── Chip ──────────────────────────────────────────────────────────────
    chipTheme: const ChipThemeData(
      backgroundColor: _darkCardDeep,
      labelStyle: TextStyle(color: Colors.white70),
      side: BorderSide(color: _darkBorder),
      shape: StadiumBorder(),
    ),

    // ── Switch / Checkbox: teal when active ───────────────────────────────
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) =>
      states.contains(MaterialState.selected) ? secondaryColor : _darkSubtext),
      trackColor: MaterialStateProperty.resolveWith((states) =>
      states.contains(MaterialState.selected) ? accentColor : _darkBorder),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) =>
      states.contains(MaterialState.selected) ? primaryColor : Colors.transparent),
      side: const BorderSide(color: _darkSubtext, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    // ── Progress / Circular ───────────────────────────────────────────────
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryColor,
      circularTrackColor: _darkBorder,
      linearTrackColor: _darkBorder,
    ),

    // ── Icon ─────────────────────────────────────────────────────────────
    iconTheme: const IconThemeData(color: Colors.white70),
    primaryIconTheme: const IconThemeData(color: primaryColor),

    // ── Text ─────────────────────────────────────────────────────────────
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Colors.white),
      displayMedium: TextStyle(color: Colors.white),
      displaySmall: TextStyle(color: Colors.white),
      headlineLarge: TextStyle(color: Colors.white),
      headlineMedium: TextStyle(color: Colors.white),
      headlineSmall: TextStyle(color: Colors.white),
      titleLarge: TextStyle(color: Colors.white),
      titleMedium: TextStyle(color: Colors.white),
      titleSmall: TextStyle(color: Colors.white70),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      bodySmall: TextStyle(color: _darkSubtext),
      labelLarge: TextStyle(color: Colors.white),
      labelMedium: TextStyle(color: Colors.white70),
      labelSmall: TextStyle(color: _darkSubtext),
    ),
  );

  // ── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// The teal mint card (like "TaskOS Premium" in screenshot)
  static const LinearGradient premiumCardGradient = LinearGradient(
    colors: [Color(0xFF00BFA5), Color(0xFF00968A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Box Decorations ──────────────────────────────────────────────────────
  static BoxDecoration premiumCardDecoration(BuildContext context,
      {Color? color, double? radius}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: color ?? (isDark ? _darkCard : Colors.white),
      borderRadius: BorderRadius.circular(radius ?? cardRadius),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withOpacity(0.5)
              : const Color(0x15004D40),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ],
      border: Border.all(
        color: isDark
            ? _darkBorder
            : Colors.teal.shade50.withOpacity(0.5),
        width: 1,
      ),
    );
  }

  /// Stat cards (Total Assigned / Completed / In Progress) — dark grey
  static BoxDecoration statCardDecoration() => BoxDecoration(
    color: _darkCard,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: _darkBorder, width: 1),
  );

  /// Selected nav item pill (teal glow like Dashboard in sidebar)
  static BoxDecoration navSelectedDecoration() => BoxDecoration(
    color: primaryColor,
    borderRadius: BorderRadius.circular(50),
  );
}