import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodel/audio_provider.dart';

class AudioGeneratorScreen extends StatefulWidget {
  const AudioGeneratorScreen({super.key});

  @override
  State<AudioGeneratorScreen> createState() => _AudioGeneratorScreenState();
}

class _AudioGeneratorScreenState extends State<AudioGeneratorScreen> {
  final TextEditingController _textController = TextEditingController();
  String? _selectedLanguage;
  Map<String, dynamic>? _selectedVoice;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final provider = Provider.of<AudioProvider>(context, listen: false);
      await provider.initDeepgram();
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter some text')));
      return;
    }

    if (_selectedLanguage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a language')));
      return;
    }

    if (_selectedVoice == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a voice')));
      return;
    }

    await provider.generateAudio(text: text, voiceId: _selectedVoice!['id']);

    if (provider.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.error!)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio generated successfully!')),
      );
      Navigator.pop(context, true);
    }
  }

  Widget _buildVoiceCard(Map<String, dynamic> voice) {
    final isSelected = _selectedVoice?['id'] == voice['id'];
    final displayName = voice['displayName'] as String;
    final region = voice['region'] as String;
    final gender = voice['gender'] as String;
    final properties = List<String>.from(voice['properties']);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedVoice = voice;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Gender icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.2)
                    // : AppColors.divider.withOpacity(0.3),
                    : gender == 'Male'
                        ? Colors.blue.withOpacity(0.2)
                        : Colors.pink.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                gender == 'Male' ? Icons.male : Icons.female,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Voice details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          displayName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: gender == 'Male'
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.pink.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          gender,
                          style: TextStyle(
                            fontSize: 11,
                            color: gender == 'Male'
                                ? Colors.blue[700]
                                : Colors.pink[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    region,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: properties.map((prop) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.15)
                              : AppColors.divider.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          prop,
                          style: TextStyle(
                            fontSize: 11,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Selection indicator
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioProvider>();
    final availableLanguages = provider.availableLanguages;
    final voicesByLanguage = _selectedLanguage != null
        ? provider.getVoicesByLanguage(_selectedLanguage!)
        : <Map<String, dynamic>>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Generate Audio'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text input section
                  const Text(
                    'Enter your text',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
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
                    child: OutlinedButton.icon(
                      onPressed: _pasteFromClipboard,
                      icon: const Icon(Icons.paste, size: 18),
                      label: const Text('Paste'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Language selection
                  const Text(
                    'Select Language',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
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
                        value: _selectedLanguage,
                        hint: const Text(
                          'Choose a language',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        items: availableLanguages.map((language) {
                          return DropdownMenuItem<String>(
                            value: language,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.language,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  language,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        isExpanded: true,
                        onChanged: (value) {
                          setState(() {
                            _selectedLanguage = value;
                            _selectedVoice = null; // Reset voice selection
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Voice selection
                  if (_selectedLanguage != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Choose Voice',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${voicesByLanguage.length} voices available',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Voice cards list — make only this section scrollable by
                    // constraining it with Expanded + ListView so the rest of the
                    // page remains fixed.
                    if (voicesByLanguage.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: const Text(
                          'No voices available for the selected language',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: voicesByLanguage.length,
                          itemBuilder: (context, index) {
                            final voice = voicesByLanguage[index];
                            return _buildVoiceCard(voice);
                          },
                        ),
                      ),
                  ],

                  const SizedBox(height: 8),

                  // Generate button
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
                      label: Text(
                        provider.isLoading ? 'Generating...' : 'Generate Audio',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  // const SizedBox(height: 8),
                ],
              ),
            ),
    );
  }
}



















// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import '../../core/theme/app_colors.dart';
// import '../../viewmodel/audio_provider.dart';

// class AudioGeneratorScreen extends StatefulWidget {
//   const AudioGeneratorScreen({super.key});

//   @override
//   State<AudioGeneratorScreen> createState() => _AudioGeneratorScreenState();
// }

// class _AudioGeneratorScreenState extends State<AudioGeneratorScreen> {
//   final TextEditingController _textController = TextEditingController();
//   String? _selectedLanguage;
//   String? _selectedVoiceId; // Changed to String ID instead of Map

//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() async {
//       final provider = Provider.of<AudioProvider>(context, listen: false);
//       await provider.initDeepgram();
//     });
//   }

//   @override
//   void dispose() {
//     _textController.dispose();
//     super.dispose();
//   }

//   Future<void> _pasteFromClipboard() async {
//     final data = await Clipboard.getData('text/plain');
//     if (data != null && data.text != null) {
//       setState(() {
//         _textController.text = data.text!;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Text pasted successfully!')),
//       );
//     }
//   }

//   Future<void> _generateAudio(BuildContext context) async {
//     final provider = Provider.of<AudioProvider>(context, listen: false);
//     final text = _textController.text.trim();

//     if (text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter some text')),
//       );
//       return;
//     }

//     if (_selectedLanguage == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a language')),
//       );
//       return;
//     }

//     if (_selectedVoiceId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a voice')),
//       );
//       return;
//     }

//     await provider.generateAudio(text: text, voiceId: _selectedVoiceId!);

//     if (provider.error != null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(provider.error!)),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Audio generated successfully!')),
//       );
//       Navigator.pop(context, true);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<AudioProvider>();
//     final availableLanguages = provider.availableLanguages;
//     final voicesByLanguage = _selectedLanguage != null
//         ? provider.getVoicesByLanguage(_selectedLanguage!)
//         : <Map<String, dynamic>>[];

//     // Get selected voice details
//     Map<String, dynamic>? selectedVoiceDetails;
//     if (_selectedVoiceId != null) {
//       selectedVoiceDetails = voicesByLanguage.firstWhere(
//             (voice) => voice['id'] == _selectedVoiceId,
//         orElse: () => {},
//       );
//       if (selectedVoiceDetails.isEmpty) {
//         selectedVoiceDetails = null;
//       }
//     }

//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: const Text('Generate Audio'),
//         backgroundColor: AppColors.background,
//         elevation: 0,
//       ),
//       body: provider.isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Text input section
//               const Text(
//                 'Enter your text',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Container(
//                 decoration: BoxDecoration(
//                   color: AppColors.surface,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: AppColors.divider),
//                 ),
//                 child: TextField(
//                   controller: _textController,
//                   style: const TextStyle(color: AppColors.textPrimary),
//                   maxLines: 5,
//                   decoration: const InputDecoration(
//                     contentPadding: EdgeInsets.all(12),
//                     border: InputBorder.none,
//                     hintText: 'Type or paste text here...',
//                     hintStyle: TextStyle(color: AppColors.textSecondary),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: OutlinedButton.icon(
//                   onPressed: _pasteFromClipboard,
//                   icon: const Icon(Icons.paste, size: 18),
//                   label: const Text('Paste'),
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: AppColors.primary,
//                     side: const BorderSide(color: AppColors.primary),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // Language selection
//               const Text(
//                 'Select Language',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: AppColors.surface,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: AppColors.divider),
//                 ),
//                 width: double.infinity,
//                 child: DropdownButtonHideUnderline(
//                   child: DropdownButton<String>(
//                     dropdownColor: AppColors.surface,
//                     value: _selectedLanguage,
//                     hint: const Text(
//                       'Choose a language',
//                       style: TextStyle(color: AppColors.textSecondary),
//                     ),
//                     items: availableLanguages.map((language) {
//                       return DropdownMenuItem<String>(
//                         value: language,
//                         child: Row(
//                           children: [
//                             const Icon(
//                               Icons.language,
//                               color: AppColors.primary,
//                               size: 20,
//                             ),
//                             const SizedBox(width: 12),
//                             Text(
//                               language,
//                               style: const TextStyle(
//                                 color: AppColors.textPrimary,
//                                 fontWeight: FontWeight.w500,
//                                 fontSize: 15,
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     }).toList(),
//                     isExpanded: true,
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedLanguage = value;
//                         _selectedVoiceId = null; // Reset voice selection
//                       });
//                     },
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // Voice selection dropdown
//               if (_selectedLanguage != null) ...[
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       'Choose Voice',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: AppColors.textPrimary,
//                       ),
//                     ),
//                     Text(
//                       '${voicesByLanguage.length} available',
//                       style: const TextStyle(
//                         fontSize: 12,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: AppColors.surface,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: AppColors.divider),
//                   ),
//                   width: double.infinity,
//                   child: DropdownButtonHideUnderline(
//                     child: DropdownButton<String>(
//                       dropdownColor: AppColors.surface,
//                       value: _selectedVoiceId,
//                       hint: const Text(
//                         'Select a voice',
//                         style: TextStyle(color: AppColors.textSecondary),
//                       ),
//                       itemHeight: 60, // taller items for touch
//                       menuMaxHeight: 320, // max dropdown height
//                       items: voicesByLanguage.map((voice) {
//                         final voiceId = voice['id'] as String;
//                         final displayName = voice['displayName'] as String;
//                         final gender = voice['gender'] as String;
//                         final region = voice['region'] as String;
//                         final properties = (voice['properties'] as List<dynamic>).join(', ');
                        
//                         return DropdownMenuItem<String>(
//                           value: voiceId,
//                           child: Row(
//                             children: [
//                               Icon(
//                                 gender == 'Male' ? Icons.male : Icons.female,
//                                 color: gender == 'Male'
//                                     ? Colors.blue[600]
//                                     : Colors.pink[600],
//                                 size: 20,
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Text(
//                                       '$displayName - $region',
//                                       style: const TextStyle(
//                                         color: AppColors.textPrimary,
//                                         fontWeight: FontWeight.w600,
//                                         fontSize: 15,
//                                       ),
//                                     ),
//                                     Text(
//                                       properties,
//                                       style: const TextStyle(
//                                         color: AppColors.textSecondary,
//                                         fontSize: 11,
//                                       ),
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       }).toList(),
//                       isExpanded: true,
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedVoiceId = value;
//                         });
//                       },
//                     ),
//                   ),
//                 ),

//                 // Show selected voice details
//                 if (selectedVoiceDetails != null) ...[
//                   const SizedBox(height: 16),
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: AppColors.primary.withOpacity(0.08),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: AppColors.primary.withOpacity(0.3),
//                       ),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.record_voice_over,
//                               color: AppColors.primary,
//                               size: 20,
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               'Voice Details',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w600,
//                                 color: AppColors.primary,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//                         Row(
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 10,
//                                 vertical: 4,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: (selectedVoiceDetails['gender'] == 'Male'
//                                     ? Colors.blue
//                                     : Colors.pink)
//                                     .withOpacity(0.15),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Icon(
//                                     selectedVoiceDetails['gender'] == 'Male'
//                                         ? Icons.male
//                                         : Icons.female,
//                                     size: 14,
//                                     color: selectedVoiceDetails['gender'] == 'Male'
//                                         ? Colors.blue[700]
//                                         : Colors.pink[700],
//                                   ),
//                                   const SizedBox(width: 4),
//                                   Text(
//                                     selectedVoiceDetails['gender'],
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w500,
//                                       color: selectedVoiceDetails['gender'] == 'Male'
//                                           ? Colors.blue[700]
//                                           : Colors.pink[700],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 10,
//                                 vertical: 4,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: AppColors.primary.withOpacity(0.15),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Icon(
//                                     Icons.public,
//                                     size: 14,
//                                     color: AppColors.primary,
//                                   ),
//                                   const SizedBox(width: 4),
//                                   Text(
//                                     selectedVoiceDetails['region'],
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w500,
//                                       color: AppColors.primary,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//                         const Text(
//                           'Properties:',
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600,
//                             color: AppColors.textSecondary,
//                           ),
//                         ),
//                         const SizedBox(height: 6),
//                         Wrap(
//                           spacing: 6,
//                           runSpacing: 6,
//                           children: (List<String>.from(selectedVoiceDetails['properties']))
//                               .map((prop) {
//                             return Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 10,
//                                 vertical: 5,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: AppColors.surface,
//                                 borderRadius: BorderRadius.circular(8),
//                                 border: Border.all(
//                                   color: AppColors.primary.withOpacity(0.3),
//                                 ),
//                               ),
//                               child: Text(
//                                 prop,
//                                 style: const TextStyle(
//                                   fontSize: 12,
//                                   color: AppColors.textPrimary,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             );
//                           }).toList(),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ],

//               const SizedBox(height: 32),

//               // Generate button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   onPressed: provider.isLoading
//                       ? null
//                       : () => _generateAudio(context),
//                   icon: provider.isLoading
//                       ? const SizedBox(
//                     height: 20,
//                     width: 20,
//                     child: CircularProgressIndicator(
//                       color: Colors.white,
//                       strokeWidth: 2,
//                     ),
//                   )
//                       : const Icon(Icons.graphic_eq),
//                   label: Text(
//                     provider.isLoading
//                         ? 'Generating...'
//                         : 'Generate Audio',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 0,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }