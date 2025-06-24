import 'package:chamba_app/screens/auth_screen.dart';
import 'package:chamba_app/screens/client/client_dashboard_screen.dart';
import 'package:chamba_app/screens/client/create_service_screen.dart';
import 'package:chamba_app/screens/client/client_task_detail_screen.dart';
import 'package:chamba_app/screens/landing_screen.dart';
import 'package:chamba_app/screens/misc/forgot_password_screen.dart';
import 'package:chamba_app/screens/subscriptions_screen.dart';
import 'package:chamba_app/screens/worker/worker_dashboard_screen.dart';
import 'package:chamba_app/screens/worker/worker_task_detail_screen.dart';
import 'package:flutter/material.dart';
import 'app_routes.dart';

// Placeholder screen for routes not yet fully implemented
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(title)), body: Center(child: Text(title)));
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // final args = settings.arguments; // Use if passing arguments

    switch (settings.name) {
      case AppRoutes.landing:
        return MaterialPageRoute(builder: (_) => const LandingScreen());
      case AppRoutes.auth: // This could be a generic entry point if needed, but specific routes are better.
        return MaterialPageRoute(builder: (_) => const AuthScreen(isLoginScreen: true));
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const AuthScreen(isLoginScreen: true));
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const AuthScreen(isLoginScreen: false));
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      // Client Routes
      case AppRoutes.clientDashboard:
        return MaterialPageRoute(builder: (_) => const ClientDashboardScreen());
      case AppRoutes.clientCreateService:
        return MaterialPageRoute(builder: (_) => const CreateServiceScreen());
      case AppRoutes.clientServiceDetails:
        if (settings.arguments is String) {
          final serviceId = settings.arguments as String;
          return MaterialPageRoute(builder: (_) => ClientTaskDetailScreen(taskId: serviceId));
        }
        return _errorRoute("Client Service Details: Missing serviceId argument");

      // Worker Routes
      case AppRoutes.workerDashboard:
        return MaterialPageRoute(builder: (_) => const WorkerDashboardScreen());
      case AppRoutes.workerTaskDetails:
         if (settings.arguments is String) {
          final taskId = settings.arguments as String;
          return MaterialPageRoute(builder: (_) => WorkerTaskDetailScreen(taskId: taskId));
        }
        return _errorRoute("Worker Task Details: Missing taskId argument");

      // Common Routes
      case AppRoutes.subscriptions:
        return MaterialPageRoute(builder: (_) => const SubscriptionsScreen());

      // Placeholder routes for not-yet-implemented screens
      case AppRoutes.clientTaskHistory:
        return MaterialPageRoute(builder: (_) => const PlaceholderScreen(title: 'Historial Cliente'));
      case AppRoutes.clientProfile:
        return MaterialPageRoute(builder: (_) => const PlaceholderScreen(title: 'Perfil Cliente'));
      case AppRoutes.workerTaskHistory:
        return MaterialPageRoute(builder: (_) => const PlaceholderScreen(title: 'Historial Trabajador'));
      case AppRoutes.workerProfile:
        return MaterialPageRoute(builder: (_) => const PlaceholderScreen(title: 'Perfil Trabajador'));
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const PlaceholderScreen(title: 'Configuración'));
      case AppRoutes.notifications:
        return MaterialPageRoute(builder: (_) => const PlaceholderScreen(title: 'Notificaciones'));
      case AppRoutes.helpSupport:
        return MaterialPageRoute(builder: (_) => const PlaceholderScreen(title: 'Ayuda y Soporte'));
      case AppRoutes.userDetails:
         if (settings.arguments is String) {
          final userId = settings.arguments as String;
          return MaterialPageRoute(builder: (_) => PlaceholderScreen(title: 'Detalle Usuario $userId'));
        }
        return _errorRoute("User Details: Missing userId argument");


      default:
        return _errorRoute("Ruta no encontrada: ${settings.name}");
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error de Navegación')),
        body: Center(child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('ERROR: $message', textAlign: TextAlign.center),
        )),
      );
    });
  }
}

// To use this AppRouter, in your MaterialApp:
// MaterialApp(
//   title: 'Chamba App Perú',
//   theme: AppTheme.lightTheme,
//   onGenerateRoute: AppRouter.generateRoute,
//   initialRoute: AppRoutes.landing,
//   // ... other properties
// )

// For navigation:
// Navigator.pushNamed(context, AppRoutes.clientDashboard);
// Navigator.pushNamed(context, AppRoutes.clientServiceDetails, arguments: "service_id_123");
