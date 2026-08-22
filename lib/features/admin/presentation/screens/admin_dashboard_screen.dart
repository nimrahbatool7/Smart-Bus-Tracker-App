import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../data/providers/admin_providers.dart';
import 'admin_layout.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpisAsync = ref.watch(dashboardKpisProvider);

    return AdminLayout(
      selectedIndex: 0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          return kpisAsync.when(
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
                        ref.invalidate(dashboardKpisProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (kpis) => SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Platform Overview',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                  ),
                  const SizedBox(height: 24),

                  // ── KPI grid ──────────────────────────────────────
                  GridView.count(
                    crossAxisCount: isMobile ? 2 : 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    childAspectRatio: isMobile ? 1.1 : 1.3,
                    children: [
                      _KpiCard(
                        title: 'Total Buses',
                        value: '${kpis.totalBuses}',
                        icon: Icons.directions_bus,
                        color: Colors.blue,
                      ),
                      _KpiCard(
                        title: 'Active Drivers',
                        value: '${kpis.activeDrivers}',
                        icon: Icons.person,
                        color: Colors.green,
                      ),
                      _KpiCard(
                        title: 'Passengers',
                        value: kpis.totalPassengers >= 1000
                            ? '${(kpis.totalPassengers / 1000).toStringAsFixed(1)}k'
                            : '${kpis.totalPassengers}',
                        icon: Icons.people,
                        color: AppTheme.accentColor,
                      ),
                      _KpiCard(
                        title: 'Revenue',
                        value:
                            '\$${kpis.totalRevenue.toStringAsFixed(0)}',
                        icon: Icons.attach_money,
                        color: AppTheme.primaryColor,
                      ),
                    ],
                  ).animate().slideY(begin: 0.1).fadeIn(),

                  const SizedBox(height: 32),

                  // ── Charts + alerts ───────────────────────────────
                  if (isMobile) ...[
                    _buildRevenueChart(kpis),
                    const SizedBox(height: 24),
                    _buildAlerts(kpis),
                    const SizedBox(height: 100),
                  ] else
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 2,
                            child: _buildRevenueChart(kpis)),
                        const SizedBox(width: 24),
                        Expanded(
                            flex: 1, child: _buildAlerts(kpis)),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRevenueChart(DashboardKpis kpis) {
    final spots = kpis.revenueByDay
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Revenue — Last 7 Days',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      const FlLine(
                          color: Colors.white12, strokeWidth: 1),
                ),
                titlesData:
                    const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppTheme.primaryColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primaryColor
                          .withOpacity(0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().slideX(begin: -0.1).fadeIn(delay: 200.ms);
  }

  Widget _buildAlerts(DashboardKpis kpis) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Alerts',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          const SizedBox(height: 16),
          if (kpis.recentAlerts.isEmpty)
            const Text('No unresolved alerts.',
                style: TextStyle(color: Colors.white54))
          else
            ...kpis.recentAlerts.map((a) {
              final type = a['type'] as String? ?? '';
              final profile =
                  a['profiles'] as Map<String, dynamic>?;
              final bus =
                  a['buses'] as Map<String, dynamic>?;
              final driver =
                  profile?['full_name'] as String? ?? '?';
              final plate =
                  bus?['plate_number'] as String? ?? '?';
              final ts = a['created_at'] as String? ?? '';
              final dt = DateTime.tryParse(ts);
              final ago = dt != null
                  ? _timeAgo(dt)
                  : '';

              Color dot;
              switch (type) {
                case 'speed_violation':
                  dot = Colors.red;
                  break;
                case 'route_deviation':
                  dot = Colors.orange;
                  break;
                case 'late_arrival':
                  dot = Colors.yellow;
                  break;
                default:
                  dot = Colors.blue;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          color: dot,
                          shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            _friendlyType(type),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Text(
                            '$driver • $plate • $ago',
                            style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    ).animate().slideX(begin: 0.1).fadeIn(delay: 200.ms);
  }

  String _friendlyType(String t) {
    switch (t) {
      case 'speed_violation':
        return 'Speed Violation';
      case 'route_deviation':
        return 'Route Deviation';
      case 'late_arrival':
        return 'Late Arrival';
      case 'maintenance':
        return 'Maintenance';
      default:
        return t;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} days ago';
  }
}

// ── KPI card widget ──────────────────────────────────────────────────────────

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String  title;
  final String  value;
  final IconData icon;
  final Color   color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}
