import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(title: const Text('About')),
      body: SingleChildScrollView(
        padding: AppPadding.screen,
        child: Column(
          children: [
            const SizedBox(height: 32),
            _buildAppInfo(context),
            const SizedBox(height: 24),
            _buildLinksSection(context),
            const SizedBox(height: 32),
            _buildFooter(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfo(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppPadding.cardLarge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.extraLarge,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: AppRadius.large,
            ),
            child: const Icon(Iconsax.heart, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            'CoFit Collective',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Version 1.0.0',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your community fitness companion.\nWork out together, grow together.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinksSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        children: [
          _buildLinkItem(
            context,
            icon: Iconsax.shield_tick,
            title: 'Privacy Policy',
            onTap: () => launchUrl(
              Uri.parse('https://cofitcollective.com/privacy'),
              mode: LaunchMode.externalApplication,
            ),
          ),
          const Divider(height: 1, indent: 56),
          _buildLinkItem(
            context,
            icon: Iconsax.document_text,
            title: 'Terms of Service',
            onTap: () => launchUrl(
              Uri.parse('https://cofitcollective.com/terms'),
              mode: LaunchMode.externalApplication,
            ),
          ),
          const Divider(height: 1, indent: 56),
          _buildLinkItem(
            context,
            icon: Iconsax.code,
            title: 'Open Source Licenses',
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'CoFit Collective',
              applicationVersion: '1.0.0',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.bgBlush,
          borderRadius: AppRadius.small,
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      trailing: const Icon(Iconsax.arrow_right_3,
          size: 20, color: AppColors.textMuted),
      onTap: onTap,
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Text(
      'Made with love for the fitness community',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textMuted,
          ),
    );
  }
}
