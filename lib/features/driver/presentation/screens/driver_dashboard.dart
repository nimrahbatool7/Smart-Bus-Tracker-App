import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/animated_button.dart';

class DriverDashboard extends StatelessWidget {
  const DriverDashboard({super.key});

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Driver Dashboard', style: TextStyle(color: Colors.white.withOpacity(0.5))),
                          Text('Shift Active', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.primaryColor)),
                        ],
                      ).animate().slideX().fadeIn(),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white54),
                        onPressed: () => context.go('/driver/login'),
                      ).animate().scale().fadeIn(),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Big Information Panel
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          GlassCard(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Assigned Bus', style: TextStyle(color: Colors.white70)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text('Ready', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'A1 - Downtown Express',
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                                ),
                                const SizedBox(height: 16),
                                const Divider(color: Colors.white12),
                                const SizedBox(height: 16),
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _StatItem(label: 'Capacity', value: '45 Seats'),
                                    _StatItem(label: 'Battery', value: '88%'),
                                    _StatItem(label: 'Status', value: 'Checked'),
                                  ],
                                ),
                              ],
                            ),
                          ).animate().slideY(begin: 0.2).fadeIn(delay: 200.ms),
                          
                          const SizedBox(height: 24),
                          
                          // Safety Score
                          Row(
                            children: [
                              Expanded(
                                child: GlassCard(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.verified_user, color: Colors.green, size: 30),
                                      const SizedBox(height: 12),
                                      Text('Safety Score', style: TextStyle(color: Colors.white.withOpacity(0.5))),
                                      const SizedBox(height: 4),
                                      const Text('98/100', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                                      const Icon(Icons.schedule, color: AppTheme.accentColor, size: 30),
                                      const SizedBox(height: 12),
                                      Text('Next Trip', style: TextStyle(color: Colors.white.withOpacity(0.5))),
                                      const SizedBox(height: 4),
                                      const Text('10:00 AM', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ).animate().slideX(begin: 0.2).fadeIn(delay: 400.ms),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Start Trip Button
                  Container(
                    margin: const EdgeInsets.only(bottom: 20, top: 20),
                    child: AnimatedButton(
                      text: 'START TRIP',
                      icon: Icons.play_arrow,
                      onPressed: () {
                        _showStartTripConfirmation(context);
                      },
                    ).animate().scale(delay: 600.ms).shimmer(delay: 1500.ms),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStartTripConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.white12)),
        title: const Text('Confirm Start Trip', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you ready to start Route A1? GPS tracking will be activated.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              context.go('/driver/live');
            },
            child: const Text('Start', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
