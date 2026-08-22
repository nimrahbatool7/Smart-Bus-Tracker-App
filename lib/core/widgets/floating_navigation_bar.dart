import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A nav item descriptor for [FloatingNavigationBar].
class NavItem {
  const NavItem({
    required this.outlineIcon,
    required this.filledIcon,
    this.label,
  });

  final IconData outlineIcon;
  final IconData filledIcon;
  final String?  label;
}

/// Frosted-glass floating navigation bar.
/// Defaults to the 4-item passenger nav when [items] is omitted.
class FloatingNavigationBar extends StatelessWidget {
  const FloatingNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items,
  });

  final int          currentIndex;
  final Function(int) onTap;
  final List<NavItem>? items;

  static const _passengerItems = [
    NavItem(outlineIcon: Icons.home_outlined,             filledIcon: Icons.home,             label: 'Home'),
    NavItem(outlineIcon: Icons.map_outlined,              filledIcon: Icons.map,              label: 'Track'),
    NavItem(outlineIcon: Icons.confirmation_num_outlined, filledIcon: Icons.confirmation_num, label: 'Tickets'),
    NavItem(outlineIcon: Icons.person_outline,            filledIcon: Icons.person,           label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final isLight  = Theme.of(context).brightness == Brightness.light;
    final navItems = items ?? _passengerItems;

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
      height: 70,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: isLight
                  ? Colors.white.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(
                color: isLight
                    ? Colors.white.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.1),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: navItems.asMap().entries.map((entry) {
                return _buildItem(context, entry.key, entry.value, isLight);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index, NavItem item, bool isLight) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                isSelected ? item.filledIcon : item.outlineIcon,
                key: ValueKey(isSelected),
                color: isSelected
                    ? AppTheme.primaryColor
                    : (isLight ? Colors.grey : Colors.white54),
                size: 24,
              ),
            ),
            if (item.label != null) ...[
              const SizedBox(height: 2),
              Text(
                item.label!,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : (isLight ? Colors.grey : Colors.white54),
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
