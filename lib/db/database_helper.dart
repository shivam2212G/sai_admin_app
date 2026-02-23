import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._init();

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('user.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user(
        user_id INTEGER PRIMARY KEY,
        full_name TEXT,
        mobile_number TEXT,
        email TEXT,
        token TEXT
      )
    ''');
  }

  Future<void> insertUser(Map<String, dynamic> userData) async {
    final db = await instance.database;
    await db.insert('user', userData,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getUser() async {
    final db = await instance.database;
    final result = await db.query('user');

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  Future<void> deleteUser() async {
    final db = await instance.database;
    await db.delete('user');
  }
}