import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/widgets/glass_card.dart';
import 'admin_layout.dart';

class AdminPaymentsScreen extends StatelessWidget {
  const AdminPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      selectedIndex: 6,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payments & Transactions', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), shape: BoxShape.circle),
                                child: const Icon(Icons.arrow_downward, color: Colors.green),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('TXN-${1000 + index}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  const Text('Monthly Pass Purchase', style: TextStyle(color: Colors.white54, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                          const Text('+\$80.00', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                    ).animate().slideX(begin: 0.1).fadeIn(delay: Duration(milliseconds: 100 * index)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
