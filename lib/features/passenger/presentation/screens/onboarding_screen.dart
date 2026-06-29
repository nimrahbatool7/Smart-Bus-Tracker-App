import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/animated_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Live Bus Tracking',
      'subtitle': 'Watch your bus move in real-time on our interactive city map.',
      'icon': 'directions_bus',
    },
    {
      'title': 'Smart ETA Prediction',
      'subtitle': 'Never miss a bus again with AI-powered arrival time predictions.',
      'icon': 'access_time',
    },
    {
      'title': 'Digital Tickets',
      'subtitle': 'Buy, store, and scan your tickets directly from your device.',
      'icon': 'qr_code_2',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient Animation
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.backgroundDark, Color(0xFF1A1D2B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _onboardingData.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon representing the illustration
                            Icon(
                              _getIconData(_onboardingData[index]['icon']!),
                              size: 150,
                              color: AppTheme.primaryColor,
                            ).animate(target: _currentPage == index ? 1 : 0)
                              .scale(duration: 500.ms, curve: Curves.easeOutBack)
                              .fadeIn()
                              .shimmer(delay: 500.ms, duration: 1500.ms),
                            
                            const SizedBox(height: 60),
                            
                            Text(
                              _onboardingData[index]['title']!,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displayLarge,
                            ).animate(target: _currentPage == index ? 1 : 0)
                              .slideY(begin: 0.2, end: 0, duration: 500.ms)
                              .fadeIn(),
                              
                            const SizedBox(height: 20),
                            
                            Text(
                              _onboardingData[index]['subtitle']!,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white70,
                              ),
                            ).animate(target: _currentPage == index ? 1 : 0)
                              .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 100.ms)
                              .fadeIn(),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 30.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _onboardingData.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: _currentPage == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index ? AppTheme.primaryColor : Colors.white24,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      AnimatedButton(
                        text: _currentPage == _onboardingData.length - 1 ? 'Get Started' : 'Next',
                        onPressed: () {
                          if (_currentPage == _onboardingData.length - 1) {
                            context.go('/login');
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOutCubic,
                            );
                          }
                        },
                      ).animate().fadeIn(delay: 800.ms),
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

  IconData _getIconData(String name) {
    switch (name) {
      case 'directions_bus':
        return Icons.directions_bus;
      case 'access_time':
        return Icons.access_time;
      case 'qr_code_2':
        return Icons.qr_code_2;
      default:
        return Icons.help;
    }
  }
}
