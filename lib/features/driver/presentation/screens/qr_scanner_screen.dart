import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isScanning = true;
  bool _isValid = false;

  void _simulateScan() {
    setState(() {
      _isScanning = false;
      _isValid = true; // For demo purposes, we accept it
    });
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.pop(); // Go back to driving mode
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Simulated Camera View
          Positioned.fill(
            child: Container(
              color: Colors.grey.shade900,
              child: const Center(child: Text('Camera Feed Placeholder', style: TextStyle(color: Colors.white54))),
            ),
          ),
          
          // Scanner Overlay
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    padding: const EdgeInsets.all(20),
                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => context.pop(),
                  ),
                ),
                const Spacer(),
                
                if (_isScanning) ...[
                  GestureDetector(
                    onTap: _simulateScan, // Tap to simulate a successful scan
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.primaryColor, width: 2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppTheme.accentColor,
                                boxShadow: [
                                  BoxShadow(color: AppTheme.accentColor.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)
                                ],
                              ),
                            ),
                          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                           .slideY(begin: 0, end: 60, duration: 1500.ms),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                    borderRadius: 30,
                    child: const Text('Align QR code within frame', style: TextStyle(fontSize: 16)),
                  ).animate().fadeIn(),
                ] else ...[
                  // Result Overlay
                  GlassCard(
                    color: _isValid ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          _isValid ? Icons.check_circle : Icons.cancel,
                          color: _isValid ? Colors.green : Colors.red,
                          size: 80,
                        ).animate().scale(curve: Curves.elasticOut),
                        const SizedBox(height: 20),
                        Text(
                          _isValid ? 'Ticket Valid' : 'Invalid Ticket',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
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
}
