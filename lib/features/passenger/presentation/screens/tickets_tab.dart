import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../tickets/data/providers/ticket_providers.dart';

class TicketsTab extends ConsumerStatefulWidget {
  const TicketsTab({super.key});

  @override
  ConsumerState<TicketsTab> createState() => _TicketsTabState();
}

class _TicketsTabState extends ConsumerState<TicketsTab> {
  bool _showActive = true;

  @override
  Widget build(BuildContext context) {
    final isLight     = Theme.of(context).brightness == Brightness.light;
    final headerColor = isLight
        ? AppTheme.lightBlueHeader
        : Colors.blue.shade900.withValues(alpha: 0.8);

    final activeAsync  = ref.watch(activePassesProvider);
    final historyAsync = ref.watch(passHistoryProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Blue header
          Positioned(
            top: 0, left: 0, right: 0,
            height: 280,
            child: Container(
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft:  Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // ── Header ────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 24),
                            const Text(
                              'My Tickets',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh,
                                  color: Colors.white70),
                              onPressed: () {
                                ref.invalidate(activePassesProvider);
                                ref.invalidate(passHistoryProvider);
                              },
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),

                      // ── Tabs ──────────────────────────────────────────
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildTab('Active',  _showActive,  () => setState(() => _showActive = true)),
                            _buildTab('History', !_showActive, () => setState(() => _showActive = false)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Content ───────────────────────────────────────
                      if (_showActive) ...[
                        activeAsync.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(
                                color: AppTheme.primaryColor),
                          ),
                          error: (e, _) => Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text('Error: $e',
                                style: const TextStyle(
                                    color: AppTheme.errorColor)),
                          ),
                          data: (passes) => passes.isEmpty
                              ? _buildEmpty('No active passes', isLight)
                              : Column(
                                  children: passes
                                      .map((p) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 8),
                                            child: _buildActiveCard(
                                                p, isLight),
                                          ))
                                      .toList(),
                                ),
                        ),
                      ] else ...[
                        historyAsync.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(
                                color: AppTheme.primaryColor),
                          ),
                          error: (e, _) => Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text('Error: $e',
                                style: const TextStyle(
                                    color: AppTheme.errorColor)),
                          ),
                          data: (passes) => passes.isEmpty
                              ? _buildEmpty('No ticket history', isLight)
                              : Column(
                                  children: passes
                                      .map((p) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 8),
                                            child: _buildHistoryCard(
                                                p, isLight),
                                          ))
                                      .toList(),
                                ),
                        ),
                      ],

                      const SizedBox(height: 30),

                      // ── Quick Actions ─────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick Actions',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                _buildQuickAction(
                                    context,
                                    Icons.confirmation_number_outlined,
                                    'Buy Ticket',
                                    AppRoutes.buyTicket,
                                    isLight),
                                _buildQuickAction(
                                    context,
                                    Icons.card_membership,
                                    'Passes',
                                    AppRoutes.passes,
                                    isLight),
                                _buildQuickAction(
                                    context,
                                    Icons.account_balance_wallet_outlined,
                                    'Top Up',
                                    AppRoutes.wallet,
                                    isLight),
                                _buildQuickAction(
                                    context,
                                    Icons.qr_code_scanner,
                                    'Scan QR',
                                    AppRoutes.scanTicket,
                                    isLight),
                              ],
                            ),
                          ],
                        ).animate().fadeIn(delay: 400.ms),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _buildTab(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white60,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 3,
            width: 40,
            color: isSelected ? Colors.white : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(String msg, bool isLight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        color: isLight ? Colors.white : null,
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.confirmation_num_outlined,
                  size: 64,
                  color: isLight
                      ? Colors.grey.shade300
                      : Colors.white24),
              const SizedBox(height: 16),
              Text(msg,
                  style: TextStyle(
                      color: isLight
                          ? Colors.grey.shade600
                          : Colors.white60,
                      fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveCard(PassModel p, bool isLight) {
    return GlassCard(
      color: isLight ? Colors.white : null,
      padding: const EdgeInsets.all(24),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: 10,
            child: Icon(Icons.directions_bus,
                size: 100,
                color: isLight
                    ? Colors.blue.shade100
                    : Colors.white.withValues(alpha: 0.06)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.typeName,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: isLight ? Colors.black87 : Colors.white)),
              const SizedBox(height: 8),
              Text(p.routeName,
                  style: TextStyle(
                      fontSize: 16,
                      color:
                          isLight ? Colors.grey.shade700 : Colors.white70)),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Valid till',
                          style: TextStyle(
                              fontSize: 12,
                              color: isLight
                                  ? Colors.grey.shade600
                                  : Colors.white60)),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('d MMM yyyy').format(p.validUntil),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color:
                                isLight ? Colors.black87 : Colors.white),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Active',
                        style: TextStyle(
                            color: Colors.green.shade600,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildHistoryCard(PassModel p, bool isLight) {
    return GlassCard(
      color: isLight ? Colors.white : null,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(p.typeName,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isLight ? Colors.black87 : Colors.white)),
              Text(
                DateFormat('d MMM yyyy').format(p.purchasedAt),
                style: TextStyle(
                    fontSize: 13,
                    color:
                        isLight ? Colors.grey.shade600 : Colors.white60),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(p.routeName,
              style: TextStyle(
                  fontSize: 14,
                  color:
                      isLight ? Colors.grey.shade700 : Colors.white70)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Expired ${DateFormat('d MMM yyyy').format(p.validUntil)}',
                style: TextStyle(
                    fontSize: 12,
                    color: isLight ? Colors.grey.shade500 : Colors.white54),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Expired',
                    style: TextStyle(
                        color: Colors.red.shade400,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon,
      String label, String route, bool isLight) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Column(
        children: [
          GlassCard(
            color: isLight ? Colors.white : null,
            padding: const EdgeInsets.all(16),
            borderRadius: 16,
            child: Icon(icon, color: Colors.blue.shade700, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isLight ? Colors.grey.shade800 : Colors.white)),
        ],
      ),
    );
  }
}
