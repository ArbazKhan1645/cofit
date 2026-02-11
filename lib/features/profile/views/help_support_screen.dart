import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const _faqs = [
    {
      'q': 'How do I track my workouts?',
      'a':
          'Go to the Workouts tab, pick a workout, and tap "Start Workout". Your progress will be tracked automatically and added to your stats.',
    },
    {
      'q': 'Can I create custom workout plans?',
      'a':
          'Currently, workouts are curated by our trainers. Custom workout plans are coming soon in a future update!',
    },
    {
      'q': 'How do streaks work?',
      'a':
          'Your streak increases by 1 for every consecutive day you complete at least one workout. Missing a day resets your streak to 0.',
    },
    {
      'q': 'How do I join a challenge?',
      'a':
          'Head to the Community tab and browse active challenges. Tap on a challenge to see details and join. Your progress will be tracked alongside other participants.',
    },
    {
      'q': 'How do I cancel my subscription?',
      'a':
          'Go to Profile > Subscription to manage your plan. You can cancel anytime — your access continues until the end of the billing period.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(title: const Text('Help & Support')),
      body: SingleChildScrollView(
        padding: AppPadding.screen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildFaqSection(context),
            const SizedBox(height: 24),
            _buildContactSection(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text('Frequently Asked Questions',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ),
          ..._faqs.map((faq) => ExpansionTile(
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 16),
                childrenPadding:
                    const EdgeInsets.fromLTRB(16, 0, 16, 16),
                title: Text(
                  faq['q']!,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                children: [
                  Text(
                    faq['a']!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text('Contact Us',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.bgBlush,
                borderRadius: AppRadius.small,
              ),
              child: const Icon(Iconsax.sms,
                  color: AppColors.primary, size: 20),
            ),
            title: const Text('Email Support'),
            subtitle: const Text('support@cofitcollective.com'),
            trailing: const Icon(Iconsax.arrow_right_3,
                size: 20, color: AppColors.textMuted),
            onTap: () => launchUrl(
              Uri.parse('mailto:support@cofitcollective.com'),
            ),
          ),
        ],
      ),
    );
  }
}
