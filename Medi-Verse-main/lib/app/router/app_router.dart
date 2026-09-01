import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/ambulance/presentation/views/ambulance_tracking_dashboard_screen.dart';
import '../../features/ambulance/presentation/views/emergency_dispatch_tracking_screen.dart';
import '../../features/auth/presentation/views/login_screen.dart';
import '../../features/auth/presentation/views/register_screen.dart';
import '../../features/auth/presentation/views/splash_screen.dart';
import '../../features/dashboard/presentation/views/patient_dashboard_screen.dart';
import '../../features/hospital/presentation/views/live_emergency_map_screen.dart';
import '../../features/triage/presentation/views/ai_nurse_triage_screen.dart';
import 'route_names.dart';

/// Central GoRouter configuration
final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.splash,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RouteNames.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: RouteNames.home,
      builder: (context, state) => const PatientDashboardScreen(),
    ),
    GoRoute(
      path: RouteNames.triageAssess,
      builder: (context, state) => const AiNurseTriageScreen(),
    ),
    GoRoute(
      path: RouteNames.hospitalSearch,
      builder: (context, state) => const LiveEmergencyMapScreen(),
    ),
    GoRoute(
      path: RouteNames.sosModal,
      builder: (context, state) => const EmergencyDispatchTrackingScreen(initialStep: 0),
    ),
    GoRoute(
      path: RouteNames.searchingAmbulance,
      builder: (context, state) => const EmergencyDispatchTrackingScreen(initialStep: 1),
    ),
    GoRoute(
      path: RouteNames.liveTracking,
      builder: (context, state) => const EmergencyDispatchTrackingScreen(initialStep: 2),
    ),
    GoRoute(
      path: RouteNames.ambulanceDashboard,
      builder: (context, state) => const AmbulanceTrackingDashboardScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Page Not Found')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Route not found: ${state.uri.path}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go(RouteNames.home),
            child: const Text('Back to Home'),
          ),
        ],
      ),
    ),
  ),
);

/// Riverpod Provider exposing GoRouter Instance for Dependency Injection
final routerProvider = Provider<GoRouter>((ref) {
  return appRouter;
});
