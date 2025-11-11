import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerProvider extends ChangeNotifier {
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLoading = true;
  String? _currentUrl;

  bool get isPlaying => _isPlaying;
  Duration get duration => _duration;
  Duration get position => _position;
  bool get isLoading => _isLoading;
  String? get currentUrl => _currentUrl;

  AudioPlayerProvider() {
    _initPlayer();
  }

  void _initPlayer() {
    _audioPlayer = AudioPlayer();
    _setupListeners();
  }

  void _setupListeners() {
    _audioPlayer?.onDurationChanged.listen((d) {
      _duration = d;
      notifyListeners();
    });

    _audioPlayer?.onPositionChanged.listen((p) {
      _position = p;
      notifyListeners();
    });

    _audioPlayer?.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });

    _audioPlayer?.onPlayerComplete.listen((_) {
      _isPlaying = false;
      _position = Duration.zero;
      notifyListeners();
    });
  }

  Future<void> initAudio(String audioUrl) async {
    _isLoading = true;
    notifyListeners();

    await _audioPlayer?.setSource(DeviceFileSource(audioUrl));
    _currentUrl = audioUrl;

    await Future.delayed(const Duration(milliseconds: 300));
    _isLoading = false;
    notifyListeners();
  }

  Future<void> playAudio(String audioUrl) async {
    // If same file and player is "stuck", rebuild it
    if (_currentUrl == audioUrl) {
      await _audioPlayer?.dispose();
      _initPlayer();
    }

    await _audioPlayer?.setSource(DeviceFileSource(audioUrl));
    await _audioPlayer?.seek(Duration.zero);
    await _audioPlayer?.resume();

    _currentUrl = audioUrl;
    _isPlaying = true;
    notifyListeners();
  }

  Future<void> pauseAudio() async {
    await _audioPlayer?.pause();
  }

  Future<void> resumeAudio() async {
    await _audioPlayer?.resume();
  }

  Future<void> stopAudio() async {
    await _audioPlayer?.stop();
    _isPlaying = false;
    _position = Duration.zero;
    notifyListeners();
  }

  Future<void> seekAudio(Duration position) async {
    await _audioPlayer?.seek(position);
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
    _audioPlayer?.dispose();
    super.dispose();
  }
}














// import 'package:flutter/foundation.dart';
// import 'package:audioplayers/audioplayers.dart';

// class AudioPlayerProvider extends ChangeNotifier {
//   late AudioPlayer _audioPlayer;
//   bool _isPlaying = false;
//   Duration _duration = Duration.zero;
//   Duration _position = Duration.zero;
//   bool _isLoading = true;
//   String? _currentUrl;

//   bool get isPlaying => _isPlaying;
//   Duration get duration => _duration;
//   Duration get position => _position;
//   bool get isLoading => _isLoading;
//   String? get currentUrl => _currentUrl;

//   AudioPlayerProvider() {
//     _audioPlayer = AudioPlayer();
//     _setupListeners();
//   }

//   void _setupListeners() {
//     _audioPlayer.onDurationChanged.listen((d) {
//       _duration = d;
//       notifyListeners();
//     });

//     _audioPlayer.onPositionChanged.listen((p) {
//       _position = p;
//       notifyListeners();
//     });

//     _audioPlayer.onPlayerStateChanged.listen((state) {
//       _isPlaying = state == PlayerState.playing;
//       notifyListeners();
//     });
//     _audioPlayer.onPlayerComplete.listen((_) {
//       _isPlaying = false;
//       _position = Duration.zero;
//       notifyListeners();
//     });
//   }

//   Future<void> initAudio(String audioUrl) async {
//     _isLoading = true;
//     notifyListeners();

//     // Preload metadata (so duration appears without auto-playing)
//     await _audioPlayer.setSource(DeviceFileSource(audioUrl));
//     _currentUrl = audioUrl;

//     // Small delay ensures the metadata is fetched before rendering
//     await Future.delayed(const Duration(milliseconds: 300));
//     _isLoading = false;
//     notifyListeners();
//   }

//   Future<void> playAudio(String audioUrl) async {
//   // If it's the same file, just restart from beginning
//   if (_currentUrl == audioUrl) {
//     await _audioPlayer.stop();
//     await _audioPlayer.setSource(DeviceFileSource(audioUrl));
//     await _audioPlayer.seek(Duration.zero);
//   } else {
//     // For a new file, load source fresh
//     await _audioPlayer.setSource(DeviceFileSource(audioUrl));
//     _currentUrl = audioUrl;
//   }

//   await _audioPlayer.resume(); // ensure it actually plays
//   _isPlaying = true;
//   notifyListeners();
// }


//   // Future<void> playAudio(String audioUrl) async {
//   //   if (_currentUrl == audioUrl) {
//   //     // Stop first to allow replay of same file
//   //     await _audioPlayer.stop();
//   //   }
//   //   await _audioPlayer.play(DeviceFileSource(audioUrl));
//   //   _currentUrl = audioUrl;
//   // }

//   Future<void> pauseAudio() async {
//     await _audioPlayer.pause();
//   }

//   Future<void> resumeAudio() async {
//     await _audioPlayer.resume();
//   }

//   Future<void> stopAudio() async {
//   await _audioPlayer.stop();
//   _isPlaying = false;
//   _position = Duration.zero;
//   _currentUrl = null;
//   notifyListeners();
// }


//   Future<void> seekAudio(Duration position) async {
//     await _audioPlayer.seek(position);
//   }

//   void skipForward() {
//     final newPosition = _position + const Duration(seconds: 10);
//     if (newPosition < _duration) {
//       seekAudio(newPosition);
//     } else {
//       seekAudio(_duration);
//     }
//   }

//   void skipBackward() {
//     final newPosition = _position - const Duration(seconds: 10);
//     if (newPosition > Duration.zero) {
//       seekAudio(newPosition);
//     } else {
//       seekAudio(Duration.zero);
//     }
//   }

//   String formatDuration(Duration d) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final minutes = twoDigits(d.inMinutes.remainder(60));
//     final seconds = twoDigits(d.inSeconds.remainder(60));
//     return '$minutes:$seconds';
//   }

//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     super.dispose();
//   }
// }
