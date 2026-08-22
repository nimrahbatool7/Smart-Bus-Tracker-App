import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../data/providers/driver_providers.dart';

// ── Validation result model ────────────────────────────────────────────────

class _ValidationResult {
  const _ValidationResult({
    required this.isValid,
    required this.reason,
    this.userName,
    this.passType,
    this.validUntil,
  });

  final bool    isValid;
  final String  reason;
  final String? userName;
  final String? passType;
  final String? validUntil;
}

// ── Screen ─────────────────────────────────────────────────────────────────

class QRScannerScreen extends ConsumerStatefulWidget {
  const QRScannerScreen({super.key});

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  final MobileScannerController _scannerCtrl = MobileScannerController();

  bool               _processing = false;
  _ValidationResult? _result;

  @override
  void dispose() {
    _scannerCtrl.dispose();
    super.dispose();
  }

  // ── Validate QR token via Supabase RPC ────────────────────────────────

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing || _result != null) return;

    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;

    setState(() => _processing = true);
    await _scannerCtrl.stop();

    try {
      // Get current trip id from active assignment
      final assignment =
          await ref.read(driverAssignmentProvider.future);
      final tripId = assignment?.tripId ?? '';

      final response = await Supabase.instance.client.rpc(
        'validate_ticket',
        params: {
          'p_qr_token': raw,
          'p_trip_id':  tripId,
        },
      ) as Map<String, dynamic>;

      setState(() {
        _result = _ValidationResult(
          isValid:    response['valid']      as bool,
          reason:     response['reason']     as String? ?? 'unknown',
          userName:   response['user_name']  as String?,
          passType:   response['pass_type']  as String?,
          validUntil: response['valid_until'] as String?,
        );
        _processing = false;
      });
    } catch (e) {
      setState(() {
        _result = _ValidationResult(
          isValid: false,
          reason:  e.toString(),
        );
        _processing = false;
      });
    }
  }

  void _reset() {
    setState(() => _result = null);
    _scannerCtrl.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Camera feed ──────────────────────────────────────────────
          if (_result == null)
            Positioned.fill(
              child: MobileScanner(
                controller: _scannerCtrl,
                onDetect: _onDetect,
              ),
            ),

          // ── Result overlay ───────────────────────────────────────────
          if (_result != null)
            Positioned.fill(
              child: Container(
                color: _result!.isValid
                    ? Colors.green.withOpacity(0.15)
                    : Colors.red.withOpacity(0.15),
              ),
            ),

          // ── UI overlay ───────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Close button
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    padding: const EdgeInsets.all(20),
                    icon: const Icon(Icons.close,
                        color: Colors.white, size: 30),
                    onPressed: () => context.pop(),
                  ),
                ),

                const Spacer(),

                if (_result == null) ...[
                  // ── Scan frame ───────────────────────────────────────
                  Center(
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppTheme.primaryColor, width: 2),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: _processing
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: AppTheme.primaryColor))
                          : Stack(
                              children: [
                                // Scanning line animation
                                Positioned(
                                  top: 0, left: 0, right: 0,
                                  child: Container(
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentColor,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.accentColor
                                              .withOpacity(0.6),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ).animate(
                                    onPlay: (c) =>
                                        c.repeat(reverse: true))
                                 .slideY(
                                    begin: 0,
                                    end: 80,
                                    duration: 1500.ms),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  GlassCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 16),
                    borderRadius: 30,
                    child: const Text(
                      'Align passenger QR code within frame',
                      style: TextStyle(fontSize: 15),
                    ),
                  ).animate().fadeIn(),
                ] else ...[
                  // ── Validation result ────────────────────────────────
                  GlassCard(
                    color: _result!.isValid
                        ? Colors.green.withOpacity(0.3)
                        : Colors.red.withOpacity(0.3),
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _result!.isValid
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: _result!.isValid
                              ? Colors.green
                              : Colors.red,
                          size: 80,
                        ).animate().scale(curve: Curves.elasticOut),

                        const SizedBox(height: 20),

                        Text(
                          _result!.isValid
                              ? 'Ticket Valid'
                              : 'Invalid Ticket',
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(fontSize: 26),
                        ),

                        if (_result!.isValid) ...[
                          const SizedBox(height: 12),
                          Text(
                            _result!.userName ?? '',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _result!.passType ?? '',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14),
                          ),
                          if (_result!.validUntil != null)
                            Text(
                              'Valid until ${_result!.validUntil}',
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 13),
                            ),
                        ] else ...[
                          const SizedBox(height: 12),
                          Text(
                            _friendlyReason(_result!.reason),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14),
                          ),
                        ],

                        const SizedBox(height: 24),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(30)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 14),
                          ),
                          onPressed: _reset,
                          child: const Text('Scan Next',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ),
                      ],
                    ),
                  ).animate().slideY(begin: 0.5).fadeIn(),
                ],

                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _friendlyReason(String reason) {
    switch (reason) {
      case 'invalid_or_expired':
        return 'This ticket is invalid or has expired.';
      case 'not_authenticated':
        return 'Scanner session error. Please re-login.';
      default:
        return reason;
    }
  }
}
