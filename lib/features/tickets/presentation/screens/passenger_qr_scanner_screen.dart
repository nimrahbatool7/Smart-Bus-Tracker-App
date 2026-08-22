import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../data/providers/ticket_providers.dart';

/// Shows the passenger's active pass QR code so the driver can scan it.
/// This is NOT a camera scanner — the passenger presents their QR.
/// (The camera scanner for drivers lives in driver/presentation/screens/qr_scanner_screen.dart)
class PassengerQrScannerScreen extends ConsumerWidget {
  const PassengerQrScannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLight     = Theme.of(context).brightness == Brightness.light;
    final passesAsync = ref.watch(activePassesProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'My Ticket QR',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            const Spacer(),

            // ── QR code area ──────────────────────────────────────────
            passesAsync.when(
              loading: () => const CircularProgressIndicator(
                  color: AppTheme.primaryColor),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Error: $e',
                    style: const TextStyle(
                        color: AppTheme.errorColor),
                    textAlign: TextAlign.center),
              ),
              data: (passes) {
                if (passes.isEmpty) {
                  return _buildNoPass(context, isLight);
                }
                // Show the first active pass QR
                final pass = passes.first;
                return _buildQrCard(pass, isLight);
              },
            ),

            const Spacer(),

            // ── Bottom hint ───────────────────────────────────────────
            passesAsync.maybeWhen(
              data: (passes) => passes.isEmpty
                  ? const SizedBox()
                  : GlassCard(
                      color: Colors.black.withValues(alpha: 0.8),
                      padding: const EdgeInsets.all(24),
                      borderRadius: 30,
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Show this QR code to the driver',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              passes.first.typeName,
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ).animate().slideY(begin: 1.0),
              orElse: () => const SizedBox(),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildQrCard(PassModel pass, bool isLight) {
    return Center(
      child: GlassCard(
        color: Colors.white,
        padding: const EdgeInsets.all(24),
        borderRadius: 24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data:            pass.qrToken,
              version:         QrVersions.auto,
              size:            220,
              backgroundColor: Colors.white,
            ).animate().scale(duration: 400.ms),
            const SizedBox(height: 16),
            Text(
              pass.typeName,
              style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              pass.routeName,
              style: TextStyle(
                  color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoPass(BuildContext context, bool isLight) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.qr_code_2, size: 80, color: Colors.white24),
          const SizedBox(height: 24),
          const Text(
            'No Active Pass',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Purchase a pass to generate your boarding QR code.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 32),
          AnimatedButton(
            text: 'Buy a Pass',
            onPressed: () {
              context.pop();
              context.push('/buy-ticket');
            },
          ),
        ],
      ),
    );
  }
}
