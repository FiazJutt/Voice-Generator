import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voicegenerator/core/theme/app_colors.dart';
import 'package:voicegenerator/model/audio_model.dart';
import 'package:voicegenerator/viewmodel/audio_provider.dart';
import 'package:voicegenerator/viewmodel/audio_player_provider.dart';

class AudioPlayerScreen extends StatelessWidget {
  final String audioUrl;
  final String title;
  final AudioModel audio;

  const AudioPlayerScreen({
    Key? key,
    required this.audioUrl,
    required this.title,
    required this.audio,
  }) : super(key: key);

  Future<void> _shareAudio(BuildContext context) async {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    await audioProvider.shareAudio(audio);

    if (audioProvider.successMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(audioProvider.successMessage!),
          backgroundColor: Colors.green.shade700,
        ),
      );
      audioProvider.clearMessages();
    } else if (audioProvider.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(audioProvider.error!)));
      audioProvider.clearMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    final displayName =
        audio.displayName ?? audioProvider.getVoiceDisplayName(audio.voice);

    // Truncate title for AppBar if too long
    final appBarTitle = audio.text.length > 30
        ? '${audio.text.substring(0, 30)}...'
        : audio.text;

    return ChangeNotifierProvider(
      create: (_) => AudioPlayerProvider()..initAudio(audioUrl),
      child: Consumer<AudioPlayerProvider>(
        builder: (context, playerProvider, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(appBarTitle, style: const TextStyle(fontSize: 16)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share_rounded),
                  onPressed: () => _shareAudio(context),
                  tooltip: 'Share',
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(80),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.audiotrack,
                      size: 100,
                      color: AppColors.icon,
                    ),
                  ),
                  SizedBox(height: 32),
                  // Full text display
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      audio.text,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Voice information
                  Text(
                    displayName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  if (audio.language != null && audio.region != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${audio.language} - ${audio.region}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  if (audio.properties != null && audio.properties!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        alignment: WrapAlignment.center,
                        children: audio.properties!.map((property) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              property,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  SizedBox(height: 24),
                  Slider(
                    min: 0,
                    max: playerProvider.duration.inSeconds.toDouble(),
                    value: playerProvider.position.inSeconds
                        .clamp(0, playerProvider.duration.inSeconds)
                        .toDouble(),
                    onChanged: (value) {
                      playerProvider.seekAudio(
                        Duration(seconds: value.toInt()),
                      );
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        playerProvider.formatDuration(playerProvider.position),
                      ),
                      Text(
                        playerProvider.formatDuration(playerProvider.duration),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Backward 10s
                      IconButton(
                        icon: const Icon(Icons.replay_10),
                        color: Colors.white,
                        iconSize: 40,
                        onPressed: playerProvider.skipBackward,
                      ),
                      const SizedBox(width: 24),

                      IconButton(
                        icon: Icon(
                          playerProvider.isPlaying
                              ? Icons.pause_circle
                              : Icons.play_circle,
                          size: 64,
                        ),
                        onPressed: () {
                          if (!playerProvider.isPlaying) {
                            playerProvider.playAudio(audioUrl);
                          } else {
                            playerProvider.pauseAudio();
                          }
                        },
                      ),
                      const SizedBox(width: 24),

                      // Forward 10s
                      IconButton(
                        icon: const Icon(Icons.forward_10),
                        color: Colors.white,
                        iconSize: 40,
                        onPressed: playerProvider.skipForward,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
