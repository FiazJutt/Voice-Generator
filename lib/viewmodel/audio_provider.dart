import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:deepgram_speech_to_text/deepgram_speech_to_text.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path;
import 'package:voicegenerator/core/deepgram_voices.dart';
import '../core/deepgram_voices.dart';
import '../data/local/audio_database_helper.dart';
import '../model/audio_model.dart';

class AudioProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<AudioModel> _audios = [];
  String? _selectedLanguage;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<AudioModel> get audios => _audios;
  String? get selectedLanguage => _selectedLanguage;

  final _dbHelper = AudioDatabaseHelper.instance;
  Deepgram? _deepgram;
  String? _apiKey;
  String? _successMessage;

  String? get successMessage => _successMessage;

  /// Voice metadata map: modelId -> {displayName, language, region, gender, properties}
  static const Map<String, Map<String, dynamic>> _voiceMetadata =
      deepgramVoices;
  
  /// Get all voice IDs
  List<String> get allVoiceIds => _voiceMetadata.keys.toList();

  /// Get available languages
  List<String> get availableLanguages {
    final languages = <String>{};
    for (var metadata in _voiceMetadata.values) {
      languages.add(metadata['language'] as String);
    }
    return languages.toList()..sort();
  }

  /// Get voices filtered by selected language
  List<Map<String, dynamic>> getVoicesByLanguage(String language) {
    final voices = <Map<String, dynamic>>[];

    _voiceMetadata.forEach((id, metadata) {
      if (metadata['language'] == language) {
        voices.add({'id': id, ...metadata});
      }
    });

    return voices;
  }

  /// Set selected language
  void setLanguage(String language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  /// Get voice metadata from voice model ID
  Map<String, dynamic>? getVoiceMetadata(String voiceId) {
    return _voiceMetadata[voiceId];
  }

  /// Get display name for a voice model ID
  String getVoiceDisplayName(String voiceId) {
    final metadata = _voiceMetadata[voiceId];
    return metadata?['displayName'] ?? voiceId;
  }

  /// Initialize Deepgram API Key
  Future<void> initDeepgram() async {
    _apiKey = dotenv.env['DEEPGRAM_API_KEY'];
    if (_apiKey == null || _apiKey!.isEmpty) {
      _setError("Deepgram API key missing in .env");
      return;
    }
    _error = null;
    notifyListeners();
  }

  Future<void> fetchSavedAudios() async {
    try {
      _audios = await _dbHelper.getAllAudios();
      notifyListeners();
    } catch (e) {
      _setError('Error fetching saved audios: $e');
    }
  }

  /// Generate speech from text using Deepgram TTS API
  Future<void> generateAudio({
    required String text,
    required String voiceId,
  }) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      await initDeepgram();
    }
    if (_apiKey == null || _apiKey!.isEmpty) {
      _setError("Deepgram API key not initialized");
      return;
    }

    if (text.trim().isEmpty) {
      _setError("Please enter some text to generate audio");
      return;
    }

    try {
      _setLoading(true);

      final url = Uri.parse('https://api.deepgram.com/v1/speak?model=$voiceId');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Token $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'text': text}),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to generate audio: ${response.statusCode} - ${response.body}',
        );
      }

      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${dir.path}/audio_$timestamp.mp3';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      if (!await file.exists()) {
        throw Exception('Failed to save audio file');
      }

      // Get voice metadata
      final voiceMetadata = getVoiceMetadata(voiceId);
      
      final audio = AudioModel(
        text: text,
        voice: voiceId,
        filePath: filePath,
        createdAt: DateTime.now(),
        displayName: voiceMetadata?['displayName'],
        language: voiceMetadata?['language'],
        region: voiceMetadata?['region'],
        gender: voiceMetadata?['gender'],
        properties: voiceMetadata?['properties'] != null
            ? List<String>.from(voiceMetadata!['properties'])
            : null,
      );

      final id = await _dbHelper.insertAudio(audio);
      if (id == 0) {
        throw Exception('Failed to save audio to database');
      }

      await fetchSavedAudios();
      _setSuccess('Audio generated successfully!');
    } catch (e) {
      _setError('Error generating audio: $e');
      debugPrint('Error generating audio: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Save audio to device
  Future<void> saveAudioToDevice(AudioModel audio) async {
    final sourceFile = File(audio.filePath);
    if (!await sourceFile.exists()) {
      _setError('Audio file not found. Please regenerate.');
      return;
    }

    _setLoading(true);

    try {
      Directory? downloadsDir;

      if (Platform.isAndroid) {
        final possiblePaths = [
          '/storage/emulated/0/Download',
          '/sdcard/Download',
          '/storage/sdcard0/Download',
        ];

        for (final possiblePath in possiblePaths) {
          downloadsDir = Directory(possiblePath);
          if (await downloadsDir.exists()) {
            break;
          }
        }
      }

      final voiceName = audio.voice
          .replaceAll('aura-', '')
          .replaceAll('-en', '')
          .replaceAll('-es', '');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${voiceName}_voice_$timestamp.mp3';
      final newPath = path.join(downloadsDir!.path, fileName);

      final newFile = await sourceFile.copy(newPath);

      if (await newFile.exists()) {
        final isInDownloads =
            newPath.contains('Download') || newPath.contains('download');
        final locationName = isInDownloads ? 'Downloads' : 'App Storage';
        _setSuccess('Audio saved to $locationName folder!\nFile: $fileName');
      } else {
        throw Exception('File was not created at $newPath');
      }
    } catch (e) {
      _setError('Error saving audio: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Share audio file
  Future<void> shareAudio(AudioModel audio) async {
    final file = File(audio.filePath);
    if (!await file.exists()) {
      _setError('Audio file not found. Please regenerate.');
      return;
    }

    try {
      final xFile = XFile(audio.filePath, mimeType: 'audio/mpeg');
      final result = await Share.shareXFiles(
        [xFile],
        text: 'Generated audio: ${audio.text}',
        subject: 'Voice: ${audio.voice}',
      );

      if (result.status == ShareResultStatus.success) {
        _setSuccess('Audio shared successfully!');
      }
    } catch (e) {
      _setError('Error sharing audio: $e');
    }
  }

  /// Delete audio
  Future<void> deleteAudio(AudioModel audio) async {
    try {
      final file = File(audio.filePath);
      if (await file.exists()) {
        await file.delete();
      }

      if (audio.id != null) {
        await _dbHelper.deleteAudio(audio.id!);
      }

      await fetchSavedAudios();
      _setSuccess('Audio deleted successfully');
    } catch (e) {
      _setError('Error deleting audio: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    _successMessage = null;
    notifyListeners();

    Future.delayed(const Duration(seconds: 5), () {
      if (_error == message) {
        _error = null;
        notifyListeners();
      }
    });
  }

  void _setSuccess(String message) {
    _successMessage = message;
    _error = null;
    notifyListeners();

    Future.delayed(const Duration(seconds: 3), () {
      if (_successMessage == message) {
        _successMessage = null;
        notifyListeners();
      }
    });
  }

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
}
