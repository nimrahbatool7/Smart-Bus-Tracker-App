import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../../../core/widgets/glass_card.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
                color: isLight ? Colors.white : null,
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Text('Current Balance', style: TextStyle(fontSize: 16, color: isLight ? Colors.grey.shade600 : Colors.white70)),
                      const SizedBox(height: 8),
                      Text('\$45.50', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40, color: isLight ? Colors.black87 : Colors.white)),
                      const SizedBox(height: 30),
                      AnimatedButton(
                        text: 'Top Up',
                        onPressed: () {
                          // Top up logic
                        },
                      ),
                    ],
                  ),
                ),
              ).animate().slideY(begin: -0.2).fadeIn(),
              
              const SizedBox(height: 40),
              
              Text(
                'Transaction History',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ).animate().fadeIn(),
              const SizedBox(height: 16),
              
              Expanded(
                child: ListView.builder(
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    final txs = [
                      {'desc': 'Top Up', 'amount': '+\$20.00', 'date': 'Today', 'isAdd': true},
                      {'desc': 'Daily Pass', 'amount': '-\$5.00', 'date': 'Yesterday', 'isAdd': false},
                      {'desc': 'Weekly Pass', 'amount': '-\$25.00', 'date': '12 May', 'isAdd': false},
                    ];
                    final tx = txs[index];
                    final isAdd = tx['isAdd'] as bool;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: GlassCard(
                        color: isLight ? Colors.white : null,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: (isAdd ? Colors.green : Colors.red).withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(isAdd ? Icons.add : Icons.remove, color: isAdd ? Colors.green : Colors.red),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tx['desc'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isLight ? Colors.black87 : Colors.white)),
                                  Text(tx['date'] as String, style: TextStyle(fontSize: 12, color: isLight ? Colors.grey.shade600 : Colors.white54)),
                                ],
                              ),
                            ),
                            Text(
                              tx['amount'] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isAdd ? Colors.green : (isLight ? Colors.black87 : Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ).animate().slideX(begin: 0.2).fadeIn(delay: Duration(milliseconds: 200 + (index * 100))),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
