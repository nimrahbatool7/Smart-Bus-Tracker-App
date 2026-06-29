import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../../../core/widgets/custom_text_field.dart';

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine if it's a wide screen for web layout
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.5,
                  colors: [Color(0xFF131521), Color(0xFF0A0C10)],
                ),
              ),
            ),
          ),
          
          Center(
            child: SizedBox(
              width: isDesktop ? 450 : double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: 80,
                      color: AppTheme.primaryColor,
                    ).animate().scale().fadeIn(),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      'Admin Portal',
                      style: Theme.of(context).textTheme.displayLarge,
                    ).animate().slideY().fadeIn(),
                    
                    const SizedBox(height: 40),
                    
                    GlassCard(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const CustomTextField(
                            hintText: 'Admin Email',
                            prefixIcon: Icons.email,
                          ),
                          const SizedBox(height: 16),
                          const CustomTextField(
                            hintText: 'Password',
                            prefixIcon: Icons.lock,
                            isPassword: true,
                          ),
                          const SizedBox(height: 32),
                          AnimatedButton(
                            text: 'Login to Command Center',
                            onPressed: () {
                              context.go('/admin/dashboard');
                            },
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 800.ms),
                    
                    const SizedBox(height: 24),
                    
                    TextButton(
                      onPressed: () => context.go('/splash'),
                      child: const Text('Return to Home', style: TextStyle(color: Colors.white54)),
                    ).animate().fadeIn(delay: 500.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
