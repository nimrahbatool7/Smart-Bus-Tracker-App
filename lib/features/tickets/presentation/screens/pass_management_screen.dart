import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../../../core/widgets/glass_card.dart';

class PassManagementScreen extends StatelessWidget {
  const PassManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Passes'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Pass',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ).animate().fadeIn(),
              const SizedBox(height: 16),
              
              GlassCard(
                color: isLight ? Colors.white : null,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Monthly Pass', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: isLight ? Colors.black87 : Colors.white)),
                        Icon(Icons.check_circle, color: Colors.green.shade600),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('All Routes Access', style: TextStyle(fontSize: 16, color: isLight ? Colors.grey.shade700 : Colors.white70)),
                    const SizedBox(height: 24),
                    Text('Expiry Date', style: TextStyle(fontSize: 12, color: isLight ? Colors.grey.shade600 : Colors.white60)),
                    Text('30 May 2024', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isLight ? Colors.red.shade400 : Colors.redAccent)),
                    const SizedBox(height: 30),
                    AnimatedButton(
                      text: 'Renew Pass',
                      onPressed: () {
                        context.pop();
                      },
                    ),
                  ],
                ),
              ).animate().slideY(begin: 0.2).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }
}
