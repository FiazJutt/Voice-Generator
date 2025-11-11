import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:voicegenerator/view/audioGenerator/audio_generator_screen.dart';
import 'package:voicegenerator/view/home/widgets/audio_detail_dialog.dart';
import 'package:voicegenerator/view/home/widgets/audio_option_bottom_sheet.dart';
import 'package:voicegenerator/view/settings/settings_screen.dart';
import 'package:voicegenerator/viewmodel/audio_player_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodel/audio_provider.dart';
import '../../model/audio_model.dart';
import '../audio_player/audio_player_screen.dart';
import 'widgets/audio_list_item.dart';
import 'widgets/empty_state_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  void _initializeScreen() {
    Future.microtask(() => context.read<AudioProvider>().fetchSavedAudios());
  }

  Future<void> _refresh() async {
    await context.read<AudioProvider>().fetchSavedAudios();
  }

  Future<void> _togglePlayPause(int index, String filePath) async {
    final player = context.read<AudioPlayerProvider>();

    if (!File(filePath).existsSync()) {
      _showSnackBar('Audio file not found');
      return;
    }

    final isSameTrack = player.currentUrl == filePath;

    // Toggle play/pause for same track, otherwise start new (stopping current if playing)
    if (isSameTrack) {
      if (player.isPlaying) {
        await player.pauseAudio();
      } else {
        // If the track already finished, resume may not restart on some platforms.
        // Detect completed state and call playAudio to force a restart.
        final duration = player.duration;
        final position = player.position;
        final bool isCompleted =
            (duration != Duration.zero && position >= duration) ||
            (duration != Duration.zero &&
                position == Duration.zero &&
                !player.isPlaying);

        if (isCompleted) {
          await player.playAudio(filePath);
        } else {
          await player.resumeAudio();
        }
      }
    } else {
      // Different track - stop current if playing and start new one
      if (player.isPlaying) {
        await player.stopAudio();
      }
      await player.initAudio(filePath);
      await player.playAudio(filePath);
    }
  }

  Future<void> _shareAudio(AudioModel audio) async {
    final provider = context.read<AudioProvider>();
    await provider.shareAudio(audio);
    _handleProviderMessages(provider);
  }

  Future<void> _saveToDevice(AudioModel audio) async {
    final provider = context.read<AudioProvider>();
    await provider.saveAudioToDevice(audio);

    if (provider.error != null &&
        (provider.error!.contains('Permission') ||
            provider.error!.contains('access'))) {
      await _handleStoragePermission(provider, audio);
    } else {
      _handleProviderMessages(provider);
    }
  }

  Future<void> _renameAudio(AudioModel audio) async {
    final provider = context.read<AudioProvider>();

    final currentName =
        audio.title ?? provider.getVoiceDisplayName(audio.voice);
    final TextEditingController controller = TextEditingController(
      text: currentName,
    );

    final result = await showDialog<String?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Audio'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'New name'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = controller.text.trim();
                Navigator.pop(context, newName.isEmpty ? null : newName);
              },
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      await provider.renameAudio(audio, result);
      _handleProviderMessages(provider);
    }
  }

  Future<void> _deleteAudio(AudioModel audio) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete audio'),
        content: const Text(
          'Are you sure you want to delete this audio? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final provider = context.read<AudioProvider>();
      await provider.deleteAudio(audio);
      _handleProviderMessages(provider);
    }
  }

  Future<void> _handleStoragePermission(
    AudioProvider provider,
    AudioModel audio,
  ) async {
    if (await Permission.manageExternalStorage.isGranted) {
      _handleProviderMessages(provider);
      return;
    }

    PermissionStatus status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    if (status.isGranted || status.isLimited) {
      await provider.saveAudioToDevice(audio);
      _handleProviderMessages(provider);
    } else {
      _showSnackBar(
        'Storage permission denied. Please grant permission in app settings.',
        duration: 4,
      );
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
    if (!mounted) return;
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
      builder: (context) => AudioOptionsBottomSheet(
        audio: audio,
        onSave: () {
          Navigator.pop(context);
          _saveToDevice(audio);
        },
        onDetails: () {
          Navigator.pop(context);
          _showDetailsDialog(audio);
        },
        onRename: () {
          Navigator.pop(context);
          _renameAudio(audio);
        },
        onDelete: () {
          Navigator.pop(context);
          _deleteAudio(audio);
        },
        onShare: () {
          Navigator.pop(context);
          _shareAudio(audio);
        },
      ),
    );
  }

  void _showDetailsDialog(AudioModel audio) {
    showDialog(
      context: context,
      builder: (context) => AudioDetailsDialog(audio: audio),
    );
  }

  void _navigateToAudioPlayer(AudioModel audio) {
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
  }

  Future<void> _navigateToGenerator() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AudioGeneratorScreen()),
    );
    if (result == true && mounted) {
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Voice Generator',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: AppColors.background,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    final provider = context.watch<AudioProvider>();

    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.primary,
      child: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.audios.isEmpty
          ? const EmptyStateWidget()
          : _buildAudioList(provider.audios),
    );
  }

  Widget _buildAudioList(List<AudioModel> audios) {
    final player = context.watch<AudioPlayerProvider>();
    final currentIndex = audios.indexWhere(
      (a) => a.filePath == player.currentUrl,
    );

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: audios.length,
      itemBuilder: (context, index) {
        final audio = audios[index];
        return AudioListItem(
          audio: audio,
          index: index,
          playingIndex: currentIndex >= 0 ? currentIndex : null,
          onTap: () => _navigateToAudioPlayer(audio),
          onPlayPause: () => _togglePlayPause(index, audio.filePath),
          onOptions: () => _showOptionsBottomSheet(audio, index),
        );
      },
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _navigateToGenerator,
      backgroundColor: AppColors.primary,
      icon: const Icon(Icons.add_rounded),
      label: const Text(
        'Generate',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
