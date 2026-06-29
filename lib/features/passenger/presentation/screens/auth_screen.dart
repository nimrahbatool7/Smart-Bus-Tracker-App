import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../../../core/widgets/custom_text_field.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background pattern/gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.backgroundDark, Color(0xFF131521)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Icon(
                      Icons.account_circle,
                      size: 80,
                      color: AppTheme.primaryColor,
                    ).animate().scale(duration: 500.ms).fadeIn(),
                    
                    const SizedBox(height: 24),
                    
                    Text(
                      _isLogin ? 'Welcome Back' : 'Create Account',
                      style: Theme.of(context).textTheme.displayLarge,
                    ).animate().slideY(begin: 0.3, end: 0).fadeIn(),
                    
                    const SizedBox(height: 40),
                    
                    GlassCard(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!_isLogin) ...[
                            const CustomTextField(
                              hintText: 'Full Name',
                              prefixIcon: Icons.person_outline,
                            ).animate().slideX(begin: -0.2).fadeIn(),
                            const SizedBox(height: 16),
                          ],
                          
                          const CustomTextField(
                            hintText: 'Email or Phone',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ).animate().slideX(begin: -0.2).fadeIn(delay: 100.ms),
                          
                          const SizedBox(height: 16),
                          
                          const CustomTextField(
                            hintText: 'Password',
                            prefixIcon: Icons.lock_outline,
                            isPassword: true,
                          ).animate().slideX(begin: -0.2).fadeIn(delay: 200.ms),
                          
                          if (_isLogin) ...[
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(color: AppTheme.primaryColor.withOpacity(0.8)),
                                ),
                              ),
                            ),
                          ] else
                            const SizedBox(height: 32),
                          
                          AnimatedButton(
                            text: _isLogin ? 'Login' : 'Sign Up',
                            onPressed: () {
                              // Simulate login and navigate to dashboard
                              context.go('/passenger_dashboard');
                            },
                          ).animate().scale(delay: 400.ms),
                        ],
                      ),
                    ).animate().fadeIn(duration: 800.ms),
                    
                    const SizedBox(height: 30),
                    
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: RichText(
                        text: TextSpan(
                          text: _isLogin ? "Don't have an account? " : "Already have an account? ",
                          style: const TextStyle(color: Colors.white70),
                          children: [
                            TextSpan(
                              text: _isLogin ? 'Register' : 'Login',
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms),
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
