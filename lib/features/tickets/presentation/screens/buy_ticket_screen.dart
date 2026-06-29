import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../../../core/widgets/glass_card.dart';

class BuyTicketScreen extends StatefulWidget {
  const BuyTicketScreen({super.key});

  @override
  State<BuyTicketScreen> createState() => _BuyTicketScreenState();
}

class _BuyTicketScreenState extends State<BuyTicketScreen> {
  String selectedType = 'Daily Pass';

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Ticket'),
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
                'Select Pass Type',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ).animate().fadeIn(),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildPassType('Daily Pass', '\$5', isLight),
                  const SizedBox(width: 16),
                  _buildPassType('Weekly Pass', '\$25', isLight),
                  const SizedBox(width: 16),
                  _buildPassType('Monthly Pass', '\$80', isLight),
                ],
              ).animate().slideY(begin: 0.2).fadeIn(),
              
              const SizedBox(height: 30),
              
              Text(
                'Select Route',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 16),
              GlassCard(
                color: isLight ? Colors.white : null,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: 'All Routes',
                  underline: const SizedBox(),
                  dropdownColor: isLight ? Colors.white : AppTheme.surfaceColorDark,
                  style: TextStyle(color: isLight ? Colors.black87 : Colors.white, fontSize: 16),
                  items: const [
                    DropdownMenuItem(value: 'All Routes', child: Text('All Routes')),
                    DropdownMenuItem(value: 'Downtown Express', child: Text('Downtown Express')),
                  ],
                  onChanged: (val) {},
                ),
              ).animate().slideY(begin: 0.2).fadeIn(delay: 200.ms),
              
              const Spacer(),
              
              GlassCard(
                color: isLight ? Colors.white : null,
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Amount', style: TextStyle(color: isLight ? Colors.grey.shade600 : Colors.white60)),
                        Text('\$5.00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: isLight ? Colors.black87 : Colors.white)),
                      ],
                    ),
                    AnimatedButton(
                      text: 'Continue',
                      width: 140,
                      onPressed: () {
                        // Success Mock
                        context.pop();
                      },
                    ),
                  ],
                ),
              ).animate().slideY(begin: 0.5).fadeIn(delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPassType(String title, String price, bool isLight) {
    final isSelected = selectedType == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedType = title),
        child: GlassCard(
          color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.2) : (isLight ? Colors.white : null),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isLight ? Colors.black87 : Colors.white), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(price, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: isSelected ? AppTheme.primaryColor : (isLight ? Colors.grey.shade700 : Colors.white70))),
            ],
          ),
        ),
      ),
    );
  }
}
