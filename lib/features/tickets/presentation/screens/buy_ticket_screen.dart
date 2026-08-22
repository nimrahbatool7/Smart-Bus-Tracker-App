import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../passenger/data/providers/bus_providers.dart';
import '../../data/providers/ticket_providers.dart';

class BuyTicketScreen extends ConsumerStatefulWidget {
  const BuyTicketScreen({super.key});

  @override
  ConsumerState<BuyTicketScreen> createState() => _BuyTicketScreenState();
}

class _BuyTicketScreenState extends ConsumerState<BuyTicketScreen> {
  String?  _selectedTypeId;
  String?  _selectedRouteId; // null = all routes

  @override
  Widget build(BuildContext context) {
    final isLight       = Theme.of(context).brightness == Brightness.light;
    final typesAsync    = ref.watch(ticketTypesProvider);
    final routesAsync   = ref.watch(activeRoutesProvider);
    final purchaseState = ref.watch(purchaseProvider);
    final isLoading     = purchaseState.isLoading;

    // Listen for purchase result
    ref.listen(purchaseProvider, (_, next) {
      next.whenOrNull(
        data: (_) {
          // Invalidate providers so PassManagementScreen + TicketsTab refresh
          ref.invalidate(activePassesProvider);
          ref.invalidate(walletProvider);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pass purchased successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          }
        },
        error: (e, _) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Ticket'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Pass type selection ──────────────────────────────────
              Text(
                'Select Pass Type',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ).animate().fadeIn(),

              const SizedBox(height: 16),

              typesAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.primaryColor)),
                error: (e, _) => Text('Error: $e',
                    style:
                        const TextStyle(color: AppTheme.errorColor)),
                data: (types) => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: types
                        .map((t) => Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: _buildPassTypeCard(
                                  t, isLight),
                            ))
                        .toList(),
                  ),
                ),
              ).animate().slideY(begin: 0.2).fadeIn(),

              const SizedBox(height: 30),

              // ── Route selection ──────────────────────────────────────
              Text(
                'Select Route',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 16),

              routesAsync.when(
                loading: () => const CircularProgressIndicator(
                    color: AppTheme.primaryColor),
                error: (e, _) => Text('Error: $e',
                    style:
                        const TextStyle(color: AppTheme.errorColor)),
                data: (routes) => GlassCard(
                  color: isLight ? Colors.white : null,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  child: DropdownButton<String?>(
                    isExpanded: true,
                    value: _selectedRouteId,
                    underline: const SizedBox(),
                    dropdownColor:
                        isLight ? Colors.white : AppTheme.backgroundDark,
                    style: TextStyle(
                        color:
                            isLight ? Colors.black87 : Colors.white,
                        fontSize: 16),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Routes'),
                      ),
                      ...routes.map((r) => DropdownMenuItem(
                            value: r['id'] as String,
                            child: Text(r['name'] as String),
                          )),
                    ],
                    onChanged: (val) =>
                        setState(() => _selectedRouteId = val),
                  ),
                ),
              ).animate().slideY(begin: 0.2).fadeIn(delay: 200.ms),

              const Spacer(),

              // ── Summary + buy ────────────────────────────────────────
              typesAsync.maybeWhen(
                data: (types) {
                  final selected = _selectedTypeId != null
                      ? types.firstWhere(
                          (t) => t.id == _selectedTypeId,
                          orElse: () => types.first,
                        )
                      : (types.isNotEmpty ? types.first : null);

                  if (selected == null) return const SizedBox();

                  // Ensure selectedTypeId is always initialised
                  if (_selectedTypeId == null && types.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() => _selectedTypeId = types.first.id);
                      }
                    });
                  }

                  return GlassCard(
                    color: isLight ? Colors.white : null,
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Amount',
                                style: TextStyle(
                                    color: isLight
                                        ? Colors.grey.shade600
                                        : Colors.white60)),
                            Text(
                              '\$${selected.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  color: isLight
                                      ? Colors.black87
                                      : Colors.white),
                            ),
                          ],
                        ),
                        AnimatedButton(
                          text: 'Buy Now',
                          width: 140,
                          isLoading: isLoading,
                          onPressed: isLoading
                              ? () {}
                              : () => ref
                                  .read(purchaseProvider.notifier)
                                  .purchase(
                                    ticketTypeId: selected.id,
                                    routeId: _selectedRouteId,
                                  ),
                        ),
                      ],
                    ),
                  ).animate().slideY(begin: 0.5).fadeIn(delay: 400.ms);
                },
                orElse: () => const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPassTypeCard(TicketTypeModel type, bool isLight) {
    final isSelected = _selectedTypeId == type.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedTypeId = type.id),
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.2)
              : (isLight ? Colors.white : Colors.white.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : (isLight
                    ? Colors.grey.shade200
                    : Colors.white.withValues(alpha: 0.1)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              type.name,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isLight ? Colors.black87 : Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '\$${type.price.toStringAsFixed(0)}',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : (isLight
                          ? Colors.grey.shade700
                          : Colors.white70)),
            ),
            const SizedBox(height: 4),
            Text(
              '${type.durationDays}d',
              style: TextStyle(
                  fontSize: 11,
                  color:
                      isLight ? Colors.grey.shade500 : Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
