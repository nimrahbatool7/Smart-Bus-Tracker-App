import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../data/providers/ticket_providers.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  // ── Top-up helper ─────────────────────────────────────────────────────────

  void _showTopUpDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            Theme.of(context).brightness == Brightness.dark
                ? AppTheme.backgroundDark
                : Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Top Up Wallet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [10.0, 20.0, 50.0, 100.0]
              .map((amount) => ListTile(
                    leading: const Icon(Icons.attach_money,
                        color: AppTheme.primaryColor),
                    title: Text(
                        '\$${amount.toStringAsFixed(0)}'),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _doTopUp(context, ref, amount);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  Future<void> _doTopUp(
      BuildContext context, WidgetRef ref, double amount) async {
    try {
      await Supabase.instance.client
          .rpc('top_up_wallet', params: {'p_amount': amount});
      ref.invalidate(walletProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '\$${amount.toStringAsFixed(0)} added to your wallet'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Top-up failed: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLight     = Theme.of(context).brightness == Brightness.light;
    final walletAsync = ref.watch(walletProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: walletAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(
                color: AppTheme.primaryColor)),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Error: $e',
              style: const TextStyle(color: AppTheme.errorColor),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (wallet) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Balance card ───────────────────────────────────────
                GlassCard(
                  color: isLight ? Colors.white : null,
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          'Current Balance',
                          style: TextStyle(
                            fontSize: 16,
                            color: isLight
                                ? Colors.grey.shade600
                                : Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${wallet.balance.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 40,
                            color:
                                isLight ? Colors.black87 : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 30),
                        AnimatedButton(
                          text: 'Top Up',
                          onPressed: () =>
                              _showTopUpDialog(context, ref),
                        ),
                      ],
                    ),
                  ),
                ).animate().slideY(begin: -0.2).fadeIn(),

                const SizedBox(height: 40),

                Text(
                  'Transaction History',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ).animate().fadeIn(),

                const SizedBox(height: 16),

                Expanded(
                  child: wallet.transactions.isEmpty
                      ? Center(
                          child: Text(
                            'No transactions yet.',
                            style: TextStyle(
                              color: isLight
                                  ? Colors.grey.shade500
                                  : Colors.white54,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: wallet.transactions.length,
                          itemBuilder: (context, i) {
                            final tx = wallet.transactions[i];
                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 16),
                              child: GlassCard(
                                color: isLight ? Colors.white : null,
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding:
                                          const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: (tx.isCredit
                                                ? Colors.green
                                                : Colors.red)
                                            .withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        tx.isCredit
                                            ? Icons.add
                                            : Icons.remove,
                                        color: tx.isCredit
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tx.description,
                                            style: TextStyle(
                                              fontWeight:
                                                  FontWeight.bold,
                                              fontSize: 16,
                                              color: isLight
                                                  ? Colors.black87
                                                  : Colors.white,
                                            ),
                                          ),
                                          Text(
                                            _formatDate(tx.createdAt),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isLight
                                                  ? Colors.grey.shade600
                                                  : Colors.white54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${tx.isCredit ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: tx.isCredit
                                            ? Colors.green
                                            : (isLight
                                                ? Colors.black87
                                                : Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate().slideX(begin: 0.2).fadeIn(
                                  delay: Duration(
                                      milliseconds: 200 + (i * 100))),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now  = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${dt.day} ${_month(dt.month)} ${dt.year}';
  }

  String _month(int m) => const [
        '',    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ][m];
}
