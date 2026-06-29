import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/floating_navigation_bar.dart';

class AdminLayout extends StatelessWidget {
  final Widget child;
  final int selectedIndex;

  const AdminLayout({
    super.key,
    required this.child,
    this.selectedIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;

        if (isDesktop) {
          return _buildDesktopLayout(context);
        } else {
          return _buildMobileLayout(context);
        }
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('NEXUS Admin', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications, color: Colors.white54), onPressed: () {}),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryColor,
              child: Icon(Icons.admin_panel_settings, color: Colors.black, size: 18),
            ),
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F111A), Color(0xFF131521)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: child,
      ),
      bottomNavigationBar: FloatingNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          switch (index) {
            case 0: context.go('/admin/dashboard'); break;
            case 1: context.go('/admin/drivers'); break;
            case 2: context.go('/admin/vehicles'); break;
            case 3: context.go('/admin/routes'); break;
            case 4: context.go('/admin/fleet'); break;
            case 5: context.go('/admin/tickets'); break;
            case 6: context.go('/admin/payments'); break;
            case 7: context.go('/admin/analytics'); break;
            case 8: context.go('/admin/settings'); break;
            case 9: context.go('/admin/profile'); break;
          }
        },
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: const Color(0xFF131521),
              border: Border(right: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      const Icon(Icons.directions_bus, color: AppTheme.primaryColor, size: 30),
                      const SizedBox(width: 12),
                      Text(
                        'NEXUS',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSidebarItem(context, Icons.dashboard, 'Dashboard', 0, '/admin/dashboard'),
                _buildSidebarItem(context, Icons.people, 'Driver Management', 1, '/admin/drivers'),
                _buildSidebarItem(context, Icons.directions_bus, 'Vehicle Management', 2, '/admin/vehicles'),
                _buildSidebarItem(context, Icons.route, 'Route Management', 3, '/admin/routes'),
                _buildSidebarItem(context, Icons.map, 'Live Fleet', 4, '/admin/fleet'),
                _buildSidebarItem(context, Icons.confirmation_num, 'Ticket Management', 5, '/admin/tickets'),
                _buildSidebarItem(context, Icons.payment, 'Payments', 6, '/admin/payments'),
                _buildSidebarItem(context, Icons.analytics, 'Analytics', 7, '/admin/analytics'),
                _buildSidebarItem(context, Icons.settings, 'Settings', 8, '/admin/settings'),
                _buildSidebarItem(context, Icons.person, 'Profile', 9, '/admin/profile'),
                const Spacer(),
                _buildSidebarItem(context, Icons.logout, 'Logout', -1, '/splash'),
                const SizedBox(height: 20),
              ],
            ),
          ).animate().slideX(begin: -0.2).fadeIn(),

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top Appbar
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131521).withValues(alpha: 0.5),
                    border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Command Center',
                        style: TextStyle(fontSize: 20, color: Colors.white70),
                      ),
                      Row(
                        children: [
                          IconButton(icon: const Icon(Icons.notifications, color: Colors.white54), onPressed: () {}),
                          const SizedBox(width: 16),
                          const CircleAvatar(
                            backgroundColor: AppTheme.primaryColor,
                            child: Icon(Icons.admin_panel_settings, color: Colors.black),
                          ),
                          const SizedBox(width: 12),
                          const Text('Super Admin', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Dynamic Content
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0F111A), Color(0xFF131521)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(BuildContext context, IconData icon, String title, int index, String route) {
    final isSelected = selectedIndex == index;
    return InkWell(
      onTap: () {
        if (route.isNotEmpty) context.go(route);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.transparent,
          border: isSelected ? const Border(right: BorderSide(color: AppTheme.primaryColor, width: 3)) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppTheme.primaryColor : Colors.white54),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
