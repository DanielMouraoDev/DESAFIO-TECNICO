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
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE courses(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            remote_id INTEGER UNIQUE,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            active INTEGER NOT NULL,
            pending_sync INTEGER NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            ALTER TABLE courses ADD COLUMN remote_id INTEGER UNIQUE
          ''');
        }
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

  Future<Course> saveOrUpdateCourse(Course course) async {
    final db = await database;
    if (course.remoteId != null) {
      final rows = await db.query(
        'courses',
        where: 'remote_id = ?',
        whereArgs: [course.remoteId],
        limit: 1,
      );
      if (rows.isNotEmpty) {
        final existing = Course.fromMap(rows.first);
        await db.update(
          'courses',
          course.copyWith(id: existing.id, pendingSync: false).toMap(),
          where: 'id = ?',
          whereArgs: [existing.id],
        );
        return course.copyWith(id: existing.id);
      }
    }

    final id = await db.insert('courses', course.toMap());
    return course.copyWith(id: id);
  }

  Future<void> saveCourses(List<Course> courses) async {
    final db = await database;
    await db.transaction((txn) async {
      for (final course in courses) {
        if (course.remoteId != null) {
          final rows = await txn.query(
            'courses',
            where: 'remote_id = ?',
            whereArgs: [course.remoteId],
            limit: 1,
          );
          if (rows.isNotEmpty) {
            final existing = Course.fromMap(rows.first);
            await txn.update(
              'courses',
              course.copyWith(id: existing.id, pendingSync: false).toMap(),
              where: 'id = ?',
              whereArgs: [existing.id],
            );
            continue;
          }
        }
        await txn.insert('courses', course.toMap());
      }
    });
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

  Future<void> markCourseSynced(int id, {int? remoteId}) async {
    final db = await database;
    final values = <String, Object?>{'pending_sync': 0};
    if (remoteId != null) {
      values['remote_id'] = remoteId;
    }
    await db.update(
      'courses',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
