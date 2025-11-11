import 'dart:convert';
import 'dart:io';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path;
import 'package:voicegenerator/core/deepgram_voices.dart';
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
      
      // Create default title for the audio. Use a short excerpt of the text if available, else timestamp.
      String defaultTitle;
      // final trimmedText = text.trim();
      // if (trimmedText.isNotEmpty) {
        // final excerpt = trimmedText.length > 20 ? '${trimmedText.substring(0, 20)}...' : trimmedText;
        // defaultTitle = excerpt;
      // } else {
        defaultTitle = 'Audio_$timestamp';
        debugPrint('Default title set to $defaultTitle');
      // }

      final audio = AudioModel(
        text: text,
        voice: voiceId,
        filePath: filePath,
        createdAt: DateTime.now(),
        title: defaultTitle,
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

  Future<void> saveAudioToDevice(AudioModel audio, {String? targetDirPath}) async {
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

      // Use the audio title (if present) as the file name when saving.
      final safeTitle = (audio.title ?? 'audio')
          .replaceAll(RegExp(r'[^A-Za-z0-9 _-]'), '')
          .replaceAll(' ', '_');
      final fileName = '${safeTitle}.mp3';

      // If a target directory path was provided (user picked), copy the file there.
      if (targetDirPath != null && targetDirPath.isNotEmpty) {
        final targetDir = Directory(targetDirPath);
        if (!await targetDir.exists()) {
          try {
            await targetDir.create(recursive: true);
          } catch (e) {
            // ignore and fall back
          }
        }

        final newPath = path.join(targetDir.path, fileName);
        final newFile = await sourceFile.copy(newPath);

        if (await newFile.exists()) {
          final isInDownloads = newPath.toLowerCase().contains('download');
          final locationName = isInDownloads ? 'Downloads' : 'App Storage';
          _setSuccess('Audio saved to $locationName folder!\nFile: $fileName');
          return;
        }
      }

      // No explicit target dir: try FileSaver first so platform handles the save.
      try {
        final bytes = await sourceFile.readAsBytes();
        // FileSaver expects named parameters: name (without extension), bytes,
        // fileExtension, and mimeType.
        await FileSaver.instance.saveAs(
          name: safeTitle,
          bytes: bytes,
          fileExtension: 'mp3',
          mimeType: MimeType.mp3,
        );
        _setSuccess('Audio saved to device Downloads');
        return;
      } catch (e) {
        debugPrint('FileSaver save failed: $e');
        // Fall through to copying into a local folder.
      }

      // Fallback: save into detected Downloads or application documents
      final targetDir = downloadsDir ?? await getApplicationDocumentsDirectory();
      final newPath = path.join(targetDir.path, fileName);
      final newFile = await sourceFile.copy(newPath);

      if (await newFile.exists()) {
        final isInDownloads = newPath.toLowerCase().contains('download');
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
      final title = audio.title ?? audio.text;
      final result = await Share.shareXFiles(
        [xFile],
        text: 'Generated audio: ${audio.text}',
        subject: title,
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

  /// Rename audio (update the title in database)
  Future<void> renameAudio(AudioModel audio, String newTitle) async {
    if (newTitle.trim().isEmpty) {
      _setError('Name cannot be empty');
      return;
    }

    try {
      _setLoading(true);

      if (audio.id != null) {
        final rows = await _dbHelper.updateTitle(audio.id!, newTitle.trim());
        if (rows == 0) {
          throw Exception('Failed to update database');
        }
      }

      // Refresh local list from DB
      await fetchSavedAudios();
      _setSuccess('Audio renamed successfully');
    } catch (e) {
      _setError('Error renaming audio: $e');
    } finally {
      _setLoading(false);
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
