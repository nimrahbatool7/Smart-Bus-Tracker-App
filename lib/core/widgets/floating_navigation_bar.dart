import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_theme.dart';

class FloatingNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FloatingNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(35),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: isLight ? Colors.white.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(
                color: isLight ? Colors.white.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_outlined, Icons.home, 'Home', 0, context),
                _buildNavItem(Icons.map_outlined, Icons.map, 'Track', 1, context),
                _buildNavItem(Icons.confirmation_num_outlined, Icons.confirmation_num, 'Tickets', 2, context),
                _buildNavItem(Icons.person_outline, Icons.person, 'Profile', 3, context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData outlineIcon, IconData filledIcon, String label, int index, BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
              child: Icon(
                isSelected ? filledIcon : outlineIcon,
                key: ValueKey(isSelected),
                color: isSelected ? AppTheme.primaryColor : (isLight ? Colors.grey : Colors.white54),
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
