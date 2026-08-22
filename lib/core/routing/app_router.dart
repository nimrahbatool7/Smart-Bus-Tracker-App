import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/passenger/presentation/screens/splash_screen.dart';
import '../../features/passenger/presentation/screens/onboarding_screen.dart';
import '../../features/passenger/presentation/screens/auth_screen.dart';
import '../../features/passenger/presentation/screens/passenger_dashboard.dart';
import '../../features/passenger/presentation/screens/destination_selection_screen.dart';

import '../../features/tickets/presentation/screens/buy_ticket_screen.dart';
import '../../features/tickets/presentation/screens/pass_management_screen.dart';
import '../../features/tickets/presentation/screens/wallet_screen.dart';
import '../../features/tickets/presentation/screens/passenger_qr_scanner_screen.dart';

import '../../features/driver/presentation/screens/driver_auth_screen.dart';
import '../../features/driver/presentation/screens/driver_dashboard.dart';
import '../../features/driver/presentation/screens/live_driving_mode.dart';
import '../../features/driver/presentation/screens/qr_scanner_screen.dart';

import '../../features/admin/presentation/screens/admin_login_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/driver_management_screen.dart';
import '../../features/admin/presentation/screens/admin_driver_details_screen.dart';
import '../../features/admin/presentation/screens/admin_live_fleet_screen.dart';
import '../../features/admin/presentation/screens/admin_vehicles_screen.dart';
import '../../features/admin/presentation/screens/admin_routes_screen.dart';
import '../../features/admin/presentation/screens/admin_tickets_screen.dart';
import '../../features/admin/presentation/screens/admin_payments_screen.dart';
import '../../features/admin/presentation/screens/admin_analytics_screen.dart';
import '../../features/admin/presentation/screens/admin_settings_screen.dart';
import '../../features/admin/presentation/screens/admin_profile_screen.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';

part 'app_router.g.dart';

// ── Route path constants ────────────────────────────────────────────────────

abstract class AppRoutes {
  static const splash             = '/splash';
  static const onboarding         = '/onboarding';
  static const login              = '/login';
  static const passengerDashboard = '/passenger_dashboard';
  static const destination        = '/destination';
  static const buyTicket          = '/buy-ticket';
  static const passes             = '/passes';
  static const wallet             = '/wallet';
  static const scanTicket         = '/scan-ticket';

  static const driverLogin        = '/driver/login';
  static const driverDashboard    = '/driver/dashboard';
  static const driverLive         = '/driver/live';
  static const driverScanner      = '/driver/scanner';

  static const adminLogin         = '/admin/login';
  static const adminDashboard     = '/admin/dashboard';
  static const adminDrivers       = '/admin/drivers';
  static const adminVehicles      = '/admin/vehicles';
  static const adminRoutes        = '/admin/routes';
  static const adminFleet         = '/admin/fleet';
  static const adminTickets       = '/admin/tickets';
  static const adminPayments      = '/admin/payments';
  static const adminAnalytics     = '/admin/analytics';
  static const adminSettings      = '/admin/settings';
  static const adminProfile       = '/admin/profile';
}

// ── Passenger-only routes ────────────────────────────────────────────────────

const _passengerRoutes = {
  AppRoutes.passengerDashboard,
  AppRoutes.destination,
  AppRoutes.buyTicket,
  AppRoutes.passes,
  AppRoutes.wallet,
  AppRoutes.scanTicket,
};

// ── Driver-only routes ────────────────────────────────────────────────────────

const _driverRoutes = {
  AppRoutes.driverDashboard,
  AppRoutes.driverLive,
  AppRoutes.driverScanner,
};

// ── Admin-only routes ─────────────────────────────────────────────────────────

const _adminRoutes = {
  AppRoutes.adminDashboard,
  AppRoutes.adminDrivers,
  AppRoutes.adminVehicles,
  AppRoutes.adminRoutes,
  AppRoutes.adminFleet,
  AppRoutes.adminTickets,
  AppRoutes.adminPayments,
  AppRoutes.adminAnalytics,
  AppRoutes.adminSettings,
  AppRoutes.adminProfile,
};

// ── Router provider ──────────────────────────────────────────────────────────

@riverpod
GoRouter appRouter(Ref ref) {
  // Re-evaluate redirect whenever auth state changes
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    // Redirect fires on every navigation attempt
    redirect: (context, state) {
      final path = state.matchedLocation;

      // While the auth stream is loading, stay put
      if (authState.isLoading) return null;

      final session = authState.value?.session;
      final isAuthenticated = session != null;

      // ── Unauthenticated user trying to access a protected route ────────────
      if (!isAuthenticated) {
        if (_passengerRoutes.any((r) => path.startsWith(r))) {
          return AppRoutes.login;
        }
        if (_driverRoutes.any((r) => path.startsWith(r))) {
          return AppRoutes.driverLogin;
        }
        if (_adminRoutes.any((r) => path.startsWith(r))) {
          return AppRoutes.adminLogin;
        }
        return null; // allow public routes
      }

      // ── Authenticated user — enforce role-based access ────────────────────
      final profile = ref.read(currentProfileProvider);
      if (profile == null) return null; // profile still loading

      final role = profile.role;

      // Passenger trying to access driver/admin routes
      if (role == 'passenger') {
        if (_driverRoutes.any((r) => path.startsWith(r))) {
          return AppRoutes.passengerDashboard;
        }
        if (_adminRoutes.any((r) => path.startsWith(r))) {
          return AppRoutes.passengerDashboard;
        }
        // Redirect from any login screen back to their dashboard
        if (path == AppRoutes.login ||
            path == AppRoutes.driverLogin ||
            path == AppRoutes.adminLogin) {
          return AppRoutes.passengerDashboard;
        }
      }

      // Driver trying to access passenger/admin routes
      if (role == 'driver') {
        if (_passengerRoutes.any((r) => path.startsWith(r))) {
          return AppRoutes.driverDashboard;
        }
        if (_adminRoutes.any((r) => path.startsWith(r))) {
          return AppRoutes.driverDashboard;
        }
        if (path == AppRoutes.login ||
            path == AppRoutes.driverLogin ||
            path == AppRoutes.adminLogin) {
          return AppRoutes.driverDashboard;
        }
      }

      // Admin trying to access passenger/driver routes
      if (role == 'admin') {
        if (_passengerRoutes.any((r) => path.startsWith(r))) {
          return AppRoutes.adminDashboard;
        }
        if (_driverRoutes.any((r) => path.startsWith(r))) {
          return AppRoutes.adminDashboard;
        }
        if (path == AppRoutes.login ||
            path == AppRoutes.driverLogin ||
            path == AppRoutes.adminLogin) {
          return AppRoutes.adminDashboard;
        }
      }

      return null; // no redirect needed
    },

    routes: [
      // ── Public ─────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, _) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, _) => const OnboardingScreen(),
      ),

      // ── Passenger ──────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        builder: (context, _) => const AuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.passengerDashboard,
        builder: (context, _) => const PassengerDashboard(),
      ),
      GoRoute(
        path: AppRoutes.destination,
        builder: (context, _) => const DestinationSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.buyTicket,
        builder: (context, _) => const BuyTicketScreen(),
      ),
      GoRoute(
        path: AppRoutes.passes,
        builder: (context, _) => const PassManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.wallet,
        builder: (context, _) => const WalletScreen(),
      ),
      GoRoute(
        path: AppRoutes.scanTicket,
        builder: (context, _) => const PassengerQrScannerScreen(),
      ),

      // ── Driver ─────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.driverLogin,
        builder: (context, _) => const DriverAuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.driverDashboard,
        builder: (context, _) => const DriverDashboard(),
      ),
      GoRoute(
        path: AppRoutes.driverLive,
        builder: (context, _) => const LiveDrivingMode(),
      ),
      GoRoute(
        path: AppRoutes.driverScanner,
        builder: (context, _) => const QRScannerScreen(),
      ),

      // ── Admin ──────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.adminLogin,
        builder: (context, _) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (context, _) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminDrivers,
        builder: (context, _) => const DriverManagementScreen(),
      ),
      GoRoute(
        path: '/admin/drivers/:id',
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          return AdminDriverDetailsScreen(driverId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.adminVehicles,
        builder: (context, _) => const AdminVehiclesScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminRoutes,
        builder: (context, _) => const AdminRoutesScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminFleet,
        builder: (context, _) => const AdminLiveFleetScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminTickets,
        builder: (context, _) => const AdminTicketsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminPayments,
        builder: (context, _) => const AdminPaymentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminAnalytics,
        builder: (context, _) => const AdminAnalyticsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminSettings,
        builder: (context, _) => const AdminSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminProfile,
        builder: (context, _) => const AdminProfileScreen(),
      ),
    ],
  );
}
