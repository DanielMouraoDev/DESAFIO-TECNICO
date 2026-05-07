import 'dart:async';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/course.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._internal();

  LocalDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final docs = await getApplicationDocumentsDirectory();
    final path = join(docs.path, 'meu_projeto_edu.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE courses(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            active INTEGER NOT NULL,
            pending_sync INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<Course>> getCourses() async {
    final db = await database;
    final rows = await db.query('courses', orderBy: 'id DESC');
    return rows.map((row) => Course.fromMap(row)).toList();
  }

  Future<Course> saveCourse(Course course) async {
    final db = await database;
    final id = await db.insert('courses', course.toMap());
    return course.copyWith(id: id);
  }

  Future<List<Course>> getPendingSyncCourses() async {
    final db = await database;
    final rows = await db.query(
      'courses',
      where: 'pending_sync = ?',
      whereArgs: [1],
      orderBy: 'id ASC',
    );
    return rows.map((row) => Course.fromMap(row)).toList();
  }

  Future<void> markCourseSynced(int id) async {
    final db = await database;
    await db.update(
      'courses',
      {'pending_sync': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
