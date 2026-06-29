import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../../../core/widgets/glass_card.dart';

class PassengerQrScannerScreen extends StatefulWidget {
  const PassengerQrScannerScreen({super.key});

  @override
  State<PassengerQrScannerScreen> createState() => _PassengerQrScannerScreenState();
}

class _PassengerQrScannerScreenState extends State<PassengerQrScannerScreen> {
  bool isScanning = true;

  @override
  void initState() {
    super.initState();
    // Mocking a scan delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          isScanning = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: Colors.black, // Scanner background usually dark
      body: Stack(
        children: [
          // Mock Camera View
          Positioned.fill(
            child: Container(
              color: Colors.black87,
              child: const Center(
                child: Text('Camera View (Mock)', style: TextStyle(color: Colors.white54)),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    const Expanded(
                      child: Text(
                        'Scan Ticket',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // balance
                  ],
                ),
                
                const Spacer(),
                
                // Scanner Frame
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.primaryColor, width: 2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: isScanning
                        ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                        : Center(
                            child: Icon(Icons.check_circle, color: Colors.green.shade400, size: 80)
                                .animate().scale().fadeIn(),
                          ),
                  ),
                ),
                
                const Spacer(),
                
                // Info Bottom Sheet
                GlassCard(
                  color: Colors.black.withValues(alpha: 0.8),
                  padding: const EdgeInsets.all(24),
                  borderRadius: 30,
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isScanning ? 'Align QR Code within frame' : 'Ticket Validated!',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        if (!isScanning)
                          AnimatedButton(
                            text: 'Done',
                            onPressed: () => context.pop(),
                          ),
                      ],
                    ),
                  ),
                ).animate().slideY(begin: 1.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
