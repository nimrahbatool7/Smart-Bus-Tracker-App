import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey      = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.errorColor));
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(adminAuthProvider.notifier).signIn(
          email: _emailCtrl.text.trim(), password: _passwordCtrl.text);
    if (!mounted) return;
    final value = ref.read(adminAuthProvider).value;
    if (value != null) context.go('/admin/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(adminAuthProvider, (_, next) {
      next.whenOrNull(error: (e, _) => _showError(e.toString()));
    });
    final isLoading = ref.watch(adminAuthProvider).isLoading;
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
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.admin_panel_settings,
                              size: 80, color: AppTheme.primaryColor)
                          .animate()
                          .scale()
                          .fadeIn(),
                      const SizedBox(height: 16),
                      Text('Admin Portal',
                          style: Theme.of(context).textTheme.displayLarge)
                          .animate()
                          .slideY()
                          .fadeIn(),
                      const SizedBox(height: 40),
                      GlassCard(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CustomTextField(
                              hintText: 'Admin Email',
                              prefixIcon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                              controller: _emailCtrl,
                              validator: (v) =>
                                  v == null || !v.contains('@')
                                      ? 'Enter a valid email'
                                      : null,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              hintText: 'Password',
                              prefixIcon: Icons.lock,
                              isPassword: true,
                              controller: _passwordCtrl,
                              validator: (v) =>
                                  v == null || v.length < 6
                                      ? 'Minimum 6 characters'
                                      : null,
                            ),
                            const SizedBox(height: 32),
                            AnimatedButton(
                              text: 'Login to Command Center',
                              isLoading: isLoading,
                              onPressed: isLoading ? () {} : _submit,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 800.ms),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () => context.go('/splash'),
                        child: const Text('Return to Home',
                            style: TextStyle(color: Colors.white54)),
                      ).animate().fadeIn(delay: 500.ms),
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
