import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/challenge_model.dart';

class FeaturedChallengeCarousel extends StatefulWidget {
  final List<ChallengeModel> challenges;
  final Function(ChallengeModel) onTap;

  const FeaturedChallengeCarousel({
    super.key,
    required this.challenges,
    required this.onTap,
  });

  @override
  State<FeaturedChallengeCarousel> createState() =>
      _FeaturedChallengeCarouselState();
}

class _FeaturedChallengeCarouselState extends State<FeaturedChallengeCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  static const List<LinearGradient> _gradients = [
    AppColors.primaryGradient,
    AppColors.calmGradient,
    AppColors.mintGradient,
    AppColors.energyGradient,
    AppColors.sunsetGradient,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.challenges.length > 1) {
      _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (_pageController.hasClients) {
          final next = (_currentPage + 1) % widget.challenges.length;
          _pageController.animateToPage(
            next,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.challenges.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.challenges.length,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            itemBuilder: (context, index) {
              final challenge = widget.challenges[index];
              final gradient = _gradients[index % _gradients.length];

              return GestureDetector(
                onTap: () => widget.onTap(challenge),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: AppRadius.extraLarge,
                    boxShadow: AppShadows.primaryGlow,
                  ),
                  child: Stack(
                    children: [
                      // Decorative circles
                      Positioned(
                        right: -30,
                        top: -30,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      Positioned(
                        left: -15,
                        bottom: -15,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 40,
                        bottom: 20,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                      ),

                      // Content
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Featured badge + days remaining
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    borderRadius: AppRadius.pill,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Iconsax.star5,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Featured',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  challenge.hasEnded
                                      ? 'Ended'
                                      : '${challenge.daysRemaining}d left',
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            // Title
                            Text(
                              challenge.title,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            // Participants + target
                            Row(
                              children: [
                                const Icon(
                                  Iconsax.people,
                                  size: 14,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${challenge.participantCount} joined',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Colors.white.withValues(
                                          alpha: 0.85,
                                        ),
                                      ),
                                ),
                                const SizedBox(width: 16),
                                const Icon(
                                  Iconsax.chart,
                                  size: 14,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${challenge.targetValue} ${challenge.targetUnit}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Colors.white.withValues(
                                          alpha: 0.85,
                                        ),
                                      ),
                                ),
                              ],
                            ),
                            // Progress bar if joined
                            if (challenge.isJoined) ...[
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: AppRadius.pill,
                                child: LinearProgressIndicator(
                                  value: challenge.progressPercentage,
                                  minHeight: 4,
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.3,
                                  ),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Page indicator dots
        if (widget.challenges.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.challenges.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentPage == index ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? AppColors.primary
                      : AppColors.borderLight,
                  borderRadius: AppRadius.pill,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
