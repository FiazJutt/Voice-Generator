import 'package:flutter/material.dart';
import 'package:voicegenerator/view/settings/widgets/settings_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: const [
          SettingsSection(
            title: 'Subscription',
            tiles: [
              SettingsTile(
                icon: Icons.star_border_rounded,
                title: 'Manage Subscription',
                subtitle: 'Manage your subscription status',
              ),
              SettingsTile(
                icon: Icons.restore_rounded,
                title: 'Restore Purchases',
                subtitle: 'Restore your previous purchases',
              ),
            ],
          ),
          SettingsSection(
            title: 'App',
            tiles: [
              SettingsTile(
                icon: Icons.rate_review_outlined,
                title: 'Write a Review',
                subtitle: 'Rate us on the App Store',
              ),
              SettingsTile(
                icon: Icons.share_outlined,
                title: 'Share the App',
                subtitle: 'Tell your friends about us',
              ),
            ],
          ),
          SettingsSection(
            title: 'Support',
            tiles: [
              SettingsTile(
                icon: Icons.support_agent_outlined,
                title: 'Contact Support',
                subtitle: 'Get help with any issues',
              ),
            ],
          ),
          SettingsSection(
            title: 'Legal',
            tiles: [
              SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'How we handle your data',
              ),
              SettingsTile(
                icon: Icons.description_outlined,
                title: 'Terms of Use',
                subtitle: 'App Usage Terms and Conditions',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
