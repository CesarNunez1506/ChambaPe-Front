import 'package:chamba_app/navigation/app_router.dart';
import 'package:chamba_app/navigation/app_routes.dart';
import 'package:chamba_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:chamba_app/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Import for localizations

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Add other providers here if needed for other features:
        // ChangeNotifierProvider(create: (_) => ServiceProvider()),
        // ChangeNotifierProvider(create: (_) => WorkerProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chamba App Perú',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Or ThemeMode.system to follow system settings. Forcing light for consistency in demo.
      debugShowCheckedModeBanner: false,

      // Localization settings for Spanish (Peru)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'PE'), // Spanish, Peru
        Locale('en', 'US'), // English, US (fallback)
      ],
      locale: const Locale('es', 'PE'), // Set default locale to Spanish (Peru)

      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: AppRoutes.landing,
    );
  }
}
