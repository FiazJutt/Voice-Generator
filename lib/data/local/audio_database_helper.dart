import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../../model/audio_model.dart';

class AudioDatabaseHelper {
  static const _databaseName = 'audio_history.db';
  static const _databaseVersion = 1;
  static const table = 'audios';

  AudioDatabaseHelper._privateConstructor();
  static final AudioDatabaseHelper instance =
  AudioDatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    return await openDatabase(path, version: _databaseVersion,
        onCreate: (db, version) async {
          await db.execute('''
          CREATE TABLE $table(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            text TEXT NOT NULL,
            voice TEXT NOT NULL,
            filePath TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            displayName TEXT,
            language TEXT,
            region TEXT,
            gender TEXT,
            properties TEXT
          )
        ''');
        });
  }

  Future<int> insertAudio(AudioModel audio) async {
    final db = await database;
    return await db.insert(table, audio.toMap());
  }

  Future<List<AudioModel>> getAllAudios() async {
    final db = await database;
    final res = await db.query(table, orderBy: 'createdAt DESC');
    return res.map((e) => AudioModel.fromMap(e)).toList();
  }

  // In AudioDatabaseHelper class
  Future<int> deleteAudio(int id) async {
    final db = await database;
    return await db.delete(
      'audios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}