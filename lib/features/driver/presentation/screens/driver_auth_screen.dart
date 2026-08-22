import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class DriverAuthScreen extends ConsumerStatefulWidget {
  const DriverAuthScreen({super.key});

  @override
  ConsumerState<DriverAuthScreen> createState() => _DriverAuthScreenState();
}

class _DriverAuthScreenState extends ConsumerState<DriverAuthScreen> {
  bool _isLogin = true;
  int  _step    = 1;

  final _loginEmailCtrl    = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();
  final _loginFormKey      = GlobalKey<FormState>();

  final _regNameCtrl     = TextEditingController();
  final _regEmailCtrl    = TextEditingController();
  final _regPasswordCtrl = TextEditingController();
  final _regPhoneCtrl    = TextEditingController();
  final _regLicenseCtrl  = TextEditingController();
  final _regVehicleCtrl  = TextEditingController();
  final _regPlateCtrl    = TextEditingController();
  final _regStep1Key     = GlobalKey<FormState>();
  final _regStep2Key     = GlobalKey<FormState>();

  @override
  void dispose() {
    _loginEmailCtrl.dispose(); _loginPasswordCtrl.dispose();
    _regNameCtrl.dispose();    _regEmailCtrl.dispose();
    _regPasswordCtrl.dispose(); _regPhoneCtrl.dispose();
    _regLicenseCtrl.dispose(); _regVehicleCtrl.dispose();
    _regPlateCtrl.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.errorColor));
  }

  Future<void> _submitLogin() async {
    if (!(_loginFormKey.currentState?.validate() ?? false)) return;
    await ref.read(driverAuthProvider.notifier).signIn(
          email: _loginEmailCtrl.text.trim(),
          password: _loginPasswordCtrl.text);
    if (!mounted) return;
    final value = ref.read(driverAuthProvider).value;
    if (value != null) context.go('/driver/dashboard');
  }

  Future<void> _advanceStep() async {
    if (_step == 1) {
      if (!(_regStep1Key.currentState?.validate() ?? false)) return;
      setState(() => _step = 2);
    } else if (_step == 2) {
      if (!(_regStep2Key.currentState?.validate() ?? false)) return;
      setState(() => _step = 3);
    } else {
      await ref.read(driverAuthProvider.notifier).signUp(
            email:         _regEmailCtrl.text.trim(),
            password:      _regPasswordCtrl.text,
            fullName:      _regNameCtrl.text.trim(),
            licenseNumber: _regLicenseCtrl.text.trim(),
            vehicleModel:  _regVehicleCtrl.text.trim(),
            plateNumber:   _regPlateCtrl.text.trim());
      if (!mounted) return;
      final value = ref.read(driverAuthProvider).value;
      if (value != null) {
        setState(() { _isLogin = true; _step = 1; });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Application submitted! Awaiting admin approval.'),
          backgroundColor: Colors.green));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(driverAuthProvider, (_, next) {
      next.whenOrNull(error: (e, _) => _showError(e.toString()));
    });
    final isLoading = ref.watch(driverAuthProvider).isLoading;

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
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Icon(Icons.badge, size: 80, color: AppTheme.accentColor)
                        .animate().scale(duration: 500.ms).fadeIn(),
                    const SizedBox(height: 16),
                    Text('Driver Portal',
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge
                            ?.copyWith(color: AppTheme.accentColor))
                        .animate().slideY(begin: 0.3).fadeIn(),
                    const SizedBox(height: 40),
                    GlassCard(
                      padding: const EdgeInsets.all(30),
                      child: _isLogin
                          ? _buildLoginForm(isLoading)
                          : _buildRegForm(isLoading),
                    ).animate().fadeIn(duration: 800.ms),
                    const SizedBox(height: 30),
                    if (_step == 1 || _isLogin)
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () => setState(() {
                                  _isLogin = !_isLogin;
                                  _step    = 1;
                                }),
                        child: RichText(
                          text: TextSpan(
                            text: _isLogin ? 'Apply to drive? ' : 'Already approved? ',
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
        ],
      ),
    );
  }

  Widget _buildLoginForm(bool isLoading) {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            hintText: 'Email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            controller: _loginEmailCtrl,
            validator: (v) => v == null || !v.contains('@')
                ? 'Enter a valid email' : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            hintText: 'Password',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            controller: _loginPasswordCtrl,
            validator: (v) => v == null || v.length < 6
                ? 'Minimum 6 characters' : null,
          ),
          const SizedBox(height: 32),
          AnimatedButton(
            text: 'Login & Start Shift',
            isLoading: isLoading,
            onPressed: isLoading ? () {} : _submitLogin,
          ),
        ],
      ),
    );
  }

  Widget _buildRegForm(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Step $_step of 3',
                style: const TextStyle(color: AppTheme.primaryColor)),
            if (_step > 1)
              GestureDetector(
                onTap: () => setState(() => _step--),
                child: const Text('Back',
                    style: TextStyle(color: Colors.white54)),
              ),
          ],
        ),
        const SizedBox(height: 20),
        if (_step == 1) _buildStep1(),
        if (_step == 2) _buildStep2(),
        if (_step == 3) _buildStep3(),
        const SizedBox(height: 32),
        AnimatedButton(
          text: _step == 3 ? 'Submit Application' : 'Next',
          isLoading: isLoading,
          onPressed: isLoading ? () {} : _advanceStep,
        ),
      ],
    );
  }

  Widget _buildStep1() => Form(
        key: _regStep1Key,
        child: Column(children: [
          CustomTextField(hintText: 'Full Name', prefixIcon: Icons.person,
              controller: _regNameCtrl,
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
          const SizedBox(height: 12),
          CustomTextField(hintText: 'Email', prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              controller: _regEmailCtrl,
              validator: (v) => v == null || !v.contains('@') ? 'Invalid email' : null),
          const SizedBox(height: 12),
          CustomTextField(hintText: 'Password (min 6)', prefixIcon: Icons.lock_outline,
              isPassword: true, controller: _regPasswordCtrl,
              validator: (v) => v == null || v.length < 6 ? 'Min 6 chars' : null),
          const SizedBox(height: 12),
          CustomTextField(hintText: 'Phone', prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone, controller: _regPhoneCtrl),
          const SizedBox(height: 12),
          CustomTextField(hintText: 'License Number', prefixIcon: Icons.badge,
              controller: _regLicenseCtrl,
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
        ]),
      );

  Widget _buildStep2() => Form(
        key: _regStep2Key,
        child: Column(children: [
          CustomTextField(hintText: 'Vehicle Model', prefixIcon: Icons.directions_bus,
              controller: _regVehicleCtrl,
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
          const SizedBox(height: 12),
          CustomTextField(hintText: 'License Plate', prefixIcon: Icons.pin,
              controller: _regPlateCtrl,
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: const Column(children: [
              Icon(Icons.upload_file, color: Colors.white54, size: 40),
              SizedBox(height: 8),
              Text('Document upload (Insurance, Registration)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
            ]),
          ),
        ]),
      );

  Widget _buildStep3() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(children: [
          const Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 60),
          const SizedBox(height: 16),
          const Text('Ready to Submit',
              style: TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Name: ${_regNameCtrl.text}\nEmail: ${_regEmailCtrl.text}\n'
            'License: ${_regLicenseCtrl.text}\nVehicle: ${_regVehicleCtrl.text}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 12),
          const Text('Your application will be reviewed by an admin.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 12)),
        ]),
      );
}
