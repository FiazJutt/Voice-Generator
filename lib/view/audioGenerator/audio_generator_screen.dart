import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../viewmodel/audio_provider.dart';

class AudioGeneratorScreen extends StatefulWidget {
  const AudioGeneratorScreen({super.key});

  @override
  State<AudioGeneratorScreen> createState() => _AudioGeneratorScreenState();
}

class _AudioGeneratorScreenState extends State<AudioGeneratorScreen> {
  final TextEditingController _textController = TextEditingController();
  String? _selectedVoice;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final provider = Provider.of<AudioProvider>(context, listen: false);
      await provider.initDeepgram();
      await provider.fetchVoices();
      debugPrint('Voices: ${provider.voices}');
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data != null && data.text != null) {
      setState(() {
        _textController.text = data.text!;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Text pasted successfully!')),
      );
    }
  }

  Future<void> _generateAudio(BuildContext context) async {
    final provider = Provider.of<AudioProvider>(context, listen: false);
    final text = _textController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some text')),
      );
      return;
    }

    if (_selectedVoice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a voice')),
      );
      return;
    }

    await provider.generateAudio(text: text, voice: _selectedVoice!);

    if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error!)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio generated successfully!')),
      );
      Navigator.pop(context, true); // return to home to refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Generate Audio'),
        backgroundColor: AppColors.background,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your text',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: TextField(
                  controller: _textController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  maxLines: 5,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(12),
                    border: InputBorder.none,
                    hintText: 'Type or paste text here...',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _pasteFromClipboard,
                  icon: const Icon(Icons.paste),
                  label: const Text('Paste'),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Choose Voice',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                width: double.infinity,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    dropdownColor: AppColors.surface,
                    value: _selectedVoice,
                    hint: const Text(
                      'Select a voice',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    items: provider.voices.map((voice) {
                      return DropdownMenuItem<String>(
                        value: voice,
                        child: Text(
                          voice,
                          style: const TextStyle(
                              color: AppColors.textPrimary),
                        ),
                      );
                    }).toList(),
                    isExpanded: true,
                    onChanged: (value) {
                      setState(() {
                        _selectedVoice = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: provider.isLoading
                      ? null
                      : () => _generateAudio(context),
                  icon: provider.isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.graphic_eq),
                  label: Text(provider.isLoading
                      ? 'Generating...'
                      : 'Generate Audio'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              // Add bottom padding for better scrolling experience
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
