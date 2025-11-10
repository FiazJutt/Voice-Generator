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
  // {
  //   // ============ AURA 1 - English Voices ============
  //   'aura-asteria-en': {
  //     'displayName': 'Asteria',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Female',
  //     'properties': ['feminine', 'clear', 'confident', 'knowledgeable']
  //   },
  //   'aura-luna-en': {
  //     'displayName': 'Luna',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Female',
  //     'properties': ['feminine', 'friendly', 'natural', 'engaging']
  //   },
  //   'aura-stella-en': {
  //     'displayName': 'Stella',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Female',
  //     'properties': ['feminine', 'raspy', 'engaging', 'cheerful']
  //   },
  //   'aura-athena-en': {
  //     'displayName': 'Athena',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Female',
  //     'properties': ['feminine', 'smooth', 'calm', 'professional']
  //   },
  //   'aura-hera-en': {
  //     'displayName': 'Hera',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Female',
  //     'properties': ['feminine', 'deep', 'smooth', 'warm']
  //   },
  //   'aura-orion-en': {
  //     'displayName': 'Orion',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Male',
  //     'properties': ['masculine', 'approachable', 'comfortable', 'calm']
  //   },
  //   'aura-arcas-en': {
  //     'displayName': 'Arcas',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Male',
  //     'properties': ['masculine', 'natural', 'smooth', 'clear']
  //   },
  //   'aura-perseus-en': {
  //     'displayName': 'Perseus',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Male',
  //     'properties': ['masculine', 'expressive', 'melodic', 'charismatic']
  //   },
  //   'aura-angus-en': {
  //     'displayName': 'Angus',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Male',
  //     'properties': ['masculine', 'casual', 'friendly', 'patient']
  //   },
  //   'aura-orpheus-en': {
  //     'displayName': 'Orpheus',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Male',
  //     'properties': ['masculine', 'clear', 'trustworthy', 'professional']
  //   },
  //   'aura-helios-en': {
  //     'displayName': 'Helios',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Male',
  //     'properties': ['masculine', 'postive', 'comfortable', 'polite']
  //   },
  //   'aura-zeus-en': {
  //     'displayName': 'Zeus',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Male',
  //     'properties': ['masculine', 'deep', 'trustworthy', 'smooth']
  //   },

  //   // ============ AURA 2 - English Voices ============
  //   'aura-2-amalthea-en': {
  //     'displayName': 'Amalthea',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Female',
  //     'properties': ['feminine', 'engaging', 'natural', 'cheerful']
  //   },
  //   'aura-2-andromeda-en': {
  //     'displayName': 'Andromeda',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Female',
  //     'properties': ['feminine', 'casual', 'expressive', 'comfortable']
  //   },
  //   'aura-2-apollo-en': {
  //     'displayName': 'Apollo',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Male',
  //     'properties': ['masculine', 'confident', 'comfortable', 'casual']
  //   },
  //   'aura-2-arcas-en': {
  //     'displayName': 'Arcas 2',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Male',
  //     'properties': ['masculine', 'natural', 'smooth', 'clear', 'comfortable']
  //   },
  //   'aura-2-aries-en': {
  //     'displayName': 'Aries',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Male',
  //     'properties': ['masculine', 'warm', 'energetic', 'caring']
  //   },
  //   'aura-2-asteria-en': {
  //     'displayName': 'Asteria 2',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Female',
  //     'properties': ['feminine', 'clear', 'confident', 'knowledgeable', 'energetic']
  //   },
  //   'aura-2-athena-en': {
  //     'displayName': 'Athena 2',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Female',
  //     'properties': ['feminine', 'calm', 'smooth', 'professional']
  //   },
  //   'aura-2-atlas-en': {
  //     'displayName': 'Atlas',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Male',
  //     'properties': ['masculine', 'enthusiastic', 'confident', 'approachable', 'friendly']
  //   },
  //   'aura-2-aurora-en': {
  //     'displayName': 'Aurora',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Female',
  //     'properties': ['feminine', 'cheerful', 'expressive', 'energetic']
  //   },
  //   'aura-2-callista-en': {
  //     'displayName': 'Callista',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Female',
  //     'properties': ['feminine', 'clear', 'energetic', 'professional', 'smooth']
  //   },
  //   'aura-2-cordelia-en': {
  //     'displayName': 'Cordelia',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Female',
  //     'properties': ['feminine', 'approachable', 'warm', 'polite']
  //   },
  //   'aura-2-cora-en': {
  //     'displayName': 'Cora',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Female',
  //     'properties': ['feminine', 'smooth', 'melodic', 'caring']
  //   },
  //   'aura-2-delia-en': {
  //     'displayName': 'Delia',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Female',
  //     'properties': ['feminine', 'casual', 'friendly', 'cheerful', 'breathy']
  //   },
  //   'aura-2-draco-en': {
  //     'displayName': 'Draco',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Male',
  //     'properties': ['masculine', 'warm', 'approachable', 'trustworthy', 'baritone']
  //   },
  //   'aura-2-electra-en': {
  //     'displayName': 'Electra',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Female',
  //     'properties': ['feminine', 'professional', 'engaging', 'knowledgeable']
  //   },
  //   'aura-2-harmonia-en': {
  //     'displayName': 'Harmonia',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Female',
  //     'properties': ['feminine', 'empathetic', 'clear', 'calm', 'confident']
  //   },
  //   'aura-2-helena-en': {
  //     'displayName': 'Helena',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Female',
  //     'properties': ['feminine', 'caring', 'natural', 'positive', 'friendly', 'raspy']
  //   },
  //   'aura-2-hera-en': {
  //     'displayName': 'Hera 2',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Female',
  //     'properties': ['feminine', 'smooth', 'warm', 'professional']
  //   },
  //   'aura-2-hermes-en': {
  //     'displayName': 'Hermes',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Male',
  //     'properties': ['masculine', 'expressive', 'engaging', 'professional']
  //   },
  //   'aura-2-hyperion-en': {
  //     'displayName': 'Hyperion',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Male',
  //     'properties': ['masculine', 'caring', 'warm', 'empathetic']
  //   },
  //   'aura-2-iris-en': {
  //     'displayName': 'Iris',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Female',
  //     'properties': ['feminine', 'cheerful', 'positive', 'approachable']
  //   },
  //   'aura-2-janus-en': {
  //     'displayName': 'Janus',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Male',
  //     'properties': ['feminine', 'southern', 'smooth', 'trustworthy']
  //   },
  //   'aura-2-juno-en': {
  //     'displayName': 'Juno',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Female',
  //     'properties': ['feminine', 'natural', 'engaging', 'melodic', 'breathy']
  //   },
  //   'aura-2-jupiter-en': {
  //     'displayName': 'Jupiter',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Male',
  //     'properties': ['masculine', 'expressive', 'knowledgeable', 'baritone']
  //   },
  //   'aura-2-luna-en': {
  //     'displayName': 'Luna 2',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Female',
  //     'properties': ['feminine', 'friendly', 'natural', 'engaging']
  //   },
  //   'aura-2-mars-en': {
  //     'displayName': 'Mars',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Male',
  //     'properties': ['masculine', 'smooth', 'patient', 'trustworthy', 'baritone']
  //   },
  //   'aura-2-minerva-en': {
  //     'displayName': 'Minerva',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Female',
  //     'properties': ['feminine', 'positive', 'friendly', 'natural']
  //   },
  //   'aura-2-neptune-en': {
  //     'displayName': 'Neptune',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Male',
  //     'properties': ['masculine', 'professional', 'patient', 'polite']
  //   },
  //   'aura-2-odysseus-en': {
  //     'displayName': 'Odysseus',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Male',
  //     'properties': ['masculine', 'calm', 'smooth', 'comfortable', 'professional']
  //   },
  //   'aura-2-ophelia-en': {
  //     'displayName': 'Ophelia',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Female',
  //     'properties': ['feminine', 'expressive', 'enthusiastic', 'cheerful']
  //   },
  //   'aura-2-orion-en': {
  //     'displayName': 'Orion 2',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Male',
  //     'properties': ['masculine', 'approachable', 'comfortable', 'calm', 'polite']
  //   },
  //   'aura-2-orpheus-en': {
  //     'displayName': 'Orpheus 2',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Male',
  //     'properties': ['masculine', 'professional', 'clear', 'confident', 'trustworthy']
  //   },
  //   'aura-2-pandora-en': {
  //     'displayName': 'Pandora',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Female',
  //     'properties': ['feminine', 'smooth', 'calm', 'melodic', 'breathy']
  //   },
  //   'aura-2-phoebe-en': {
  //     'displayName': 'Phoebe',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Female',
  //     'properties': ['feminine', 'energetic', 'warm', 'casual']
  //   },
  //   'aura-2-pluto-en': {
  //     'displayName': 'Pluto',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Male',
  //     'properties': ['masculine', 'smooth', 'calm', 'empathetic', 'baritone']
  //   },
  //   'aura-2-saturn-en': {
  //     'displayName': 'Saturn',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Male',
  //     'properties': ['masculine', 'knowledgeable', 'confident', 'baritone']
  //   },
  //   'aura-2-selene-en': {
  //     'displayName': 'Selene',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Female',
  //     'properties': ['feminine', 'expressive', 'engaging', 'energetic']
  //   },
  //   'aura-2-thalia-en': {
  //     'displayName': 'Thalia',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Female',
  //     'properties': ['feminine', 'clear', 'confident', 'energetic', 'enthusiastic']
  //   },
  //   'aura-2-theia-en': {
  //     'displayName': 'Theia',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Female',
  //     'properties': ['feminine', 'expressive', 'polite', 'sincere']
  //   },
  //   'aura-2-vesta-en': {
  //     'displayName': 'Vesta',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Female',
  //     'properties': ['feminine', 'natural', 'expressive', 'patient', 'empathetic']
  //   },
  //   'aura-2-zeus-en': {
  //     'displayName': 'Zeus 2',
  //     'language': 'English',
  //     'region': 'American',
  //     'gender': 'Male',
  //     'properties': ['masculine', 'deep', 'trustworthy', 'smooth']
  //   },

  //   // ============ AURA 2 - Spanish Voices ============
  //   'aura-2-sirio-es': {
  //     'displayName': 'Sirio',
  //     'language': 'Spanish',
  //     'region': 'Español',
  //     'gender': 'Male',
  //     'properties': ['masculine', 'breathy', 'confident', 'energetic', 'professional', 'raspy']
  //   },
  //   'aura-2-nestor-es': {
  //     'displayName': 'Néstor',
  //     'language': 'Spanish',
  //     'region': 'Español',
  //     'gender': 'Male',
  //     'properties': ['masculine', 'calm', 'professional', 'approachable', 'clear', 'confident']
  //   },
  //   'aura-2-carina-es': {
  //     'displayName': 'Carina',
  //     'language': 'Spanish',
  //     'region': 'Español',
  //     'gender': 'Female',
  //     'properties': ['feminine', 'professional', 'raspy', 'energetic', 'breathy', 'confident']
  //   },
  //   'aura-2-celeste-es': {
  //     'displayName': 'Celeste',
  //     'language': 'Spanish',
  //     'region': 'Español',
  //     'gender': 'Female',
  //     'properties': ['feminine', 'clear', 'energetic', 'positive', 'friendly', 'enthusiastic']
  //   },
  //   'aura-2-alvaro-es': {
  //     'displayName': 'Álvaro',
  //     'language': 'Spanish',
  //     'region': 'Español',
  //     'gender': 'Male',
  //     'properties': ['masculine', 'calm', 'professional', 'clear', 'knowledgeable', 'approachable']
  //   },
  //   'aura-2-diana-es': {
  //     'displayName': 'Diana',
  //     'language': 'Spanish',
  //     'region': 'Español',
  //     'gender': 'Female',
  //     'properties': ['feminine', 'professional', 'confident', 'expressive', 'polite', 'knowledgeable']
  //   },
  //   'aura-2-aquila-es': {
  //     'displayName': 'Áquila',
  //     'language': 'Spanish',
  //     'region': 'Español',
  //     'gender': 'Female',
  //     'properties': ['masculine', 'casual', 'comfortable', 'confident', 'expressive', 'enthusiastic']
  //   },
  //   'aura-2-selena-es': {
  //     'displayName': 'Selena',
  //     'language': 'Spanish',
  //     'region': 'Español',
  //     'gender': 'Female',
  //     'properties': ['feminine', 'approachable', 'calm', 'casual', 'friendly', 'positive']
  //   },
  //   'aura-2-estrella-es': {
  //     'displayName': 'Estrella',
  //     'language': 'Spanish',
  //     'region': 'Español',
  //     'gender': 'Female',
  //     'properties': ['feminine', 'approachable', 'calm', 'comfortable', 'expressive', 'natural']
  //   },
  //   'aura-2-javier-es': {
  //     'displayName': 'Javier',
  //     'language': 'Spanish',
  //     'region': 'Español',
  //     'gender': 'Male',
  //     'properties': ['masculine', 'approachable', 'calm', 'comfortable', 'friendly', 'professional']
  //   },
  // };

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

      final audio = AudioModel(
        text: text,
        voice: voiceId,
        filePath: filePath,
        createdAt: DateTime.now(),
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
