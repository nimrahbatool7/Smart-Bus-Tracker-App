import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

/// Shared layout shell for all admin screens.
/// On desktop (> 800 px) renders a full sidebar.
/// On mobile renders an AppBar + scrollable BottomNavigationBar substitute
/// (a horizontal icon row inside a frosted container).
class AdminLayout extends StatelessWidget {
  const AdminLayout({
    super.key,
    required this.child,
    this.selectedIndex = 0,
  });

  final Widget child;
  final int    selectedIndex;

  // ── Route map ────────────────────────────────────────────────────────────

  static const _routes = [
    '/admin/dashboard',
    '/admin/drivers',
    '/admin/vehicles',
    '/admin/routes',
    '/admin/fleet',
    '/admin/tickets',
    '/admin/payments',
    '/admin/analytics',
    '/admin/settings',
    '/admin/profile',
  ];

  static const _icons = [
    Icons.dashboard,
    Icons.people,
    Icons.directions_bus,
    Icons.route,
    Icons.map,
    Icons.confirmation_num,
    Icons.payment,
    Icons.analytics,
    Icons.settings,
    Icons.person,
  ];

  static const _labels = [
    'Dashboard',
    'Drivers',
    'Vehicles',
    'Routes',
    'Fleet',
    'Tickets',
    'Payments',
    'Analytics',
    'Settings',
    'Profile',
  ];

  void _navigate(BuildContext context, int index) {
    if (index >= 0 && index < _routes.length) {
      context.go(_routes[index]);
    } else {
      context.go('/splash'); // logout
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return constraints.maxWidth > 800
            ? _buildDesktop(context)
            : _buildMobile(context);
      },
    );
  }

  // ── Mobile layout ─────────────────────────────────────────────────────────

  Widget _buildMobile(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('NEXUS Admin',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
              icon: const Icon(Icons.notifications,
                  color: Colors.white54),
              onPressed: () {}),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryColor,
              child: Icon(Icons.admin_panel_settings,
                  color: Colors.black, size: 18),
            ),
          ),
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
      // Scrollable bottom nav — handles 10 items
      bottomNavigationBar: _MobileAdminNav(
        selectedIndex: selectedIndex,
        onTap: (i) => _navigate(context, i),
      ),
    );
  }

  // ── Desktop layout ────────────────────────────────────────────────────────

  Widget _buildDesktop(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: const Color(0xFF131521),
              border: Border(
                  right: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      const Icon(Icons.directions_bus,
                          color: AppTheme.primaryColor, size: 30),
                      const SizedBox(width: 12),
                      Text(
                        'NEXUS',
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge
                            ?.copyWith(fontSize: 24),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(_labels.length, (i) {
                  return _SidebarItem(
                    icon:      _icons[i],
                    label:     _labels[i],
                    isSelected: selectedIndex == i,
                    onTap:     () => _navigate(context, i),
                  );
                }),
                const Spacer(),
                _SidebarItem(
                  icon:      Icons.logout,
                  label:     'Logout',
                  isSelected: false,
                  onTap:     () => context.go('/splash'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ).animate().slideX(begin: -0.2).fadeIn(),

          // Main content
          Expanded(
            child: Column(
              children: [
                // Top bar
                Container(
                  height: 70,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131521)
                        .withValues(alpha: 0.5),
                    border: Border(
                        bottom: BorderSide(
                            color: Colors.white
                                .withValues(alpha: 0.1))),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _labels[selectedIndex.clamp(
                            0, _labels.length - 1)],
                        style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white70),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications,
                                color: Colors.white54),
                            onPressed: () {},
                          ),
                          const SizedBox(width: 16),
                          const CircleAvatar(
                            backgroundColor:
                                AppTheme.primaryColor,
                            child: Icon(
                                Icons.admin_panel_settings,
                                color: Colors.black),
                          ),
                          const SizedBox(width: 12),
                          const Text('Super Admin',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF0F111A),
                          Color(0xFF131521)
                        ],
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
}

// ── Sidebar item ─────────────────────────────────────────────────────────────

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String   label;
  final bool     isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          border: isSelected
              ? const Border(
                  right: BorderSide(
                      color: AppTheme.primaryColor, width: 3))
              : null,
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected
                    ? AppTheme.primaryColor
                    : Colors.white54),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Mobile scrollable nav ─────────────────────────────────────────────────────

class _MobileAdminNav extends StatelessWidget {
  const _MobileAdminNav({
    required this.selectedIndex,
    required this.onTap,
  });

  final int           selectedIndex;
  final Function(int) onTap;

  static const _icons = AdminLayout._icons;
  static const _labels = AdminLayout._labels;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: const Color(0xFF131521),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_labels.length, (i) {
            final selected = selectedIndex == i;
            return GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected
                          ? AppTheme.primaryColor
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _icons[i],
                      color: selected
                          ? AppTheme.primaryColor
                          : Colors.white38,
                      size: 22,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _labels[i],
                      style: TextStyle(
                        fontSize: 10,
                        color: selected
                            ? AppTheme.primaryColor
                            : Colors.white38,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
