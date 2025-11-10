// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:voicegenerator/core/theme/app_colors.dart';
// import 'package:voicegenerator/model/audio_model.dart';
// import 'package:voicegenerator/viewmodel/audio_player_provider.dart';

// class AudioListWidget extends StatefulWidget {
//   final List<AudioModel> audioList;
//   final void Function(AudioModel audio, int index)? onMoreOptions;

//   const AudioListWidget(List<AudioModel> audios, {
//     Key? key,
//     required this.audioList,
//     this.onMoreOptions,
//   }) : super(key: key);

//   @override
//   State<AudioListWidget> createState() => _AudioListWidgetState();
// }

// class _AudioListWidgetState extends State<AudioListWidget> {
//   int? _playingIndex;

//   Future<void> _togglePlayPause(
//       BuildContext context, int index, String filePath) async {
//     final player = Provider.of<AudioPlayerProvider>(context, listen: false);

//     if (!File(filePath).existsSync()) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Audio file not found')),
//       );
//       return;
//     }

//     // Stop currently playing audio if different
//     if (_playingIndex != null && _playingIndex != index) {
//       await player.stopAudio();
//     }

//     // Toggle current
//     if (_playingIndex == index) {
//       if (player.isPlaying) {
//         await player.pauseAudio();
//       } else {
//         await player.resumeAudio();
//       }
//     } else {
//       await player.initAudio(filePath);
//       await player.playAudio(filePath);
//       setState(() => _playingIndex = index);
//     }

//     setState(() {}); // rebuild play icons
//   }

//   @override
//   Widget build(BuildContext context) {
//     final player = Provider.of<AudioPlayerProvider>(context);

//     return ListView.separated(
//       physics: const BouncingScrollPhysics(),
//       itemCount: widget.audioList.length,
//       separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.grey),
//       itemBuilder: (context, index) {
//         final audio = widget.audioList[index];
//         final isPlaying = _playingIndex == index && player.isPlaying;

//         return ListTile(
//           contentPadding:
//               const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//           leading: CircleAvatar(
//             backgroundColor: AppColors.primary.withOpacity(0.2),
//             child: Icon(
//               isPlaying ? Icons.graphic_eq : Icons.audiotrack,
//               color: AppColors.primary,
//             ),
//           ),
//           title: Text(
//             audio.text,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           subtitle: Text(
//             File(audio.filePath).path.split('/').last,
//             overflow: TextOverflow.ellipsis,
//             style: const TextStyle(color: Colors.grey),
//           ),
//           trailing: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               IconButton(
//                 icon: Icon(
//                   isPlaying
//                       ? Icons.pause_circle_filled_rounded
//                       : Icons.play_circle_filled_rounded,
//                   color: AppColors.primary,
//                   size: 32,
//                 ),
//                 onPressed: () =>
//                     _togglePlayPause(context, index, audio.filePath),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.more_vert_rounded),
//                 color: AppColors.icon,
//                 onPressed: () =>
//                     widget.onMoreOptions?.call(audio, index),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
