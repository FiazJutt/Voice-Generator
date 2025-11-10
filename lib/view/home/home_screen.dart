import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:voicegenerator/view/audioGenerator/audio_generator_screen.dart';
import 'package:voicegenerator/view/settings/settings_screen.dart';
import 'package:voicegenerator/viewmodel/audio_player_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodel/audio_provider.dart';
import '../../model/audio_model.dart';
import '../audio_player/audio_player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _playingIndex;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
    _setupAudioListeners();
  }

  void _initializeScreen() {
    Future.microtask(
      () =>
          Provider.of<AudioProvider>(context, listen: false).fetchSavedAudios(),
    );
  }

  void _setupAudioListeners() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _playingIndex = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await Provider.of<AudioProvider>(context, listen: false).fetchSavedAudios();
  }

  Future<void> _togglePlayPause(int index, String filePath) async {
    final player = Provider.of<AudioPlayerProvider>(context, listen: false);

    if (!File(filePath).existsSync()) {
      _showSnackBar('Audio file not found');
      return;
    }

    // If another item is playing, stop it first
    if (_playingIndex != null && _playingIndex != index) {
      await player.stopAudio();
    }

    // If same item tapped again
    if (_playingIndex == index) {
      if (player.isPlaying) {
        await player.pauseAudio();
      } else {
        await player.resumeAudio();
      }
    } else {
      await player.initAudio(filePath);
      await player.playAudio(filePath);
      setState(() => _playingIndex = index);
    }

    setState(() => _playingIndex = index); // refresh icon state

    // if (_playingIndex == index && _isPlaying) {
    //   await _audioPlayer.pause();
    // } else if (_playiuysaingIndex == index && !_isPlaying) {
    //   await _audioPlayer.resume();
    // } else {
    //   await _audioPlayer.stop();
    //   await _audioPlayer.play(DeviceFileSource(filePath));
    //   setState(() => _playingIndex = index);
    // }
  }

  Future<void> _shareAudio(AudioModel audio) async {
    final provider = Provider.of<AudioProvider>(context, listen: false);
    await provider.shareAudio(audio);
    _handleProviderMessages(provider);
  }

  Future<void> _saveToDevice(AudioModel audio) async {
    final provider = Provider.of<AudioProvider>(context, listen: false);

    // Try to save directly first (works on Android 13+)
    await provider.saveAudioToDevice(audio);

    if (provider.error != null &&
        (provider.error!.contains('Permission') ||
            provider.error!.contains('access'))) {
      // Permission issue detected, request appropriate permissions
      if (await Permission.manageExternalStorage.isGranted) {
        _handleProviderMessages(provider);
        return;
      }

      // Request permission
      PermissionStatus status = await Permission.manageExternalStorage
          .request();

      if (!status.isGranted) {
        status = await Permission.storage.request();
      }

      if (status.isGranted || status.isLimited) {
        // Retry save after permission granted
        await provider.saveAudioToDevice(audio);
        _handleProviderMessages(provider);
      } else {
        _showSnackBar(
          'Storage permission denied. Please grant permission in app settings.',
          duration: 4,
        );
      }
    } else {
      _handleProviderMessages(provider);
    }
  }

  void _handleProviderMessages(AudioProvider provider) {
    if (provider.successMessage != null) {
      _showSnackBar(provider.successMessage!, isSuccess: true);
      provider.clearMessages();
    } else if (provider.error != null) {
      _showSnackBar(provider.error!);
      provider.clearMessages();
    }
  }

  void _showSnackBar(
    String message, {
    bool isSuccess = false,
    int duration = 3,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green.shade700 : null,
        duration: Duration(seconds: duration),
      ),
    );
  }

  void _showOptionsBottomSheet(AudioModel audio, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildOptionTile(
              icon: Icons.share_rounded,
              title: 'Share',
              onTap: () {
                Navigator.pop(context);
                _shareAudio(audio);
              },
            ),
            _buildOptionTile(
              icon: Icons.download_rounded,
              title: 'Save to Device',
              onTap: () {
                Navigator.pop(context);
                _saveToDevice(audio);
              },
            ),
            _buildOptionTile(
              icon: Icons.info_outline_rounded,
              title: 'Details',
              onTap: () {
                Navigator.pop(context);
                _showDetailsDialog(audio);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
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

  void _showDetailsDialog(AudioModel audio) {
    final provider = Provider.of<AudioProvider>(context, listen: false);
    final displayName =
        audio.displayName ?? provider.getVoiceDisplayName(audio.voice);
    final voiceInfo = audio.language != null && audio.region != null
        ? '$displayName (${audio.language} - ${audio.region})'
        : displayName;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            _buildDetailRow('Text', audio.text),
            const SizedBox(height: 12),
            _buildDetailRow('Voice', voiceInfo),
            if (audio.gender != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow('Gender', audio.gender!),
            ],
            if (audio.properties != null && audio.properties!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildDetailRow('Properties', audio.properties!.join(', ')),
            ],
            const SizedBox(height: 12),
            _buildDetailRow('Created', _formatDate(audio.createdAt)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Voice Generator',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,

        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.audios.isEmpty
            ? _buildEmptyState()
            : _buildAudioList(provider.audios),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AudioGeneratorScreen(),
            ),
          );
          if (result == true) await _refresh();
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Generate',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.graphic_eq_rounded,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No generated audios yet',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the button below to create your first audio',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAudioList(List<AudioModel> audios) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: audios.length,
      itemBuilder: (context, index) {
        final audio = audios[index];
        final isPlaying = _playingIndex == index && _isPlaying;

        final provider = Provider.of<AudioProvider>(context, listen: false);
        final displayName =
            audio.displayName ?? provider.getVoiceDisplayName(audio.voice);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AudioPlayerScreen(
                  audioUrl: audio.filePath,
                  title: audio.voice,
                  audio: audio,
                ),
              ),
            );
          },
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
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isPlaying
                      ? AppColors.primary.withOpacity(0.15)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isPlaying
                      ? Icons.graphic_eq_rounded
                      : Icons.audiotrack_rounded,
                  color: isPlaying ? AppColors.primary : AppColors.icon,
                  size: 28,
                ),
              ),
              title: Text(
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
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '$displayName • ${_formatDate(audio.createdAt)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),

              trailing: Consumer<AudioPlayerProvider>(
                builder: (context, player, _) {
                  final isPlaying = _playingIndex == index && player.isPlaying;
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
                        onPressed: () =>
                            _togglePlayPause(index, audio.filePath),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert_rounded),
                        color: AppColors.icon,
                        onPressed: () => _showOptionsBottomSheet(audio, index),
                      ),
                    ],
                  );
                },
              ),

              // trailing: Row(
              //   mainAxisSize: MainAxisSize.min,
              //   children: [
              //     IconButton(
              //       icon: Icon(
              //         isPlaying
              //             ? Icons.pause_circle_filled_rounded
              //             : Icons.play_circle_filled_rounded,
              //         size: 32,
              //       ),
              //       color: AppColors.primary,
              //       onPressed: () => _togglePlayPause(index, audio.filePath),
              //     ),
              //     IconButton(
              //       icon: const Icon(Icons.more_vert_rounded),
              //       color: AppColors.icon,
              //       onPressed: () => _showOptionsBottomSheet(audio, index),
              //     ),
              //   ],
              // ),
            ),
          ),
        );
      },
    );
  }
}
