import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/providers/driver_providers.dart';

class DriverDashboard extends ConsumerWidget {
  const DriverDashboard({super.key});

  // ── Start trip confirmation dialog ─────────────────────────────────────

  void _showStartConfirmation(
      BuildContext context, WidgetRef ref, DriverAssignment assignment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.backgroundDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white12),
        ),
        title: const Text('Confirm Start Trip',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Start route ${assignment.routeName} with bus ${assignment.plateNumber}?\n\n'
          'GPS tracking will activate immediately.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(tripNotifierProvider.notifier).startTrip(
                    busId:   assignment.busId,
                    routeId: assignment.routeId,
                  );
              if (context.mounted) {
                context.go(AppRoutes.driverLive);
              }
            },
            child: const Text('Start',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentAsync = ref.watch(driverAssignmentProvider);
    final profile         = ref.watch(currentProfileProvider);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F111A), Color(0xFF131521)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Header ─────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${profile?.fullName.split(' ').first ?? 'Driver'}',
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 14),
                          ),
                          Text(
                            'Driver Dashboard',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: AppTheme.primaryColor),
                          ),
                        ],
                      ).animate().slideX().fadeIn(),
                      IconButton(
                        icon: const Icon(Icons.logout,
                            color: Colors.white54),
                        onPressed: () async {
                          await ref
                              .read(driverAuthProvider.notifier)
                              .signOut();
                          if (context.mounted) {
                            context.go(AppRoutes.driverLogin);
                          }
                        },
                      ).animate().scale().fadeIn(),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // ── Assignment panel ───────────────────────────────
                  Expanded(
                    child: assignmentAsync.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.primaryColor),
                      ),
                      error: (e, _) => Center(
                        child: Text('Error: $e',
                            style: const TextStyle(
                                color: AppTheme.errorColor)),
                      ),
                      data: (assignment) {
                        if (assignment == null) {
                          return _buildNoAssignment(context);
                        }
                        return _buildAssignmentPanel(
                            context, ref, assignment);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── No assignment state ───────────────────────────────────────────────

  Widget _buildNoAssignment(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.directions_bus_outlined,
              size: 80, color: Colors.white24),
          const SizedBox(height: 24),
          const Text(
            'No Active Assignment',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'You have no bus or route assigned.\nContact your admin.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  // ── Assignment details ────────────────────────────────────────────────

  Widget _buildAssignmentPanel(BuildContext context, WidgetRef ref,
      DriverAssignment assignment) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Bus info card
          GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Assigned Bus',
                        style: TextStyle(color: Colors.white70)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Ready',
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${assignment.plateNumber} — ${assignment.routeName}',
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  assignment.model,
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white12),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                        label: 'Capacity',
                        value: '${assignment.capacity} seats'),
                    _StatItem(
                        label: 'Status', value: 'Checked'),
                    _StatItem(
                        label: 'Score',
                        value: '${assignment.safetyScore}/100'),
                  ],
                ),
              ],
            ),
          ).animate().slideY(begin: 0.2).fadeIn(delay: 200.ms),

          const SizedBox(height: 24),

          // Safety score card
          Row(
            children: [
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.verified_user,
                          color: Colors.green, size: 30),
                      const SizedBox(height: 12),
                      const Text('Safety Score',
                          style: TextStyle(color: Colors.white54)),
                      const SizedBox(height: 4),
                      Text(
                        '${assignment.safetyScore}/100',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ).animate().slideX(begin: -0.2).fadeIn(delay: 400.ms),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.route,
                          color: AppTheme.accentColor, size: 30),
                      const SizedBox(height: 12),
                      const Text('Route',
                          style: TextStyle(color: Colors.white54)),
                      const SizedBox(height: 4),
                      Text(
                        assignment.routeName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ).animate().slideX(begin: 0.2).fadeIn(delay: 400.ms),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // START TRIP button
          AnimatedButton(
            text: 'START TRIP',
            icon: Icons.play_arrow,
            onPressed: () =>
                _showStartConfirmation(context, ref, assignment),
          ).animate().scale(delay: 600.ms).shimmer(delay: 1500.ms),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.5), fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
