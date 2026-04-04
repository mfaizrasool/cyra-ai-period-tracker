import 'package:cyra_ai_period_tracker/core/utils/date_utils.dart';
import 'package:cyra_ai_period_tracker/data/models/daily_log.dart';
import 'package:cyra_ai_period_tracker/data/models/period_log.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cyra_db.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(path, version: 1, onCreate: _createDB);
  }

  static const String _dbFileName = 'cyra_db.db';

  /// Closes the connection and deletes the database file. Next [database] access recreates empty tables.
  Future<void> closeAndDeleteDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbFileName);
    await deleteDatabase(path);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE period_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        flowLevel INTEGER NOT NULL,
        isPredicted INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        symptoms TEXT NOT NULL,
        mood TEXT NOT NULL,
        notes TEXT NOT NULL
      )
    ''');
  }

  /// One row per calendar day: replaces any existing row for that day.
  Future<PeriodLog> upsertPeriodLog(PeriodLog log) async {
    final db = await instance.database;
    final keyPrefix = dateKey(log.date);
    await db.delete(
      'period_logs',
      where: 'date LIKE ?',
      whereArgs: ['$keyPrefix%'],
    );
    final map = Map<String, dynamic>.from(log.toMap())..remove('id');
    final id = await db.insert('period_logs', map);
    return PeriodLog(
      id: id,
      date: dateOnly(log.date),
      flowLevel: log.flowLevel,
      isPredicted: log.isPredicted,
    );
  }

  Future<List<PeriodLog>> getAllPeriodLogs() async {
    final db = await instance.database;
    final result = await db.query('period_logs', orderBy: 'date ASC');
    return result.map(PeriodLog.fromMap).toList();
  }

  Future<void> deletePeriodLog(int id) async {
    final db = await instance.database;
    await db.delete('period_logs', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deletePeriodLogForDate(DateTime date) async {
    final db = await instance.database;
    final keyPrefix = dateKey(date);
    await db.delete(
      'period_logs',
      where: 'date LIKE ?',
      whereArgs: ['$keyPrefix%'],
    );
  }

  /// One row per calendar day: replaces any existing row for that day.
  Future<DailyLog> upsertDailyLog(DailyLog log) async {
    final db = await instance.database;
    final keyPrefix = dateKey(log.date);
    await db.delete(
      'daily_logs',
      where: 'date LIKE ?',
      whereArgs: ['$keyPrefix%'],
    );
    final normalized = DailyLog(
      date: dateOnly(log.date),
      symptoms: log.symptoms,
      mood: log.mood,
      notes: log.notes,
    );
    final map = normalized.toMap()..remove('id');
    final id = await db.insert('daily_logs', map);
    return DailyLog(
      id: id,
      date: normalized.date,
      symptoms: normalized.symptoms,
      mood: normalized.mood,
      notes: normalized.notes,
    );
  }

  Future<DailyLog?> getDailyLogForDate(DateTime date) async {
    final db = await instance.database;
    final keyPrefix = dateKey(date);
    final result = await db.query(
      'daily_logs',
      where: 'date LIKE ?',
      whereArgs: ['$keyPrefix%'],
      orderBy: 'id DESC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      return DailyLog.fromMap(result.first);
    }
    return null;
  }

  Future<List<DailyLog>> getAllDailyLogs() async {
    final db = await instance.database;
    final result = await db.query('daily_logs', orderBy: 'date ASC');
    return result.map(DailyLog.fromMap).toList();
  }
}
