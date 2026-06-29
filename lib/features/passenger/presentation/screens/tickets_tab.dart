import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';

class TicketsTab extends StatefulWidget {
  const TicketsTab({super.key});

  @override
  State<TicketsTab> createState() => _TicketsTabState();
}

class _TicketsTabState extends State<TicketsTab> {
  bool showActive = true;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final headerColor = isLight ? AppTheme.lightBlueHeader : Colors.blue.shade900.withValues(alpha: 0.8);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Top Blue Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: Container(
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
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
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 24), // Spacer for centering
                            const Text(
                              'My Tickets',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 24),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
                      
                      // Custom Tabs
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => showActive = true),
                              child: Column(
                                children: [
                                  Text(
                                    'Active',
                                    style: TextStyle(
                                      color: showActive ? Colors.white : Colors.white60,
                                      fontSize: 16,
                                      fontWeight: showActive ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 3,
                                    width: 40,
                                    color: showActive ? Colors.white : Colors.transparent,
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => showActive = false),
                              child: Column(
                                children: [
                                  Text(
                                    'History',
                                    style: TextStyle(
                                      color: !showActive ? Colors.white : Colors.white60,
                                      fontSize: 16,
                                      fontWeight: !showActive ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 3,
                                    width: 40,
                                    color: !showActive ? Colors.white : Colors.transparent,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Main Content Area
                      if (showActive)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: GlassCard(
                            color: isLight ? Colors.white : null,
                            padding: const EdgeInsets.all(24),
                            child: Stack(
                              children: [
                                Positioned(
                                  right: -20,
                                  top: 10,
                                  child: Icon(Icons.directions_bus, size: 100, color: (isLight ? Colors.blue.shade100 : Colors.white.withValues(alpha: 0.1))),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Monthly Pass', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: isLight ? Colors.black87 : Colors.white)),
                                    const SizedBox(height: 8),
                                    Text('All Routes', style: TextStyle(fontSize: 16, color: isLight ? Colors.grey.shade700 : Colors.white70)),
                                    const SizedBox(height: 30),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Valid till', style: TextStyle(fontSize: 12, color: isLight ? Colors.grey.shade600 : Colors.white60)),
                                            const SizedBox(height: 4),
                                            Text('30 May 2024', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isLight ? Colors.black87 : Colors.white)),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            'Active',
                                            style: TextStyle(color: Colors.green.shade600, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            children: [
                              _buildHistoryCard(
                                title: 'Monthly Pass',
                                route: 'Attock → Islamabad',
                                date: '20 June 2026',
                                amount: '\$45.00',
                                isLight: isLight,
                              ),
                              const SizedBox(height: 16),
                              // Empty state example (commented out or just append)
                              // GlassCard(
                              //   color: isLight ? Colors.white : null,
                              //   padding: const EdgeInsets.all(32),
                              //   child: Center(
                              //     child: Column(
                              //       children: [
                              //         Icon(Icons.history, size: 64, color: isLight ? Colors.grey.shade300 : Colors.white24),
                              //         const SizedBox(height: 16),
                              //         Text('No previous tickets', style: TextStyle(color: isLight ? Colors.grey.shade600 : Colors.white60, fontSize: 16)),
                              //       ],
                              //     ),
                              //   ),
                              // ),
                            ],
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                        ),
                      
                      const SizedBox(height: 30),
                      
                      // Quick Actions
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick Actions',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildQuickAction(context, Icons.confirmation_number_outlined, 'Buy Ticket', '/buy-ticket', isLight),
                                _buildQuickAction(context, Icons.card_membership, 'Passes', '/passes', isLight),
                                _buildQuickAction(context, Icons.account_balance_wallet_outlined, 'Top Up', '/wallet', isLight),
                                _buildQuickAction(context, Icons.qr_code_scanner, 'Scan QR', '/scan-ticket', isLight),
                              ],
                            ),
                          ],
                        ).animate().fadeIn(delay: 400.ms),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Payment Methods
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment Methods',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            GlassCard(
                              color: isLight ? Colors.white : null,
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(Icons.credit_card, color: Colors.blue.shade700, size: 30),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      '•••• 4242',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isLight ? Colors.black87 : Colors.white),
                                    ),
                                  ),
                                  Text(
                                    'VISA',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.blue.shade900),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            GlassCard(
                              color: isLight ? Colors.white : null,
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(Icons.add_circle_outline, color: Colors.blue.shade500),
                                  const SizedBox(width: 16),
                                  Text(
                                    'Add New Card',
                                    style: TextStyle(fontSize: 16, color: isLight ? Colors.black87 : Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 600.ms),
                      ),
                      const SizedBox(height: 100), // Bottom padding
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

  Widget _buildQuickAction(BuildContext context, IconData icon, String label, String route, bool isLight) {
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
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isLight ? Colors.grey.shade800 : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard({
    required String title,
    required String route,
    required String date,
    required String amount,
    required bool isLight,
  }) {
    return GlassCard(
      color: isLight ? Colors.white : null,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isLight ? Colors.black87 : Colors.white)),
              Text(amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isLight ? Colors.blue.shade700 : AppTheme.primaryColor)),
            ],
          ),
          const SizedBox(height: 8),
          Text(route, style: TextStyle(fontSize: 14, color: isLight ? Colors.grey.shade700 : Colors.white70)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date, style: TextStyle(fontSize: 12, color: isLight ? Colors.grey.shade500 : Colors.white54)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Expired', style: TextStyle(color: Colors.red.shade400, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
