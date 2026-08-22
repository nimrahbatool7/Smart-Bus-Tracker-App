import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLogin = true;

  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl     = TextEditingController();
  final _formKey      = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isLogin) {
      await ref.read(passengerAuthProvider.notifier).signIn(
            email: _emailCtrl.text.trim(), password: _passwordCtrl.text);
    } else {
      await ref.read(passengerAuthProvider.notifier).signUp(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
            fullName: _nameCtrl.text.trim());
    }
    if (!mounted) return;
    final value = ref.read(passengerAuthProvider).value;
    if (value != null) context.go('/passenger_dashboard');
  }

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) { _showError('Enter your email first.'); return; }
    await ref.read(passengerAuthProvider.notifier).resetPassword(email);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent.')));
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.errorColor));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(passengerAuthProvider, (_, next) {
      next.whenOrNull(error: (e, _) => _showError(e.toString()));
    });
    final isLoading = ref.watch(passengerAuthProvider).isLoading;

    return Scaffold(
      body: Stack(
        children: [
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
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.account_circle,
                              size: 80, color: AppTheme.primaryColor)
                          .animate()
                          .scale(duration: 500.ms)
                          .fadeIn(),
                      const SizedBox(height: 24),
                      Text(_isLogin ? 'Welcome Back' : 'Create Account',
                          style: Theme.of(context).textTheme.displayLarge)
                          .animate()
                          .slideY(begin: 0.3, end: 0)
                          .fadeIn(),
                      const SizedBox(height: 40),
                      GlassCard(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (!_isLogin) ...[
                              CustomTextField(
                                hintText: 'Full Name',
                                prefixIcon: Icons.person_outline,
                                controller: _nameCtrl,
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Name is required'
                                    : null,
                              ).animate().slideX(begin: -0.2).fadeIn(),
                              const SizedBox(height: 16),
                            ],
                            CustomTextField(
                              hintText: 'Email',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              controller: _emailCtrl,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                if (!v.contains('@')) return 'Enter a valid email';
                                return null;
                              },
                            ).animate().slideX(begin: -0.2).fadeIn(delay: 100.ms),
                            const SizedBox(height: 16),
                            CustomTextField(
                              hintText: 'Password',
                              prefixIcon: Icons.lock_outline,
                              isPassword: true,
                              controller: _passwordCtrl,
                              validator: (v) => v == null || v.length < 6
                                  ? 'Minimum 6 characters'
                                  : null,
                            ).animate().slideX(begin: -0.2).fadeIn(delay: 200.ms),
                            if (_isLogin) ...[
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: isLoading ? null : _forgotPassword,
                                  child: const Text('Forgot Password?',
                                      style: TextStyle(
                                          color: AppTheme.primaryColor)),
                                ),
                              ),
                            ] else
                              const SizedBox(height: 32),
                            AnimatedButton(
                              text: _isLogin ? 'Login' : 'Sign Up',
                              isLoading: isLoading,
                              onPressed: isLoading ? () {} : _submit,
                            ).animate().scale(delay: 400.ms),
                          ],
                        ),
                      ).animate().fadeIn(duration: 800.ms),
                      const SizedBox(height: 30),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () => setState(() => _isLogin = !_isLogin),
                        child: RichText(
                          text: TextSpan(
                            text: _isLogin
                                ? "Don't have an account? "
                                : 'Already have an account? ',
                            style: const TextStyle(color: Colors.white70),
                            children: [
                              TextSpan(
                                text: _isLogin ? 'Register' : 'Login',
                                style: const TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold),
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
          ),
        ],
      ),
    );
  }
}
