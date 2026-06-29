import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../widgets/location_permission_dialog.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _currentLocation = 'Current Location';

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final headerColor = isLight ? AppTheme.lightBlueHeader : Colors.blue.shade900.withValues(alpha: 0.5);

    return Scaffold(
      backgroundColor: Colors.transparent, // Let Dashboard's background show
      body: Stack(
        children: [
          // Top Blue Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 250,
            child: Container(
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.menu, color: Colors.white),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Hello, Rider!',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Where would you like to go?',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.white.withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Icon(Icons.notifications_none, color: Colors.white),
                          ],
                        ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
                        
                        const SizedBox(height: 30),
                        
                        // Location Card
                        GlassCard(
                          padding: const EdgeInsets.all(20),
                          color: isLight ? Colors.white : null,
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  const Icon(Icons.circle, size: 12, color: Colors.blue),
                                  Container(height: 30, width: 2, color: isLight ? Colors.grey.shade300 : Colors.white24),
                                  const Icon(Icons.location_on, size: 16, color: Colors.red),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                    onTap: () {
                                      LocationPermissionDialog.show(context, onGranted: () {
                                        setState(() {
                                          _currentLocation = 'Downtown Ave, NY';
                                        });
                                      });
                                    },
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('From', style: TextStyle(fontSize: 12, color: isLight ? Colors.grey.shade600 : Colors.white60)),
                                        Text(_currentLocation, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isLight ? Colors.black87 : Colors.white)),
                                      ],
                                    ),
                                  ),
                                  Divider(height: 20, color: isLight ? Colors.grey.shade200 : Colors.white12),
                                  GestureDetector(
                                    onTap: () {
                                      context.push('/destination');
                                    },
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('To', style: TextStyle(fontSize: 12, color: isLight ? Colors.grey.shade600 : Colors.white60)),
                                        Text('Select Destination', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: isLight ? Colors.grey.shade400 : Colors.white54)),
                                      ],
                                    ),
                                  ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isLight ? Colors.grey.shade100 : Colors.white12,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.swap_vert, size: 20, color: isLight ? Colors.black54 : Colors.white),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                        
                        const SizedBox(height: 30),
                        
                        Text(
                          'Nearby Buses',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate().fadeIn(delay: 400.ms),
                        
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                
                SliverPadding(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final buses = [
                          {'id': '23A', 'name': 'City Center', 'via': 'Main Street', 'eta': '3 min', 'dist': '2.4 km away'},
                          {'id': '15B', 'name': 'Green Park', 'via': 'Market Road', 'eta': '7 min', 'dist': '4.1 km away'},
                          {'id': '31C', 'name': 'University', 'via': 'Station Road', 'eta': '11 min', 'dist': '5.6 km away'},
                        ];
                        final bus = buses[index];
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: GlassCard(
                            color: isLight ? Colors.white : null,
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade700,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      bus['id']!,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(bus['name']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isLight ? Colors.black87 : Colors.white)),
                                      const SizedBox(height: 2),
                                      Text('via ${bus['via']}', style: TextStyle(fontSize: 13, color: isLight ? Colors.grey.shade600 : Colors.white60)),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Icon(Icons.directions_bus, size: 14, color: Colors.green.shade600),
                                          const SizedBox(width: 4),
                                          Text('Live', style: TextStyle(fontSize: 13, color: Colors.green.shade600, fontWeight: FontWeight.w600)),
                                          const SizedBox(width: 16),
                                          Icon(Icons.location_on_outlined, size: 14, color: isLight ? Colors.grey.shade500 : Colors.white54),
                                          const SizedBox(width: 4),
                                          Text(bus['dist']!, style: TextStyle(fontSize: 13, color: isLight ? Colors.grey.shade500 : Colors.white54)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(bus['eta']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isLight ? Colors.black87 : Colors.white)),
                                    Text('Arrival', style: TextStyle(fontSize: 12, color: isLight ? Colors.grey.shade600 : Colors.white60)),
                                  ],
                                )
                              ],
                            ),
                          ).animate().fadeIn(delay: Duration(milliseconds: 600 + (index * 150))).slideX(begin: 0.1),
                        );
                      },
                      childCount: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
