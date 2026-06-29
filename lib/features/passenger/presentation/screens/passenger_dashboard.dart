import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/floating_navigation_bar.dart';
import 'home_tab.dart';
import 'track_tab.dart';
import 'tickets_tab.dart';
import 'profile_tab.dart';

class PassengerDashboard extends StatefulWidget {
  const PassengerDashboard({super.key});

  @override
  State<PassengerDashboard> createState() => _PassengerDashboardState();
}

class _PassengerDashboardState extends State<PassengerDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const TrackTab(),
    const TicketsTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    
    return Scaffold(
      extendBody: true, // Needed to let background show behind nav bar
      body: Container(
        decoration: BoxDecoration(
          color: isLight ? AppTheme.backgroundLight : null,
          gradient: isLight ? null : const LinearGradient(
            colors: [AppTheme.backgroundDark, Color(0xFF131521)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: FloatingNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
