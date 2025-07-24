import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/affirmation.dart';
import '../models/notification_settings.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'affirmations.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE affirmations(
        id TEXT PRIMARY KEY,
        text TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE notification_settings(
        id INTEGER PRIMARY KEY,
        isEnabled INTEGER NOT NULL DEFAULT 1,
        reminderTimes TEXT NOT NULL DEFAULT '9,15,21',
        frequency INTEGER NOT NULL DEFAULT 3,
        randomOrder INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Insert default notification settings
    await db.insert('notification_settings', {
      'id': 1,
      'isEnabled': 1,
      'reminderTimes': '9,15,21',
      'frequency': 3,
      'randomOrder': 1,
    });
  }

  // Affirmation CRUD operations
  Future<int> insertAffirmation(Affirmation affirmation) async {
    final db = await database;
    return await db.insert('affirmations', affirmation.toMap());
  }

  Future<List<Affirmation>> getAllAffirmations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'affirmations',
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => Affirmation.fromMap(maps[i]));
  }

  Future<List<Affirmation>> getActiveAffirmations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'affirmations',
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => Affirmation.fromMap(maps[i]));
  }

  Future<int> updateAffirmation(Affirmation affirmation) async {
    final db = await database;
    return await db.update(
      'affirmations',
      affirmation.toMap(),
      where: 'id = ?',
      whereArgs: [affirmation.id],
    );
  }

  Future<int> deleteAffirmation(String id) async {
    final db = await database;
    return await db.delete(
      'affirmations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Notification settings operations
  Future<NotificationSettings> getNotificationSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notification_settings',
      where: 'id = ?',
      whereArgs: [1],
    );
    
    if (maps.isNotEmpty) {
      return NotificationSettings.fromMap(maps.first);
    } else {
      // Return default settings if none exist
      return NotificationSettings();
    }
  }

  Future<int> updateNotificationSettings(NotificationSettings settings) async {
    final db = await database;
    return await db.update(
      'notification_settings',
      settings.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
  }
}
