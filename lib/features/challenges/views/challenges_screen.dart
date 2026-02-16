import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/challenge_model.dart';
import '../controllers/challenge_controller.dart';
import 'widgets/challenge_card.dart';
import 'widgets/featured_challenge_carousel.dart';

class ChallengesScreen extends GetView<ChallengeController> {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text('Challenges'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.activeChallenges.isEmpty &&
            controller.upcomingChallenges.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refreshChallenges,
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              // Featured carousel
              if (controller.featuredChallenges.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    child: FeaturedChallengeCarousel(
                      challenges: controller.featuredChallenges,
                      onTap: (challenge) => _openDetail(challenge.id),
                    ),
                  ),
                ),

              // Tab chips
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Obx(() => SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildTabChip(context, 'Active', 0),
                            const SizedBox(width: 8),
                            _buildTabChip(context, 'Upcoming', 1),
                            const SizedBox(width: 8),
                            _buildTabChip(context, 'My Challenges', 2),
                          ],
                        ),
                      )),
                ),
              ),

              // Tab content
              Obx(() {
                switch (controller.selectedTabIndex.value) {
                  case 0:
                    return _buildChallengeList(
                        controller.activeChallenges, 'active');
                  case 1:
                    return _buildChallengeList(
                        controller.upcomingChallenges, 'upcoming');
                  case 2:
                    return _buildMyChallengesList();
                  default:
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
              }),

              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTabChip(BuildContext context, String label, int index) {
    final selected = controller.selectedTabIndex.value == index;
    return GestureDetector(
      onTap: () {
        controller.selectedTabIndex.value = index;
        if (index == 2 && controller.completedChallenges.isEmpty) {
          controller.loadMyCompletedChallenges();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: AppRadius.pill,
          boxShadow: selected ? AppShadows.primaryGlow : AppShadows.subtle,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }

  SliverList _buildChallengeList(
      List<ChallengeModel> challenges, String type) {
    if (challenges.isEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate([
          _buildEmptyState(type),
        ]),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final challenge = challenges[index];
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: ChallengeCard(
              challenge: challenge,
              onTap: () => _openDetail(challenge.id),
            )
                .animate()
                .fadeIn(
                    delay: Duration(milliseconds: index * 60),
                    duration: 400.ms)
                .slideY(begin: 0.08, end: 0),
          );
        },
        childCount: challenges.length,
      ),
    );
  }

  SliverList _buildMyChallengesList() {
    final active = controller.myChallenges;
    final completed = controller.completedChallenges;

    if (active.isEmpty && completed.isEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate([
          _buildEmptyState('my'),
        ]),
      );
    }

    final items = <Widget>[];

    // Active challenges section
    if (active.isNotEmpty) {
      items.add(Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: Text(
          'In Progress',
          style: Theme.of(Get.context!).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ));

      for (int i = 0; i < active.length; i++) {
        final uc = active[i];
        if (uc.challenge != null) {
          items.add(Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: ChallengeCard(
              challenge: uc.challenge!.copyWith(
                isJoined: true,
                userProgress: uc.currentProgress,
                userRank: uc.rank,
              ),
              onTap: () => _openDetail(uc.challengeId),
            )
                .animate()
                .fadeIn(
                    delay: Duration(milliseconds: i * 60), duration: 400.ms)
                .slideY(begin: 0.08, end: 0),
          ));
        }
      }
    }

    // Completed challenges section
    if (completed.isNotEmpty) {
      items.add(Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        child: Text(
          'Completed',
          style: Theme.of(Get.context!).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ));

      for (int i = 0; i < completed.length; i++) {
        final uc = completed[i];
        if (uc.challenge != null) {
          items.add(Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: ChallengeCard(
              challenge: uc.challenge!.copyWith(
                isJoined: true,
                userProgress: uc.currentProgress,
                userRank: uc.rank,
              ),
              onTap: () => _openDetail(uc.challengeId),
            )
                .animate()
                .fadeIn(
                    delay: Duration(milliseconds: i * 60), duration: 400.ms)
                .slideY(begin: 0.08, end: 0),
          ));
        }
      }
    }

    return SliverList(
      delegate: SliverChildListDelegate(items),
    );
  }

  Widget _buildEmptyState(String type) {
    String message;
    IconData icon;

    switch (type) {
      case 'active':
        message = 'No active challenges right now';
        icon = Iconsax.cup;
        break;
      case 'upcoming':
        message = 'No upcoming challenges';
        icon = Iconsax.calendar_1;
        break;
      default:
        message = 'You haven\'t joined any challenges yet';
        icon = Iconsax.flag;
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.bgBlush,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(String challengeId) {
    controller.loadChallengeDetail(challengeId);
    Get.toNamed(AppRoutes.challengeDetail);
  }
}
