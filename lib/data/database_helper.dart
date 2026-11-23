import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/detection_record.dart';

/// Helper pengelolaan database lokal SQLite untuk riwayat diagnosis daun padi.
class DatabaseHelper {
  static const String _databaseName = 'cekpadi.db';
  static const int _databaseVersion = 1;

  static const String tableHistory = 'detection_history';
  static const String columnId = 'id';
  static const String columnLabelKey = 'label_key';
  static const String columnDiseaseName = 'disease_name';
  static const String columnConfidence = 'confidence';
  static const String columnIsLowConfidence = 'is_low_confidence';
  static const String columnSecondLabelKey = 'second_label_key';
  static const String columnSecondConfidence = 'second_confidence';
  static const String columnImagePath = 'image_path';
  static const String columnCreatedAt = 'created_at';

  // Notifier reaktif: memberitahu seluruh UI ketika data berubah tanpa perlu pull-to-refresh
  static final ValueNotifier<int> historyChangeNotifier = ValueNotifier<int>(0);

  static void _notifyChange() {
    historyChangeNotifier.value++;
  }

  // Singleton instance
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableHistory (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnLabelKey TEXT NOT NULL,
        $columnDiseaseName TEXT NOT NULL,
        $columnConfidence REAL NOT NULL,
        $columnIsLowConfidence INTEGER NOT NULL,
        $columnSecondLabelKey TEXT,
        $columnSecondConfidence REAL,
        $columnImagePath TEXT NOT NULL,
        $columnCreatedAt TEXT NOT NULL
      )
    ''');
  }

  /// Menyimpan hasil deteksi baru ke riwayat
  Future<int> insertRecord(DetectionRecord record) async {
    final Database db = await database;
    final int id = await db.insert(
      tableHistory,
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _notifyChange();
    return id;
  }

  /// Mengambil seluruh daftar riwayat (terbaru di atas)
  Future<List<DetectionRecord>> getAllRecords() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableHistory,
      orderBy: '$columnId DESC',
    );

    return maps.map((map) => DetectionRecord.fromMap(map)).toList();
  }

  /// Mengambil sejumlah n riwayat terbaru (untuk beranda)
  Future<List<DetectionRecord>> getRecentRecords({int limit = 3}) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableHistory,
      orderBy: '$columnId DESC',
      limit: limit,
    );

    return maps.map((map) => DetectionRecord.fromMap(map)).toList();
  }

  /// Menghitung total pemeriksaan yang pernah dilakukan
  Future<int> getRecordCount() async {
    final Database db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $tableHistory'),
    );
    return count ?? 0;
  }

  /// Mengambil record berdasarkan ID
  Future<DetectionRecord?> getRecordById(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableHistory,
      where: '$columnId = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return DetectionRecord.fromMap(maps.first);
    }
    return null;
  }

  /// Menghapus 1 record riwayat berdasarkan ID
  Future<int> deleteRecord(int id) async {
    final Database db = await database;
    final int deleted = await db.delete(
      tableHistory,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    _notifyChange();
    return deleted;
  }

  /// Menghapus seluruh riwayat
  Future<int> clearAllRecords() async {
    final Database db = await database;
    final int count = await db.delete(tableHistory);
    _notifyChange();
    return count;
  }

  /// Menutup koneksi database
  Future<void> close() async {
    final Database db = await database;
    await db.close();
    _database = null;
  }
}
