import 'package:chamba_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class AppTheme {
  // Using kColor constants from constants.dart
  static const Color _primaryColor = kPrimaryColor; // Azul
  static const Color _secondaryColor = kSecondaryColor; // Verde
  static const Color _accentColor = kAccentColor; // Amarillo/Dorado
  static const Color _backgroundColor = kBackgroundColor; // Crema/Blanco Hueso
  static const Color _textColor = kTextColor; // Gris Oscuro
  static const Color _cardColor = kCardColor; // Blanco

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: _primaryColor,
    scaffoldBackgroundColor: _backgroundColor,

    // Use GoogleFonts for the default text theme
    textTheme: GoogleFonts.montserratTextTheme(ThemeData.light().textTheme).copyWith(
      displayLarge: const TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold, color: _textColor, letterSpacing: -0.5),
      displayMedium: const TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold, color: _textColor, letterSpacing: -0.25),
      displaySmall: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: _textColor),
      headlineMedium: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600, color: _textColor), // Used for AppBar titles if not overridden
      headlineSmall: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: _textColor), // Good for card titles
      titleLarge: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, color: _textColor),    // Good for list item titles
      bodyLarge: const TextStyle(fontSize: 15.0, color: _textColor, height: 1.4),
      bodyMedium: const TextStyle(fontSize: 13.0, color: _textColor, height: 1.3),
      labelLarge: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: _cardColor), // For ElevatedButton text
      labelMedium: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w500, color: _primaryColor), // For TextButton text
      labelSmall: TextStyle(fontSize: 11.0, fontWeight: FontWeight.w500, color: _textColor.withOpacity(0.7)), // For chip labels
      bodySmall: TextStyle(fontSize: 12.0, color: _textColor.withOpacity(0.7), height: 1.2), // For subtitles or less important text
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: _primaryColor,
      elevation: 2, // Subtle elevation
      iconTheme: const IconThemeData(color: _cardColor), // White icons on AppBar
      titleTextStyle: GoogleFonts.montserrat(
        color: _cardColor, // White title
        fontSize: 20,
        fontWeight: FontWeight.w600, // Semi-bold
      ),
      centerTitle: true,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: _cardColor, // Text color
        padding: const EdgeInsets.symmetric(horizontal: kLargePadding, vertical: kDefaultPadding * 0.85),
        textStyle: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        ),
        elevation: 2,
        shadowColor: _primaryColor.withOpacity(0.3),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryColor,
        textStyle: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding, vertical: kSmallPadding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _cardColor.withOpacity(0.8), // Slightly transparent white
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        borderSide: const BorderSide(color: _primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        borderSide: BorderSide(color: Colors.red.shade700, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        borderSide: BorderSide(color: Colors.red.shade700, width: 1.5),
      ),
      labelStyle: TextStyle(color: _textColor.withOpacity(0.8), fontWeight: FontWeight.w500),
      hintStyle: TextStyle(color: Colors.grey.shade500),
      prefixIconColor: _primaryColor.withOpacity(0.7),
      suffixIconColor: _primaryColor.withOpacity(0.7),
      contentPadding: const EdgeInsets.symmetric(vertical: kDefaultPadding * 0.9, horizontal: kDefaultPadding),
    ),

    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      primary: _primaryColor,
      secondary: _secondaryColor,
      surface: _cardColor, // Card backgrounds, dialogs
      background: _backgroundColor, // Scaffold background
      error: Colors.red.shade700,
      onPrimary: _cardColor, // Text/icons on primary color
      onSecondary: _cardColor, // Text/icons on secondary color
      onSurface: _textColor, // Text on cards/dialogs
      onBackground: _textColor, // Text on scaffold background
      onError: _cardColor, // Text/icons on error color
      brightness: Brightness.light,
    ),

    cardTheme: CardTheme(
      elevation: 1.5, // Softer elevation
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kCardBorderRadius)),
      color: _cardColor,
      margin: const EdgeInsets.symmetric(vertical: kSmallMargin, horizontal: kSmallMargin / 2), // Consistent margins
      clipBehavior: Clip.antiAlias, // Good for rounded corners with images
    ),

    iconTheme: IconThemeData(
      color: _primaryColor, // Default icon color
      size: kMediumIconSize,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: _primaryColor.withOpacity(0.1),
      labelStyle: TextStyle(color: _primaryColor, fontWeight: FontWeight.w500, fontSize: 11),
      padding: const EdgeInsets.symmetric(horizontal: kSmallPadding, vertical: kSmallPadding/2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kDefaultBorderRadius/2)),
      side: BorderSide.none,
    ),

    tabBarTheme: TabBarTheme(
      labelColor: _cardColor, // Color of selected tab text
      unselectedLabelColor: _cardColor.withOpacity(0.7), // Color of unselected tab text
      indicator: UnderlineTabIndicator( // Style of the indicator under the selected tab
        borderSide: const BorderSide(color: _accentColor, width: 3.0), // Accent color for indicator
        insets: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
      ),
       labelStyle: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600),
       unselectedLabelStyle: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w500),
    ),

    dialogTheme: DialogTheme(
      backgroundColor: _cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kCardBorderRadius)),
      titleTextStyle: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600, color: _primaryColor),
      contentTextStyle: GoogleFonts.montserrat(fontSize: 14, color: _textColor),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: _primaryColor,
      unselectedItemColor: Colors.grey.shade600,
      backgroundColor: _cardColor,
      elevation: 8.0,
      selectedLabelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 11),
      unselectedLabelStyle: GoogleFonts.montserrat(fontSize: 10),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _secondaryColor,
      foregroundColor: _cardColor,
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kDefaultBorderRadius * 2)),
    ),

    // Add other theme properties as needed
    useMaterial3: true, // Enable Material 3 features
  );

  // --- Dark Theme (Example, can be further customized) ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: _primaryColor, // Could be a slightly lighter blue for dark mode
    scaffoldBackgroundColor: const Color(0xFF121212),

    textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: const TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold, letterSpacing: -0.5),
      displayMedium: const TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold, letterSpacing: -0.25),
      displaySmall: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
      headlineMedium: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
      headlineSmall: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
      titleLarge: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
      bodyLarge: const TextStyle(fontSize: 15.0, height: 1.4),
      bodyMedium: const TextStyle(fontSize: 13.0, height: 1.3),
      labelLarge: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold), // For ElevatedButton text
      labelMedium: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600, color: _accentColor), // For TextButton text
      labelSmall: TextStyle(fontSize: 11.0, fontWeight: FontWeight.w500, color: Colors.grey.shade400),
      bodySmall: TextStyle(fontSize: 12.0, color: Colors.grey.shade400, height: 1.2),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey.shade900,
      elevation: 0, // Flat design for dark mode often looks good
      iconTheme: const IconThemeData(color: _accentColor), // Accent color for icons
      titleTextStyle: GoogleFonts.montserrat(
        color: Colors.grey.shade200,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      centerTitle: true,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _secondaryColor, // Green buttons stand out
        foregroundColor: _cardColor,
        padding: const EdgeInsets.symmetric(horizontal: kLargePadding, vertical: kDefaultPadding * 0.85),
        textStyle: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _accentColor, // Accent for text buttons
         textStyle: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding, vertical: kSmallPadding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade800,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        borderSide: BorderSide(color: Colors.grey.shade700, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        borderSide: BorderSide(color: Colors.grey.shade700, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        borderSide: const BorderSide(color: _accentColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
      ),
      labelStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
      hintStyle: TextStyle(color: Colors.grey.shade600),
      prefixIconColor: _accentColor.withOpacity(0.7),
      suffixIconColor: _accentColor.withOpacity(0.7),
      contentPadding: const EdgeInsets.symmetric(vertical: kDefaultPadding * 0.9, horizontal: kDefaultPadding),
    ),

    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor, // Or a dark mode primary variant
      primary: _primaryColor,
      secondary: _secondaryColor, // Or a dark mode secondary variant
      surface: Colors.grey.shade850, // Darker surface for cards
      background: const Color(0xFF121212),
      error: Colors.redAccent.shade100,
      onPrimary: _cardColor,
      onSecondary: _cardColor,
      onSurface: Colors.grey.shade300, // Lighter text on dark surfaces
      onBackground: Colors.grey.shade300,
      onError: Colors.black,
      brightness: Brightness.dark,
    ),

    cardTheme: CardTheme(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kCardBorderRadius)),
      color: Colors.grey.shade850, // Dark card color
      margin: const EdgeInsets.symmetric(vertical: kSmallMargin, horizontal: kSmallMargin / 2),
      clipBehavior: Clip.antiAlias,
    ),

    iconTheme: const IconThemeData(
      color: _accentColor, // Accent color for icons
      size: kMediumIconSize,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: _accentColor.withOpacity(0.15),
      labelStyle: TextStyle(color: _accentColor, fontWeight: FontWeight.w500, fontSize: 11),
      padding: const EdgeInsets.symmetric(horizontal: kSmallPadding, vertical: kSmallPadding/2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kDefaultBorderRadius/2)),
      side: BorderSide.none,
    ),

    tabBarTheme: TabBarTheme(
      labelColor: _accentColor,
      unselectedLabelColor: Colors.grey.shade400,
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(color: _accentColor, width: 3.0),
        insets: EdgeInsets.symmetric(horizontal: kDefaultPadding),
      ),
      labelStyle: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w500),
    ),

    dialogTheme: DialogTheme(
      backgroundColor: Colors.grey.shade850,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kCardBorderRadius)),
      titleTextStyle: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600, color: _accentColor),
      contentTextStyle: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey.shade300),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: _accentColor,
      unselectedItemColor: Colors.grey.shade500,
      backgroundColor: Colors.grey.shade900,
      elevation: 8.0,
       selectedLabelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 11),
      unselectedLabelStyle: GoogleFonts.montserrat(fontSize: 10),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _accentColor,
      foregroundColor: _textColor, // Dark text on light accent
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kDefaultBorderRadius * 2)),
    ),

    useMaterial3: true,
  );
}
