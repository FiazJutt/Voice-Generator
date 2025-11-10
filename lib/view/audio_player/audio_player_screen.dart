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

    final playerProvider = context.watch<AudioPlayerProvider>();

    // Initialize only when:
    // - No track is loaded yet, or
    // - A different track is selected while nothing is playing.
    final currentUrl = playerProvider.currentUrl;
    final isDifferentTrack = currentUrl != null && currentUrl != audioUrl;
    final shouldInit = currentUrl == null || (!playerProvider.isPlaying && isDifferentTrack);
    if (shouldInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AudioPlayerProvider>().initAudio(audioUrl);
      });
    }

    // Check if this screen's track is the currently playing one
    final isThisTrackActive = playerProvider.currentUrl == audioUrl;
    final isThisTrackPlaying = isThisTrackActive && playerProvider.isPlaying;

    return Scaffold(
            appBar: AppBar(
              // title: Text(appBarTitle, style: const TextStyle(fontSize: 16)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share_rounded),
                  onPressed: () => _shareAudio(context),
                  tooltip: 'Share',
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
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
                  SizedBox(height: 24),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 12),

                  ///
                  ///
                  ///// Voice information
                  // Text(
                  //   displayName,
                  //   style: TextStyle(
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.w600,
                  //     color: AppColors.primary,
                  //   ),
                  // ),
                  // if (audio.language != null && audio.region != null)
                  //   Padding(
                  //     padding: const EdgeInsets.only(top: 4),
                  //     child: Text(
                  //       '${audio.language} - ${audio.region}',
                  //       style: TextStyle(
                  //         fontSize: 14,
                  //         color: AppColors.textSecondary,
                  //       ),
                  //     ),
                  //   ),
                  // if (audio.properties != null && audio.properties!.isNotEmpty)
                  //   Padding(
                  //     padding: const EdgeInsets.only(top: 8),
                  //     child: Wrap(
                  //       spacing: 6,
                  //       runSpacing: 6,
                  //       alignment: WrapAlignment.center,
                  //       children: audio.properties!.map((property) {
                  //         return Container(
                  //           padding: EdgeInsets.symmetric(
                  //             horizontal: 12,
                  //             vertical: 6,
                  //           ),
                  //           decoration: BoxDecoration(
                  //             color: AppColors.primary.withOpacity(0.1),
                  //             borderRadius: BorderRadius.circular(16),
                  //             border: Border.all(
                  //               color: AppColors.primary.withOpacity(0.3),
                  //               width: 1,
                  //             ),
                  //           ),
                  //           child: Text(
                  //             property,
                  //             style: TextStyle(
                  //               fontSize: 12,
                  //               color: AppColors.primary,
                  //               fontWeight: FontWeight.w500,
                  //             ),
                  //           ),
                  //         );
                  //       }).toList(),
                  //     ),
                  //   ),

                  ///
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      [
                        displayName,
                        if (audio.language != null && audio.region != null)
                          '${audio.language} - ${audio.region}\n',
                        if (audio.language != null && audio.region == null)
                          audio.language!,
                        if (audio.properties != null &&
                            audio.properties!.isNotEmpty)
                          audio.properties!.join(', '),
                      ].whereType<String>().join(' • '),
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 24),
                  Slider(
                    min: 0,
                    max: isThisTrackActive
                        ? playerProvider.duration.inSeconds.toDouble()
                        : 1.0,
                    value: isThisTrackActive
                        ? playerProvider.position.inSeconds
                            .clamp(0, playerProvider.duration.inSeconds)
                            .toDouble()
                        : 0.0,
                    onChanged: isThisTrackActive
                        ? (value) {
                            playerProvider.seekAudio(
                              Duration(seconds: value.toInt()),
                            );
                          }
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isThisTrackActive
                              ? playerProvider
                                  .formatDuration(playerProvider.position)
                              : '00:00',
                        ),
                        Text(
                          isThisTrackActive
                              ? playerProvider
                                  .formatDuration(playerProvider.duration)
                              : '00:00',
                        ),
                      ],
                    ),
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
                        onPressed: isThisTrackActive ? playerProvider.skipBackward : null,
                      ),
                      const SizedBox(width: 24),

                      IconButton(
                        icon: Icon(
                          isThisTrackPlaying
                              ? Icons.pause_circle
                              : Icons.play_circle,
                          size: 64,
                        ),
                        onPressed: () async {
                          if (isThisTrackActive) {
                            // This track is loaded - toggle play/pause
                            if (playerProvider.isPlaying) {
                              await playerProvider.pauseAudio();
                            } else {
                              await playerProvider.resumeAudio();
                            }
                          } else {
                            // Different track - stop current and play this one
                            if (playerProvider.isPlaying) {
                              await playerProvider.stopAudio();
                            }
                            await playerProvider.initAudio(audioUrl);
                            await playerProvider.playAudio(audioUrl);
                          }
                        },
                      ),
                      const SizedBox(width: 24),

                      // Forward 10s
                      IconButton(
                        icon: const Icon(Icons.forward_10),
                        color: Colors.white,
                        iconSize: 40,
                        onPressed: isThisTrackActive ? playerProvider.skipForward : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
  }
}
