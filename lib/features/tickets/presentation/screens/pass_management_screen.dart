import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../data/providers/ticket_providers.dart';

class PassManagementScreen extends ConsumerWidget {
  const PassManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLight      = Theme.of(context).brightness == Brightness.light;
    final passesAsync  = ref.watch(activePassesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Passes'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(activePassesProvider),
          ),
        ],
      ),
      body: SafeArea(
        child: passesAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(
                  color: AppTheme.primaryColor)),
          error: (e, _) => Center(
            child: Text('Error: $e',
                style: const TextStyle(color: AppTheme.errorColor)),
          ),
          data: (passes) {
            if (passes.isEmpty) {
              return _buildEmpty(context, isLight);
            }
            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: passes.length,
              itemBuilder: (ctx, i) =>
                  _buildPassCard(ctx, passes[i], isLight, ref),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, bool isLight) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_membership,
                size: 80,
                color: isLight ? Colors.grey.shade300 : Colors.white24),
            const SizedBox(height: 24),
            Text('No active passes',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isLight ? Colors.black87 : Colors.white)),
            const SizedBox(height: 12),
            Text('Buy a pass to start riding',
                style: TextStyle(
                    color:
                        isLight ? Colors.grey.shade600 : Colors.white60)),
            const SizedBox(height: 32),
            AnimatedButton(
              text: 'Buy a Pass',
              onPressed: () => context.push(AppRoutes.buyTicket),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassCard(BuildContext context, PassModel pass,
      bool isLight, WidgetRef ref) {
    final daysLeft =
        pass.validUntil.difference(DateTime.now()).inDays;
    final isExpiringSoon = daysLeft <= 5 && daysLeft >= 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GlassCard(
        color: isLight ? Colors.white : null,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title row ───────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(pass.typeName,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: isLight ? Colors.black87 : Colors.white)),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Active',
                      style: TextStyle(
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text(pass.routeName,
                style: TextStyle(
                    fontSize: 15,
                    color:
                        isLight ? Colors.grey.shade700 : Colors.white70)),

            const SizedBox(height: 20),

            // ── QR code ──────────────────────────────────────────────
            Center(
              child: GlassCard(
                color: Colors.white,
                padding: const EdgeInsets.all(12),
                borderRadius: 16,
                child: QrImageView(
                  data: pass.qrToken,
                  version: QrVersions.auto,
                  size: 180,
                  backgroundColor: Colors.white,
                ),
              ).animate().scale(duration: 400.ms),
            ),

            const SizedBox(height: 20),

            // ── Validity ─────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Valid until',
                        style: TextStyle(
                            fontSize: 12,
                            color: isLight
                                ? Colors.grey.shade600
                                : Colors.white60)),
                    Text(
                      DateFormat('d MMM yyyy').format(pass.validUntil),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isExpiringSoon
                              ? Colors.orange
                              : (isLight ? Colors.black87 : Colors.white)),
                    ),
                  ],
                ),
                if (isExpiringSoon)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Expires in $daysLeft day${daysLeft == 1 ? '' : 's'}',
                      style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Renew button ──────────────────────────────────────────
            AnimatedButton(
              text: 'Renew Pass',
              onPressed: () => context.push(AppRoutes.buyTicket),
            ),
          ],
        ),
      ).animate().slideY(begin: 0.1).fadeIn(),
    );
  }
}
