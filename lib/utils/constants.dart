import 'package:flutter/material.dart';

// App Colors (can be used if not relying solely on Theme)
const Color kPrimaryColor = Color(0xFF0D47A1); // Professional Blue
const Color kSecondaryColor = Color(0xFF2E7D32); // Professional Green
const Color kAccentColor = Color(0xFFFFC107); // A touch of yellow/gold
const Color kBackgroundColor = Color(0xFFF5F5F5); // Light Cream/Off-white
const Color kTextColor = Color(0xFF333333);
const Color kCardColor = Colors.white;
const Color kErrorColor = Colors.red;
const Color kSuccessColor = Colors.green;
const Color kWarningColor = Colors.orange;

// Standard Padding & Margin Values
const double kDefaultPadding = 16.0;
const double kDefaultMargin = 16.0;
const double kSmallPadding = 8.0;
const double kSmallMargin = 8.0;
const double kLargePadding = 24.0;
const double kLargeMargin = 24.0;

// Border Radius
const double kDefaultBorderRadius = 8.0;
const double kCardBorderRadius = 12.0;

// Icon Sizes
const double kSmallIconSize = 16.0;
const double kMediumIconSize = 24.0;
const double kLargeIconSize = 32.0;

// Font Sizes (can be used for specific overrides if TextTheme is not enough)
const double kFontSizeSmall = 12.0;
const double kFontSizeMedium = 14.0;
const double kFontSizeLarge = 16.0;
const double kFontSizeXLarge = 18.0;
const double kFontSizeXXLarge = 20.0;
const double kFontSizeTitle = 24.0;

// API Endpoints (Placeholders - replace with actual API URLs)
const String kApiBaseUrl = "https://api.examplechamba.com/v1";
const String kLoginEndpoint = "/auth/login";
const String kRegisterEndpoint = "/auth/register";
const String kServicesEndpoint = "/services";
const String kTasksEndpoint = "/tasks";
const String kUserProfileEndpoint = "/users/me";
const String kSubscriptionsEndpoint = "/subscriptions";

// Asset Paths (Ensure these assets exist in your assets folder and pubspec.yaml)
// const String kLogoPath = "assets/images/logo.png";
// const String kProfilePlaceholderPath = "assets/images/profile_placeholder.png";
// const String kServicePlaceholderPath = "assets/images/service_placeholder.png";

// Example Categories (can be fetched from API later)
const List<String> kServiceCategories = [
  "Jardinería",
  "Plomería",
  "Gasfitería",
  "Pintura",
  "Electricidad",
  "Carpintería",
  "Limpieza",
  "Mudanza",
  "Reparaciones Generales",
  "Cuidado de Mascotas",
  "Clases Particulares",
];

// Keys for SharedPreferences or Secure Storage (if used)
const String kAuthTokenKey = "AUTH_TOKEN";
const String kUserTypeKey = "USER_TYPE";
const String kUserIdKey = "USER_ID";

// Other constants
const String kAppName = "Chamba Perú";
const String kDefaultCountryCode = "+51"; // Peru

// Verification Status
const String kVerifiedText = "Verificado";
const String kNotVerifiedText = "No Verificado";

// Star Rating
const int kMaxRating = 5;
