import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import 'admin_layout.dart';

class DriverManagementScreen extends StatelessWidget {
  const DriverManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      selectedIndex: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          return Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Driver Management', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('Add Driver', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 24),

                // Search and Filter
                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.white54),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Search driver by name or ID...',
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                          ),
                          onChanged: (val) {},
                        ),
                      ),
                      const Icon(Icons.filter_list, color: Colors.white54),
                    ],
                  ),
                ).animate().slideY(begin: -0.1).fadeIn(),
                
                const SizedBox(height: 24),

                // List of Drivers
                Expanded(
                  child: ListView.builder(
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      final drivers = [
                        {'id': 'D-1023', 'name': 'James Wilson', 'route': 'Downtown Express', 'status': 'Active'},
                        {'id': 'D-1024', 'name': 'Sarah Connor', 'route': 'University Line', 'status': 'Pending'},
                        {'id': 'D-1025', 'name': 'Michael Chang', 'route': 'City Loop', 'status': 'Suspended'},
                        {'id': 'D-1026', 'name': 'Emily Davis', 'route': 'Airport Shuttle', 'status': 'Active'},
                      ];
                      final driver = drivers[index];
                      final status = driver['status'] as String;

                      Color statusColor;
                      if (status == 'Active') statusColor = Colors.green;
                      else if (status == 'Pending') statusColor = Colors.orange;
                      else statusColor = Colors.red;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
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
                                        Text(driver['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                                        Text('ID: ${driver['id']}', style: const TextStyle(color: Colors.white54, fontSize: 14)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Divider(color: Colors.white.withValues(alpha: 0.1)),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Assigned Route', style: TextStyle(color: Colors.white54, fontSize: 12)),
                                      Text(driver['route'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      if (status == 'Pending') ...[
                                        _buildActionButton(Icons.check, Colors.green, 'Approve', () {}),
                                        const SizedBox(width: 8),
                                      ],
                                      if (status == 'Active') ...[
                                        _buildActionButton(Icons.block, Colors.red, 'Suspend', () {}),
                                        const SizedBox(width: 8),
                                      ],
                                      _buildActionButton(Icons.visibility, Colors.blue, 'Details', () {
                                        context.push('/admin/drivers/${driver['id']}');
                                      }),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ).animate().slideX(begin: 0.1).fadeIn(delay: Duration(milliseconds: 200 + (index * 100))),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}
