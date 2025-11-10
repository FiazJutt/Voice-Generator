import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:deepgram_speech_to_text/deepgram_speech_to_text.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path;
import '../data/local/audio_database_helper.dart';
import '../model/audio_model.dart';

class AudioProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<AudioModel> _audios = [];
  List<String> _voices = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<AudioModel> get audios => _audios;
  List<String> get voices => _voices;

  final _dbHelper = AudioDatabaseHelper.instance;
  Deepgram? _deepgram;
  String? _apiKey;
  String? _successMessage;

  String? get successMessage => _successMessage;

  // A static list of supported voices/models
  static const List<String> _supportedVoices = [
    'aura-asteria-en', 'aura-luna-en', 'aura-stella-en', 'aura-athena-en',
    'aura-hera-en', 'aura-orion-en', 'aura-arcas-en', 'aura-perseus-en',
    'aura-angus-en', 'aura-orpheus-en', 'aura-helios-en', 'aura-zeus-en',
    'aura-2-amalthea-en', 'aura-2-andromeda-en', 'aura-2-apollo-en',
    'aura-2-arcas-en', 'aura-2-aries-en', 'aura-2-asteria-en',
    'aura-2-athena-en', 'aura-2-atlas-en', 'aura-2-aurora-en',
    'aura-2-callista-en', 'aura-2-cordelia-en', 'aura-2-cora-en',
    'aura-2-delia-en', 'aura-2-draco-en', 'aura-2-electra-en', 'aura-2-harmonia-en',
    'aura-2-helena-en', 'aura-2-harmonia-en', 'aura-2-helena-en',
    'aura-2-hera-en', 'aura-2-hermes-en', 'aura-2-hyperion-en',
    'aura-2-iris-en', 'aura-2-janus-en', 'aura-2-juno-en', 'aura-2-jupiter-en',
    'aura-2-luna-en', 'aura-2-mars-en', 'aura-2-minerva-en', 'aura-2-neptune-en',
    'aura-2-odysseus-en', 'aura-2-ophelia- en', 'aura-2-orion-en', 'aura-2-orpheus-en',
    'aura-2-pandora-en', 'aura-2-phoebe-en', 'aura-2-pluto-en', 'aura-2-saturn-en',
    'aura-2-selene-en', 'aura-2-thalia-en', 'aura-2-theia-en', 'aura-2-vesta-en',
    'aura-2-zeus-en', 'aura-2-sirio-es', 'aura-2-nestor-es', 'aura-2-carina-es',
    'aura-2-celeste-es', 'aura-2-alvaro-es', 'aura-2-diana-es',
    'aura-2-aquila-es', 'aura-2-selena-es',
    'aura-2-estrella-es', 'aura-2-javier-es'
  ];

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

  /// Fetch available voices (loads static list)
  Future<void> fetchVoices() async {
    try {
      _setLoading(true);
      _voices = List<String>.from(_supportedVoices);
      _error = null;
    } catch (e) {
      _setError('Error fetching voices: $e');
    } finally {
      _setLoading(false);
    }
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
    required String voice,
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

      // Make HTTP request to Deepgram TTS API
      final url = Uri.parse('https://api.deepgram.com/v1/speak?model=$voice');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Token $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'text': text,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to generate audio: ${response.statusCode} - ${response.body}');
      }

      // Save audio file locally
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${dir.path}/audio_$timestamp.mp3';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // Verify file was created
      if (!await file.exists()) {
        throw Exception('Failed to save audio file');
      }

      // Save to database
      final audio = AudioModel(
        text: text,
        voice: voice,
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

  /// Save audio to Android Downloads folder (user-visible)
  Future<void> saveAudioToDevice(AudioModel audio) async {
    final sourceFile = File(audio.filePath);
    if (!await sourceFile.exists()) {
      _setError('Audio file not found. Please regenerate.');
      return;
    }

    _setLoading(true);

    try {
      // Get the Downloads directory for Android
      Directory? downloadsDir;

      // Method 1: Try to get external storage Downloads directory
      try {
        if (Platform.isAndroid) {
          // Common paths for Downloads directory on Android
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
      } catch (e) {
        debugPrint('Error accessing standard Downloads paths: $e');
      }

      // Create unique filename with voice name and timestamp
      final voiceName = audio.voice.replaceAll('aura-', '').replaceAll('-en', '');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${voiceName}_voice_$timestamp.mp3';
      final newPath = path.join(downloadsDir!.path, fileName);

      // Copy file to Downloads directory
      final newFile = await sourceFile.copy(newPath);

      // Verify the file was created
      if (await newFile.exists()) {
        final fileSize = await newFile.length();
        debugPrint('File saved successfully at: ${newFile.path} (${fileSize} bytes)');

        // Determine if we saved to Downloads or fallback location
        final isInDownloads = newPath.contains('Download') || newPath.contains('download');
        final locationName = isInDownloads ? 'Downloads' : 'App Storage';

        _setSuccess('Audio saved to $locationName folder!\nFile: $fileName');

      } else {
        throw Exception('File was not created at $newPath');
      }
    } catch (e) {
      _setError('Error saving audio: ${e.toString()}');
      debugPrint('Error saving audio: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
    } finally {
      _setLoading(false);
    }
  }

  /// Share audio file to any platform (WhatsApp, Email, etc.)
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
      } else if (result.status == ShareResultStatus.dismissed) {
        debugPrint('Share dismissed by user');
      }
    } catch (e) {
      _setError('Error sharing audio: $e');
      debugPrint('Error sharing audio: $e');
    }
  }

  /// Delete audio from database and file system
  Future<void> deleteAudio(AudioModel audio) async {
    try {
      // Delete file if exists
      final file = File(audio.filePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Delete from database
      if (audio.id != null) {
        await _dbHelper.deleteAudio(audio.id!);
      }

      await fetchSavedAudios();
      _setSuccess('Audio deleted successfully');
    } catch (e) {
      _setError('Error deleting audio: $e');
    }
  }

  /// Play audio file
  Future<void> playAudio(AudioModel audio) async {
    final file = File(audio.filePath);
    if (!await file.exists()) {
      _setError('Audio file not found. Please regenerate.');
      return;
    }

    // You'll need to implement audio playback here
    // This could use packages like audioplayers, just_audio, etc.
    _setSuccess('Playing audio...');
    debugPrint('Audio file path: ${audio.filePath}');
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    _successMessage = null;
    notifyListeners();

    // Clear error after 5 seconds
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

    // Clear success message after 3 seconds
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
























// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:path/path.dart' as path;
// import '../data/local/audio_database_helper.dart';
// import '../model/audio_model.dart';
//
// class AudioProvider extends ChangeNotifier {
//   bool _isLoading = false;
//   String? _error;
//   List<AudioModel> _audios = [];
//   List<String> _voices = [];
//   Map<String, String> _voiceDetails = {}; // Store voice names with descriptions
//
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//   List<AudioModel> get audios => _audios;
//   List<String> get voices => _voices;
//   Map<String, String> get voiceDetails => _voiceDetails;
//
//   final _dbHelper = AudioDatabaseHelper.instance;
//   String? _apiKey;
//   String? _successMessage;
//
//   String? get successMessage => _successMessage;
//
//   /// Initialize Deepgram API Key
//   Future<void> initDeepgram() async {
//     _apiKey = dotenv.env['DEEPGRAM_API_KEY'];
//     if (_apiKey == null || _apiKey!.isEmpty) {
//       _setError("Deepgram API key missing in .env");
//       return;
//     }
//     _error = null;
//     notifyListeners();
//   }
//
//   /// Fetch available voices/models from Deepgram API
//   Future<void> fetchVoices() async {
//     if (_apiKey == null || _apiKey!.isEmpty) {
//       await initDeepgram();
//     }
//     if (_apiKey == null || _apiKey!.isEmpty) {
//       _setError("Deepgram API key not initialized");
//       return;
//     }
//
//     try {
//       _setLoading(true);
//
//       // Make HTTP request to Deepgram Models API
//       final url = Uri.parse('https://api.deepgram.com/v1/projects');
//
//       final response = await http.get(
//         url,
//         headers: {
//           'Authorization': 'Token $_apiKey',
//         },
//       );
//
//       if (response.statusCode != 200) {
//         // If projects endpoint fails, try the models endpoint directly
//         await _fetchModelsDirectly();
//         return;
//       }
//
//       // Parse the projects response to get models
//       final projectsData = jsonDecode(response.body);
//       if (projectsData['projects'] is List) {
//         final projects = projectsData['projects'] as List;
//         if (projects.isNotEmpty) {
//           final projectId = projects.first['project_id'];
//           await _fetchModelsForProject(projectId);
//         } else {
//           // Fallback to direct models fetch
//           await _fetchModelsDirectly();
//         }
//       } else {
//         // Fallback to direct models fetch
//         await _fetchModelsDirectly();
//       }
//     } catch (e) {
//       _setError('Error fetching voices: $e');
//       debugPrint('Error fetching voices: $e');
//
//       // Fallback to static list if API fails
//       _useFallbackVoices();
//     } finally {
//       _setLoading(false);
//     }
//   }
//
//   /// Fetch models directly from Deepgram models endpoint
//   Future<void> _fetchModelsDirectly() async {
//     try {
//       final url = Uri.parse('https://api.deepgram.com/v1/models');
//
//       final response = await http.get(
//         url,
//         headers: {
//           'Authorization': 'Token $_apiKey',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final modelsData = jsonDecode(response.body);
//         _parseModelsResponse(modelsData);
//       } else {
//         throw Exception('Failed to fetch models: ${response.statusCode}');
//       }
//     } catch (e) {
//       debugPrint('Error in _fetchModelsDirectly: $e');
//       throw e;
//     }
//   }
//
//   /// Fetch models for a specific project
//   Future<void> _fetchModelsForProject(String projectId) async {
//     try {
//       final url = Uri.parse('https://api.deepgram.com/v1/projects/$projectId/models');
//
//       final response = await http.get(
//         url,
//         headers: {
//           'Authorization': 'Token $_apiKey',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final modelsData = jsonDecode(response.body);
//         _parseModelsResponse(modelsData);
//       } else {
//         // Fallback to direct models fetch
//         await _fetchModelsDirectly();
//       }
//     } catch (e) {
//       debugPrint('Error in _fetchModelsForProject: $e');
//       // Fallback to direct models fetch
//       await _fetchModelsDirectly();
//     }
//   }
//
//   /// Parse the models response and update voices list
//   void _parseModelsResponse(Map<String, dynamic> modelsData) {
//     final List<String> fetchedVoices = [];
//     final Map<String, String> voiceDetails = {};
//
//     if (modelsData['models'] is List) {
//       final models = modelsData['models'] as List;
//
//       for (final model in models) {
//         if (model is Map<String, dynamic>) {
//           final modelName = model['name']?.toString();
//           final modelDescription = model['description']?.toString() ?? modelName ?? 'Unknown voice';
//
//           if (modelName != null && modelName.isNotEmpty) {
//             // Filter for TTS models (you might want to adjust this filter)
//             if (_isTtsModel(modelName)) {
//               fetchedVoices.add(modelName);
//               voiceDetails[modelName] = modelDescription;
//             }
//           }
//         }
//       }
//     }
//
//     if (fetchedVoices.isNotEmpty) {
//       _voices = fetchedVoices;
//       _voiceDetails = voiceDetails;
//       _error = null;
//       debugPrint('Successfully fetched ${_voices.length} voices from Deepgram API');
//     } else {
//       // If no voices found, use fallback
//       throw Exception('No TTS voices found in API response');
//     }
//
//     notifyListeners();
//   }
//
//   /// Check if a model is a TTS model
//   bool _isTtsModel(String modelName) {
//     // Deepgram TTS models typically include 'aura' in the name
//     // You can adjust this filter based on Deepgram's naming conventions
//     return modelName.toLowerCase().contains('aura') ||
//         modelName.toLowerCase().contains('speak') ||
//         modelName.toLowerCase().contains('tts');
//   }
//
//   /// Use fallback voices if API fails
//   void _useFallbackVoices() {
//     _voices = [
//       'aura-asteria-en',
//       'aura-luna-en',
//       'aura-stella-en',
//       'aura-athena-en',
//       'aura-hera-en',
//       'aura-orion-en',
//       'aura-arcas-en',
//       'aura-perseus-en',
//       'aura-angus-en',
//       'aura-orpheus-en',
//       'aura-helios-en',
//       'aura-zeus-en',
//     ];
//
//     // Add descriptions for fallback voices
//     _voiceDetails = {
//       'aura-asteria-en': 'Asteria - Female voice',
//       'aura-luna-en': 'Luna - Female voice',
//       'aura-stella-en': 'Stella - Female voice',
//       'aura-athena-en': 'Athena - Female voice',
//       'aura-hera-en': 'Hera - Female voice',
//       'aura-orion-en': 'Orion - Male voice',
//       'aura-arcas-en': 'Arcas - Male voice',
//       'aura-perseus-en': 'Perseus - Male voice',
//       'aura-angus-en': 'Angus - Male voice',
//       'aura-orpheus-en': 'Orpheus - Male voice',
//       'aura-helios-en': 'Helios - Male voice',
//       'aura-zeus-en': 'Zeus - Male voice',
//     };
//
//     debugPrint('Using fallback voices list');
//     notifyListeners();
//   }
//
//   /// Get voice description for display
//   String getVoiceDescription(String voice) {
//     return _voiceDetails[voice] ?? voice;
//   }
//
//   Future<void> fetchSavedAudios() async {
//     try {
//       _audios = await _dbHelper.getAllAudios();
//       notifyListeners();
//     } catch (e) {
//       _setError('Error fetching saved audios: $e');
//     }
//   }
//
//   /// Generate speech from text using Deepgram TTS API
//   Future<void> generateAudio({
//     required String text,
//     required String voice,
//   }) async {
//     if (_apiKey == null || _apiKey!.isEmpty) {
//       await initDeepgram();
//     }
//     if (_apiKey == null || _apiKey!.isEmpty) {
//       _setError("Deepgram API key not initialized");
//       return;
//     }
//
//     if (text.trim().isEmpty) {
//       _setError("Please enter some text to generate audio");
//       return;
//     }
//
//     // Validate that the selected voice is available
//     if (!_voices.contains(voice)) {
//       _setError("Selected voice is not available. Please refresh voices.");
//       return;
//     }
//
//     try {
//       _setLoading(true);
//
//       // Make HTTP request to Deepgram TTS API
//       final url = Uri.parse('https://api.deepgram.com/v1/speak?model=$voice');
//
//       final response = await http.post(
//         url,
//         headers: {
//           'Authorization': 'Token $_apiKey',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           'text': text,
//         }),
//       );
//
//       if (response.statusCode != 200) {
//         throw Exception('Failed to generate audio: ${response.statusCode} - ${response.body}');
//       }
//
//       // Save audio file locally
//       final dir = await getApplicationDocumentsDirectory();
//       final timestamp = DateTime.now().millisecondsSinceEpoch;
//       final fileName = 'audio_$timestamp.mp3';
//       final filePath = '${dir.path}/$fileName';
//       final file = File(filePath);
//       await file.writeAsBytes(response.bodyBytes);
//
//       // Verify file was created
//       if (!await file.exists()) {
//         throw Exception('Failed to save audio file');
//       }
//
//       // Save to database
//       final audio = AudioModel(
//         text: text,
//         voice: voice,
//         filePath: filePath,
//         createdAt: DateTime.now(),
//       );
//
//       final id = await _dbHelper.insertAudio(audio);
//       if (id == 0) {
//         throw Exception('Failed to save audio to database');
//       }
//
//       await fetchSavedAudios();
//       _setSuccess('Audio generated successfully using ${getVoiceDescription(voice)}!');
//     } catch (e) {
//       _setError('Error generating audio: $e');
//       debugPrint('Error generating audio: $e');
//     } finally {
//       _setLoading(false);
//     }
//   }
//
//   /// Save audio to Android Downloads folder
//   Future<void> saveAudioToDevice(AudioModel audio) async {
//     final sourceFile = File(audio.filePath);
//     if (!await sourceFile.exists()) {
//       _setError('Audio file not found. Please regenerate.');
//       return;
//     }
//
//     _setLoading(true);
//
//     try {
//       Directory? downloadsDir;
//
//       // Try to get Downloads directory
//       try {
//         if (Platform.isAndroid) {
//           final possiblePaths = [
//             '/storage/emulated/0/Download',
//             '/sdcard/Download',
//             '/storage/sdcard0/Download',
//           ];
//
//           for (final possiblePath in possiblePaths) {
//             downloadsDir = Directory(possiblePath);
//             if (await downloadsDir.exists()) {
//               break;
//             }
//           }
//         }
//       } catch (e) {
//         debugPrint('Error accessing Downloads paths: $e');
//       }
//
//       // Fallback to external storage
//       if (downloadsDir == null || !await downloadsDir.exists()) {
//         try {
//           final externalDir = await getExternalStorageDirectory();
//           if (externalDir != null) {
//             downloadsDir = Directory(path.join(externalDir.parent.path, 'Download'));
//             if (!await downloadsDir.exists()) {
//               await downloadsDir.create(recursive: true);
//             }
//           }
//         } catch (e) {
//           debugPrint('Error using getExternalStorageDirectory: $e');
//         }
//       }
//
//       // Final fallback to app documents
//       if (downloadsDir == null || !await downloadsDir.exists()) {
//         downloadsDir = await getApplicationDocumentsDirectory();
//       }
//
//       // Create filename with voice name
//       final voiceName = audio.voice.replaceAll('aura-', '').replaceAll('-en', '');
//       final timestamp = DateTime.now().millisecondsSinceEpoch;
//       final fileName = '${voiceName}_voice_$timestamp.mp3';
//       final newPath = path.join(downloadsDir.path, fileName);
//
//       // Copy file
//       final newFile = await sourceFile.copy(newPath);
//
//       if (await newFile.exists()) {
//         final isInDownloads = newPath.contains('Download') || newPath.contains('download');
//         final locationName = isInDownloads ? 'Downloads' : 'App Storage';
//
//         _setSuccess('Audio saved to $locationName folder!\nFile: $fileName');
//       } else {
//         throw Exception('File was not created at $newPath');
//       }
//     } catch (e) {
//       _setError('Error saving audio: ${e.toString()}');
//       debugPrint('Error saving audio: $e');
//     } finally {
//       _setLoading(false);
//     }
//   }
//
//   /// Share audio file
//   Future<void> shareAudio(AudioModel audio) async {
//     final file = File(audio.filePath);
//     if (!await file.exists()) {
//       _setError('Audio file not found. Please regenerate.');
//       return;
//     }
//
//     try {
//       final xFile = XFile(audio.filePath, mimeType: 'audio/mpeg');
//       final result = await Share.shareXFiles(
//         [xFile],
//         text: 'Generated audio: ${audio.text}',
//         subject: 'Voice: ${getVoiceDescription(audio.voice)}',
//       );
//
//       if (result.status == ShareResultStatus.success) {
//         _setSuccess('Audio shared successfully!');
//       }
//     } catch (e) {
//       _setError('Error sharing audio: $e');
//     }
//   }
//
//   /// Delete audio from database and file system
//   Future<void> deleteAudio(AudioModel audio) async {
//     try {
//       final file = File(audio.filePath);
//       if (await file.exists()) {
//         await file.delete();
//       }
//
//       if (audio.id != null) {
//         await _dbHelper.deleteAudio(audio.id!);
//       }
//
//       await fetchSavedAudios();
//       _setSuccess('Audio deleted successfully');
//     } catch (e) {
//       _setError('Error deleting audio: $e');
//     }
//   }
//
//   void _setLoading(bool value) {
//     _isLoading = value;
//     notifyListeners();
//   }
//
//   void _setError(String message) {
//     _error = message;
//     _successMessage = null;
//     notifyListeners();
//
//     Future.delayed(const Duration(seconds: 5), () {
//       if (_error == message) {
//         _error = null;
//         notifyListeners();
//       }
//     });
//   }
//
//   void _setSuccess(String message) {
//     _successMessage = message;
//     _error = null;
//     notifyListeners();
//
//     Future.delayed(const Duration(seconds: 3), () {
//       if (_successMessage == message) {
//         _successMessage = null;
//         notifyListeners();
//       }
//     });
//   }
//
//   void clearMessages() {
//     _error = null;
//     _successMessage = null;
//     notifyListeners();
//   }
// }























