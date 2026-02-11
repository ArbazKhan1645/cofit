import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../app/routes/app_routes.dart';
import 'package:get_storage/get_storage.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _introPages = [
    {
      'icon': Icons.fitness_center_rounded,
      'title': 'Train with Expert Trainers',
      'description': 'Access 8 weekly workouts from 2 certified trainers. Every workout is designed to adapt to your fitness level.',
      'color': AppColors.primary,
    },
    {
      'icon': Icons.emoji_events_rounded,
      'title': 'Track Your Progress',
      'description': 'Earn badges, track your stats, and celebrate every milestone. Only positive vibes here!',
      'color': AppColors.lavender,
    },
    {
      'icon': Icons.people_rounded,
      'title': 'Join the Community',
      'description': 'Connect with others, share recipes, join challenges, and be part of a supportive fitness family.',
      'color': AppColors.mintFresh,
    },
  ];

  void _nextPage() {
    if (_currentPage < _introPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeIntro();
    }
  }

  void _completeIntro() {
    final storage = GetStorage();
    storage.write('hasSeenIntro', true);
    Get.offAllNamed(AppRoutes.signIn);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _completeIntro,
                  child: Text(
                    'Skip',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                ),
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _introPages.length,
                itemBuilder: (context, index) {
                  final page = _introPages[index];
                  return _buildIntroPage(page, index);
                },
              ),
            ),

            // Page Indicator & Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _introPages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : AppColors.borderLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Next/Get Started button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      child: Text(
                        _currentPage == _introPages.length - 1
                            ? 'Get Started'
                            : 'Next',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroPage(Map<String, dynamic> page, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: (page['color'] as Color).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page['icon'] as IconData,
              size: 80,
              color: page['color'] as Color,
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
          const SizedBox(height: 48),

          // Title
          Text(
            page['title'] as String,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 16),

          // Description
          Text(
            page['description'] as String,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms, duration: 500.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}
