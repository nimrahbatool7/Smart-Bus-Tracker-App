import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/animated_button.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showRoles = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showRoles = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.backgroundDark, Color(0xFF1A1D2B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.directions_bus,
                  size: 100,
                  color: AppTheme.primaryColor,
                ).animate()
                  .fadeIn(duration: 800.ms)
                  .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0), curve: Curves.easeOutBack)
                  .shimmer(delay: 1000.ms, duration: 1500.ms),
                
                const SizedBox(height: 24),
                
                Text(
                  'NEXUS TRANSIT',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    letterSpacing: 4,
                    color: Colors.white,
                  ),
                ).animate()
                  .fadeIn(delay: 500.ms, duration: 800.ms)
                  .slideY(begin: 0.2, end: 0),
                  
                const SizedBox(height: 60),
                
                if (!_showRoles)
                  const CircularProgressIndicator(
                    color: AppTheme.accentColor,
                  ).animate().fadeIn()
                else
                  Column(
                    children: [
                      Text(
                        'Select Your Role',
                        style: Theme.of(context).textTheme.titleLarge,
                      ).animate().fadeIn().slideY(begin: 0.5),
                      const SizedBox(height: 24),
                      AnimatedButton(
                        text: 'I am a Passenger',
                        icon: Icons.person,
                        onPressed: () => context.go('/onboarding'),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.5),
                      const SizedBox(height: 16),
                      AnimatedButton(
                        text: 'I am a Driver',
                        icon: Icons.drive_eta,
                        onPressed: () => context.go('/driver/login'),
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.5),
                      const SizedBox(height: 16),
                      AnimatedButton(
                        text: 'I am an Admin (Web)',
                        icon: Icons.admin_panel_settings,
                        onPressed: () => context.go('/admin/login'),
                      ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.5),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

