import 'package:flutter/material.dart';
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

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      // Passenger Routes
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/passenger_dashboard',
        builder: (context, state) => const PassengerDashboard(),
      ),
      GoRoute(
        path: '/destination',
        builder: (context, state) => const DestinationSelectionScreen(),
      ),
      GoRoute(
        path: '/buy-ticket',
        builder: (context, state) => const BuyTicketScreen(),
      ),
      GoRoute(
        path: '/passes',
        builder: (context, state) => const PassManagementScreen(),
      ),
      GoRoute(
        path: '/wallet',
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: '/scan-ticket',
        builder: (context, state) => const PassengerQrScannerScreen(),
      ),
      // Driver Routes
      GoRoute(
        path: '/driver/login',
        builder: (context, state) => const DriverAuthScreen(),
      ),
      GoRoute(
        path: '/driver/dashboard',
        builder: (context, state) => const DriverDashboard(),
      ),
      GoRoute(
        path: '/driver/live',
        builder: (context, state) => const LiveDrivingMode(),
      ),
      GoRoute(
        path: '/driver/scanner',
        builder: (context, state) => const QRScannerScreen(),
      ),
      // Admin Routes
      GoRoute(
        path: '/admin/login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/drivers',
        builder: (context, state) => const DriverManagementScreen(),
      ),
      GoRoute(
        path: '/admin/drivers/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AdminDriverDetailsScreen(driverId: id);
        },
      ),
      GoRoute(
        path: '/admin/vehicles',
        builder: (context, state) => const AdminVehiclesScreen(),
      ),
      GoRoute(
        path: '/admin/routes',
        builder: (context, state) => const AdminRoutesScreen(),
      ),
      GoRoute(
        path: '/admin/tickets',
        builder: (context, state) => const AdminTicketsScreen(),
      ),
      GoRoute(
        path: '/admin/payments',
        builder: (context, state) => const AdminPaymentsScreen(),
      ),
      GoRoute(
        path: '/admin/analytics',
        builder: (context, state) => const AdminAnalyticsScreen(),
      ),
      GoRoute(
        path: '/admin/fleet',
        builder: (context, state) => const AdminLiveFleetScreen(),
      ),
      GoRoute(
        path: '/admin/settings',
        builder: (context, state) => const AdminSettingsScreen(),
      ),
      GoRoute(
        path: '/admin/profile',
        builder: (context, state) => const AdminProfileScreen(),
      ),
    ],
  );
}

