import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerProvider extends ChangeNotifier {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLoading = true;

  bool get isPlaying => _isPlaying;
  Duration get duration => _duration;
  Duration get position => _position;
  bool get isLoading => _isLoading;

  AudioPlayerProvider() {
    _audioPlayer = AudioPlayer();
    _setupListeners();
  }

  void _setupListeners() {
    _audioPlayer.onDurationChanged.listen((d) {
      _duration = d;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((p) {
      _position = p;
      notifyListeners();
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });
  }

  Future<void> initAudio(String audioUrl) async {
    _isLoading = true;
    notifyListeners();

    // Preload metadata (so duration appears without auto-playing)
    await _audioPlayer.setSource(DeviceFileSource(audioUrl));

    // Small delay ensures the metadata is fetched before rendering
    await Future.delayed(const Duration(milliseconds: 300));
    _isLoading = false;
    notifyListeners();
  }

  Future<void> playAudio(String audioUrl) async {
    await _audioPlayer.play(DeviceFileSource(audioUrl));
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
  }

  Future<void> resumeAudio() async {
    await _audioPlayer.resume();
  }

  Future<void> stopAudio() async {
  await _audioPlayer.stop();
  _isPlaying = false;
  _position = Duration.zero;
  notifyListeners();
}


  Future<void> seekAudio(Duration position) async {
    await _audioPlayer.seek(position);
  }

  void skipForward() {
    final newPosition = _position + const Duration(seconds: 10);
    if (newPosition < _duration) {
      seekAudio(newPosition);
    } else {
      seekAudio(_duration);
    }
  }

  void skipBackward() {
    final newPosition = _position - const Duration(seconds: 10);
    if (newPosition > Duration.zero) {
      seekAudio(newPosition);
    } else {
      seekAudio(Duration.zero);
    }
  }

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
