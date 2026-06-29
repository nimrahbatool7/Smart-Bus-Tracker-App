import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../../../core/widgets/custom_text_field.dart';

class DriverAuthScreen extends StatefulWidget {
  const DriverAuthScreen({super.key});

  @override
  State<DriverAuthScreen> createState() => _DriverAuthScreenState();
}

class _DriverAuthScreenState extends State<DriverAuthScreen> {
  bool _isLogin = true;
  int _registrationStep = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/splash'),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Gradient (Darker, more industrial for driver)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0A0C10), Color(0xFF131521)],
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
                    // Driver Logo
                    Icon(
                      Icons.badge,
                      size: 80,
                      color: AppTheme.accentColor,
                    ).animate().scale(duration: 500.ms).fadeIn(),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      'Driver Portal',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppTheme.accentColor,
                      ),
                    ).animate().slideY(begin: 0.3, end: 0).fadeIn(),
                    
                    const SizedBox(height: 40),
                    
                    GlassCard(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_isLogin) ...[
                            _buildLoginForm(),
                          ] else ...[
                            _buildRegistrationForm(),
                          ],
                        ],
                      ),
                    ).animate().fadeIn(duration: 800.ms),
                    
                    const SizedBox(height: 30),
                    
                    if (_registrationStep == 1 || _isLogin)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                            _registrationStep = 1;
                          });
                        },
                        child: RichText(
                          text: TextSpan(
                            text: _isLogin ? "Apply to drive? " : "Already approved? ",
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

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CustomTextField(
          hintText: 'Driver ID or Phone',
          prefixIcon: Icons.person_pin,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          hintText: 'PIN / Password',
          prefixIcon: Icons.lock_outline,
          isPassword: true,
        ),
        const SizedBox(height: 32),
        AnimatedButton(
          text: 'Login & Start Shift',
          onPressed: () {
            context.go('/driver/dashboard');
          },
        ),
      ],
    );
  }

  Widget _buildRegistrationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Step $_registrationStep of 3', style: const TextStyle(color: AppTheme.primaryColor)),
            if (_registrationStep > 1)
               GestureDetector(
                 onTap: () => setState(() => _registrationStep--),
                 child: const Text('Back', style: TextStyle(color: Colors.white54)),
               )
          ],
        ),
        const SizedBox(height: 20),
        
        if (_registrationStep == 1) ...[
          const CustomTextField(hintText: 'Full Name', prefixIcon: Icons.person),
          const SizedBox(height: 16),
          const CustomTextField(hintText: 'Phone Number', prefixIcon: Icons.phone),
          const SizedBox(height: 16),
          const CustomTextField(hintText: 'License Number', prefixIcon: Icons.badge),
        ] else if (_registrationStep == 2) ...[
          const CustomTextField(hintText: 'Vehicle Model', prefixIcon: Icons.directions_bus),
          const SizedBox(height: 16),
          const CustomTextField(hintText: 'License Plate', prefixIcon: Icons.pin),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12, style: BorderStyle.solid),
            ),
            child: const Column(
              children: [
                Icon(Icons.upload_file, color: Colors.white54, size: 40),
                SizedBox(height: 8),
                Text('Upload Documents (Insurance, Reg)', style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ] else if (_registrationStep == 3) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 60),
                SizedBox(height: 16),
                Text(
                  'Application Ready',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Your application will be reviewed by admins. You will be notified once approved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          )
        ],

        const SizedBox(height: 32),
        AnimatedButton(
          text: _registrationStep == 3 ? 'Submit Application' : 'Next',
          onPressed: () {
            if (_registrationStep < 3) {
              setState(() => _registrationStep++);
            } else {
              setState(() => _isLogin = true); // Simulate submit and go to login
            }
          },
        ),
      ],
    );
  }
}
