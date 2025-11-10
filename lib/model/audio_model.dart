class AudioModel {
  final int? id;
  final String text;
  final String voice;
  final String filePath;
  final DateTime createdAt;

  AudioModel({
    this.id,
    required this.text,
    required this.voice,
    required this.filePath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'voice': voice,
      'filePath': filePath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AudioModel.fromMap(Map<String, dynamic> map) {
    return AudioModel(
      id: map['id'],
      text: map['text'],
      voice: map['voice'],
      filePath: map['filePath'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
