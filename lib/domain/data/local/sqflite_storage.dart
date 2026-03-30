import 'dart:convert';
import 'dart:io';

import 'package:my_appp/domain/data/local/local_storage.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// [LocalStorage] implementation backed by SQLite via sqflite.
///
/// Stores key-value pairs in a single table where values are
/// JSON-encoded strings.
class SqfliteStorage implements LocalStorage {
  /// Creates a new [SqfliteStorage] with the given [databaseName].
  ///
  /// The [databaseName] determines the SQLite file on disk.
  SqfliteStorage({this.databaseName = 'app_storage.db'});

  /// Name of the SQLite database file.
  final String databaseName;

  static const String _tableName = 'storage';

  Database? _db;

  Database get _database {
    if (_db == null) {
      throw StateError(
        'Database not initialized. Call init() before performing operations.',
      );
    }
    return _db!;
  }

  @override
  Future<void> init() async {
    if (Platform.isLinux) {
      return;
    }
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, databaseName);

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
    );
  }

  @override
  Future<void> put(String key, Map<String, dynamic> value) async {
    final jsonString = jsonEncode(value);
    await _database.insert(
      _tableName,
      {'key': key, 'value': jsonString},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<Map<String, dynamic>?> get(String key) async {
    final result = await _database.query(
      _tableName,
      where: 'key = ?',
      whereArgs: [key],
    );

    if (result.isEmpty) return null;

    final jsonString = result.first['value']! as String;
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> getAll() async {
    final result = await _database.query(_tableName);

    return result.map((row) {
      final jsonString = row['value']! as String;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    }).toList();
  }

  @override
  Future<void> delete(String key) async {
    await _database.delete(
      _tableName,
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  @override
  Future<void> clear() async {
    await _database.delete(_tableName);
  }
}
