import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'User.dart';
import 'Song.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "app.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE User ("
          "userId INTEGER PRIMARY KEY,"
          "firstName TEXT,"
          "lastName TEXT,"
          "image TEXT"
          "email TEXT"
          "joined DATETIME"
          "token TEXT"
          ")");
      await db.execute("CREATE TABLE Song ("
          "songId INTEGER PRIMARY KEY,"
          "duration INTEGER,"
          "artist TEXT,"
          "name TEXT"
          "postedAt DATETIME"
          "localUrl TEXT"
          ")");
    });
  }

  newUser(User user) async {
    final db = await database;
    var res = await db.insert("User", user.toJson());
    return res;
  }

  updateUser(User user) async {
    final db = await database;
    var res = await db.update("User", user.toJson(),
        where: "userId = ?", whereArgs: [user.userId]);
    return res;
  }

  deleteUser(int id) async {
    final db = await database;
    db.delete("User", where: "userId = ?", whereArgs: [id]);
  }

  deleteAllSongs() async {
    final db = await database;
    db.rawDelete("Delete * from Song");
  }

  deleteSong(int id) async {
    final db = await database;
    db.delete("Song", where: "songId = ?", whereArgs: [id]);
  }
}
