class AudioModel {
  final int? id;
  final String text;
  final String voice; // This is the model ID (e.g., 'aura-asteria-en')
  final String filePath;
  final DateTime createdAt;
  final String? title; // user-visible mutable name for the audio (used for download/share/rename)
  
  // Voice metadata
  final String? displayName;
  final String? language;
  final String? region;
  final String? gender;
  final List<String>? properties;

  AudioModel({
    this.id,
    required this.text,
    required this.voice,
    required this.filePath,
    required this.createdAt,
    this.displayName,
    this.title,
    this.language,
    this.region,
    this.gender,
    this.properties,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'voice': voice,
      'filePath': filePath,
      'createdAt': createdAt.toIso8601String(),
      'title': title,
      'displayName': displayName,
      'language': language,
      'region': region,
      'gender': gender,
      'properties': properties?.join(','), // Store as comma-separated string
    };
  }

  factory AudioModel.fromMap(Map<String, dynamic> map) {
    return AudioModel(
      id: map['id'],
      text: map['text'],
      voice: map['voice'],
      filePath: map['filePath'],
      createdAt: DateTime.parse(map['createdAt']),
      displayName: map['displayName'],
      title: map['title'],
      language: map['language'],
      region: map['region'],
      gender: map['gender'],
      properties: map['properties'] != null 
          ? (map['properties'] as String).split(',')
          : null,
    );
  }
}
