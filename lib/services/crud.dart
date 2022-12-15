import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class Crud {

  // Database related oeprations

  static Future<void> createTable(sql.Database database) async {
    await database.execute("""
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 
        title TEXT NOT NULL,
        note TEXT NOT NULL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);

    // id - Unique ID
    // title - note title
    // note - body oof the note
    // createdAt - time at which note was created
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'notes.db',
      version: 1,
      onCreate: (db, version) async {
        await createTable(db);
      },
    );
  }

  // Add, Update and Delete operations

  // Get All Notes from DB
  static Future<List<Map<String, dynamic>>> getNotes() async {
    final db = await Crud.db();
    return db.query('notes', orderBy: 'id');
  }

  // Get single note from DB
  static Future<List<Map<String, dynamic>>> getNote(int id) async {
    final db = await Crud.db();
    return db.query('notes', where: "id = ?", whereArgs: [id]);
  }

  // Create a note
  static Future<int> createNote(String title, String note) async {
    final db = await Crud.db();
    final dataToBeInserted = {'title': title, 'note': note};
    final id = await db.insert('notes', dataToBeInserted);
    return id;
  }

  // Update a single note
  static Future<int> updateNote(int id, String title, String note) async {
    final db = await Crud.db();
    final updatedDataToBeInserted = {
      'title': title,
      'note': note,
      'createdAt': DateTime.now().toString()
    };
    final updatedId = await db.update('notes', updatedDataToBeInserted,
        where: "id = ?", whereArgs: [id]);
    return updatedId;
  }

  // Delete a single note
  static Future<void> deleteNote(int id) async {
    final db = await Crud.db();
    try {
      await db.delete('notes', where: "id = ?", whereArgs: [id]);
    } catch (e) {
      debugPrint("Something went wrong");
    }
  }

  // Delete all notes
  static Future<void> deleteAllNotes() async {
    final db = await Crud.db();
    try {
      await db.delete('notes');
    } catch (e) {
      debugPrint("Something went wrong");
    }
  }
}
