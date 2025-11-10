import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../model/audio_model.dart';
import '../../../viewmodel/audio_provider.dart';
import '../../../viewmodel/audio_player_provider.dart';

class AudioListItem extends StatelessWidget {
  final AudioModel audio;
  final int index;
  final int? playingIndex;
  final VoidCallback onTap;
  final VoidCallback onPlayPause;
  final VoidCallback onOptions;

  const AudioListItem({
    super.key,
    required this.audio,
    required this.index,
    required this.playingIndex,
    required this.onTap,
    required this.onPlayPause,
    required this.onOptions,
  });

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AudioProvider>();
    final displayName =
        audio.displayName ?? provider.getVoiceDisplayName(audio.voice);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: _buildLeadingIcon(),
          title: _buildTitle(),
          subtitle: _buildSubtitle(displayName),
          trailing: _buildTrailingActions(),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon() {
    return Consumer<AudioPlayerProvider>(
      builder: (context, player, _) {
        final isPlaying = playingIndex == index && player.isPlaying;
        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isPlaying
                ? AppColors.primary.withOpacity(0.15)
                : AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isPlaying ? Icons.graphic_eq_rounded : Icons.audiotrack_rounded,
            color: isPlaying ? AppColors.primary : AppColors.icon,
            size: 28,
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return Text(
      audio.text.length > 50
          ? '${audio.text.substring(0, 50)}...'
          : audio.text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSubtitle(String displayName) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        '$displayName • ${_formatDate(audio.createdAt)}',
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTrailingActions() {
    return Consumer<AudioPlayerProvider>(
      builder: (context, player, _) {
        final isPlaying = playingIndex == index && player.isPlaying;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isPlaying
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_filled_rounded,
                size: 32,
              ),
              color: AppColors.primary,
              onPressed: onPlayPause,
            ),
            IconButton(
              icon: const Icon(Icons.more_vert_rounded),
              color: AppColors.icon,
              onPressed: onOptions,
            ),
          ],
        );
      },
    );
  }
}