import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../model/audio_model.dart';

class AudioOptionsBottomSheet extends StatelessWidget {
  final AudioModel audio;
  final VoidCallback onShare;
  final VoidCallback onSave;
  final VoidCallback onDetails;

  const AudioOptionsBottomSheet({
    super.key,
    required this.audio,
    required this.onShare,
    required this.onSave,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          const SizedBox(height: 20),
          _OptionTile(
            icon: Icons.share_rounded,
            title: 'Share',
            onTap: onShare,
          ),
          _OptionTile(
            icon: Icons.download_rounded,
            title: 'Save to Device',
            onTap: onSave,
          ),
          _OptionTile(
            icon: Icons.info_outline_rounded,
            title: 'Details',
            onTap: onDetails,
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}