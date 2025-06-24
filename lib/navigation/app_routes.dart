// ignore_for_file: constant_identifier_names

// Defines the route names used throughout the application.
// This helps in avoiding typos and managing navigation paths centrally.

class AppRoutes {
  static const String landing = '/';
  static const String auth = '/auth'; // Could be a wrapper for login/register
  static const String login = '/login'; // Specific login route if not using /auth
  static const String register = '/register'; // Specific register route
  static const String forgotPassword = '/forgot-password';

  // Client Routes
  static const String clientDashboard = '/client/dashboard';
  static const String clientCreateService = '/client/create-service';
  static const String clientServiceDetails = '/client/service-details'; // e.g., /client/service-details/123
  static const String clientTaskHistory = '/client/task-history';
  static const String clientProfile = '/client/profile';
  static const String clientRateWorker = '/client/rate-worker'; // e.g., /client/rate-worker/taskId

  // Worker Routes
  static const String workerDashboard = '/worker/dashboard';
  static const String workerTaskDetails = '/worker/task-details'; // e.g., /worker/task-details/123
  static const String workerTaskHistory = '/worker/task-history';
  static const String workerProfile = '/worker/profile';
  static const String workerEarnings = '/worker/earnings';
  static const String workerRateClient = '/worker/rate-client'; // e.g., /worker/rate-client/taskId

  // Common/Shared Routes
  static const String subscriptions = '/subscriptions';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String helpSupport = '/help-support';
  static const String userDetails = '/user-details'; // e.g. /user-details/userId for viewing other profiles

  // Helper method to create routes with parameters
  // Example: AppRoutes.serviceDetails('client', '123') -> /client/service-details/123
  static String serviceDetails(String userRole, String serviceId) {
    if (userRole == 'client') {
      return '$clientServiceDetails/$serviceId';
    } else if (userRole == 'worker') {
      return '$workerTaskDetails/$serviceId';
    }
    return '/'; // Fallback
  }

   static String rateScreen(String userRole, String taskId) {
    if (userRole == 'client') {
      return '$clientRateWorker/$taskId';
    } else if (userRole == 'worker') {
      return '$workerRateClient/$taskId';
    }
    return '/'; // Fallback
  }
}

// Example of how routes might be configured in main.dart or a dedicated router file (GoRouter, AutoRoute, etc.)
/*
GoRouter(
  initialLocation: AppRoutes.landing,
  routes: [
    GoRoute(
      path: AppRoutes.landing,
      builder: (context, state) => LandingScreen(),
    ),
    GoRoute(
      path: AppRoutes.auth,
      builder: (context, state) => AuthScreen(), // AuthScreen might handle if it's login or register
    ),
    GoRoute(
      path: '${AppRoutes.clientServiceDetails}/:serviceId', // Example with path parameter
      builder: (context, state) {
        final serviceId = state.pathParameters['serviceId']!;
        return ClientServiceDetailScreen(serviceId: serviceId);
      },
    ),
    // ... other routes
  ],
)
*/
