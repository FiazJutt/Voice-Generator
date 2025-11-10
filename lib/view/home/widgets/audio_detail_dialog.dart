import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../model/audio_model.dart';
import '../../../viewmodel/audio_provider.dart';

class AudioDetailsDialog extends StatelessWidget {
  final AudioModel audio;

  const AudioDetailsDialog({
    super.key,
    required this.audio,
  });

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AudioProvider>();
    final displayName =
        audio.displayName ?? provider.getVoiceDisplayName(audio.voice);
    final voiceInfo = audio.language != null && audio.region != null
        ? '$displayName (${audio.language} - ${audio.region})'
        : displayName;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Audio Details',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow(label: 'Text', value: audio.text),
          const SizedBox(height: 12),
          _DetailRow(label: 'Voice', value: voiceInfo),
          if (audio.gender != null) ...[
            const SizedBox(height: 12),
            _DetailRow(label: 'Gender', value: audio.gender!),
          ],
          if (audio.properties != null && audio.properties!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _DetailRow(label: 'Properties', value: audio.properties!.join(', ')),
          ],
          const SizedBox(height: 12),
          _DetailRow(label: 'Created', value: _formatDate(audio.createdAt)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        ),
      ],
    );
  }
}