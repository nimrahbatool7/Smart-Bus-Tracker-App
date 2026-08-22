import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../data/providers/admin_providers.dart';
import 'admin_layout.dart';

class DriverManagementScreen extends ConsumerWidget {
  const DriverManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile   = MediaQuery.of(context).size.width < 600;
    final filtered   = ref.watch(filteredDriversProvider);
    final statusState= ref.watch(driverStatusProvider);

    // Show snackbar on status update result
    ref.listen(driverStatusProvider, (_, next) {
      next.whenOrNull(
        data: (_) {
          ref.invalidate(driversProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Driver status updated'),
              backgroundColor: Colors.green,
            ),
          );
        },
        error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.errorColor,
          ),
        ),
      );
    });

    return AdminLayout(
      selectedIndex: 1,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Driver Management',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Add Driver',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Search ───────────────────────────────────────────────
            GlassCard(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.white54),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Search driver by name or phone…',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                      onChanged: (v) => ref
                          .read(driverSearchQueryProvider.notifier)
                          .state = v,
                    ),
                  ),
                ],
              ),
            ).animate().slideY(begin: -0.1).fadeIn(),

            const SizedBox(height: 24),

            // ── Driver list ──────────────────────────────────────────
            Expanded(
              child: filtered.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.primaryColor)),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $e',
                          style: const TextStyle(
                              color: AppTheme.errorColor)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            ref.invalidate(driversProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (drivers) {
                  if (drivers.isEmpty) {
                    return const Center(
                      child: Text('No drivers found.',
                          style: TextStyle(color: Colors.white54)),
                    );
                  }
                  return ListView.builder(
                    itemCount: drivers.length,
                    itemBuilder: (ctx, i) =>
                        _buildDriverCard(ctx, ref, drivers[i], i,
                            statusState.isLoading),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverCard(BuildContext context, WidgetRef ref,
      DriverProfile driver, int index, bool isUpdating) {
    Color statusColor;
    switch (driver.status) {
      case 'active':
        statusColor = Colors.green;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white12,
                  child: Icon(Icons.person, color: Colors.white70),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(driver.fullName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white)),
                      Text(
                        driver.phone ?? 'No phone',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    driver.status[0].toUpperCase() +
                        driver.status.substring(1),
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Active Route',
                        style: TextStyle(
                            color: Colors.white54, fontSize: 12)),
                    Text(
                      driver.routeName ?? 'Not on trip',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (driver.status == 'pending')
                      _actionBtn(
                        Icons.check,
                        Colors.green,
                        'Approve',
                        isUpdating
                            ? null
                            : () => ref
                                .read(driverStatusProvider.notifier)
                                .updateStatus(driver.id, 'active'),
                      ),
                    if (driver.status == 'active')
                      _actionBtn(
                        Icons.block,
                        Colors.red,
                        'Suspend',
                        isUpdating
                            ? null
                            : () => ref
                                .read(driverStatusProvider.notifier)
                                .updateStatus(driver.id, 'suspended'),
                      ),
                    if (driver.status == 'suspended')
                      _actionBtn(
                        Icons.check_circle_outline,
                        Colors.green,
                        'Reinstate',
                        isUpdating
                            ? null
                            : () => ref
                                .read(driverStatusProvider.notifier)
                                .updateStatus(driver.id, 'active'),
                      ),
                    const SizedBox(width: 8),
                    _actionBtn(
                      Icons.visibility,
                      Colors.blue,
                      'Details',
                      () => context
                          .push('/admin/drivers/${driver.id}'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ).animate().slideX(begin: 0.1).fadeIn(
          delay: Duration(milliseconds: 100 * index)),
    );
  }

  Widget _actionBtn(IconData icon, Color color, String tooltip,
      VoidCallback? onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (onTap == null ? Colors.grey : color)
                .withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon,
              color: onTap == null ? Colors.grey : color,
              size: 20),
        ),
      ),
    );
  }
}
