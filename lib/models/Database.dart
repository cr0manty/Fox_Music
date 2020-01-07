import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'User.dart';
import 'Song.dart';

class DBProvider {
  static const dbName = 'vk_music2.db';

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
    String path = join(documentsDirectory.path, dbName);
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE User ("
          "id INTEGER PRIMARY KEY,"
          "user_id INTEGER,"
          "first_name TEXT,"
          "username TEXT,"
          "last_name TEXT,"
          "image TEXT,"
          "email TEXT,"
          "date_joined TEXT,"
          "last_login TEXT,"
          "token TEXT,"
          "vk_auth BOOLEAN DEFAULT FALSE,"
          "is_staff BOOLEAN DEFAULT FALSE,"
          "can_use_vk BOOLEAN DEFAULT FALSE"
          ")");
      await db.execute("CREATE TABLE Song ("
          "song_id INTEGER PRIMARY KEY,"
          "duration INTEGER,"
          "user_id INTEGER,"
          "download TEXT,"
          "artist TEXT,"
          "name TEXT,"
          "posted_at TEXT,"
          "updated_at TEXT,"
          "localUrl TEXT"
          ")");
    });
  }

  newUser(User user) async {
    final db = await database;
    var res = await db.insert("User", user.toJson());
    return res;
  }

  getUser(int id) async {
    final db = await database;
    var res = await db.query("User", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? User.fromJson(res.first) : null;
  }

  getAllUsers() async {
    final db = await database;
    var res = await db.query("User");
    List<User> list =
        res.isNotEmpty ? res.map((c) => User.fromJson(c)).toList() : [];
    return list;
  }

  updateUser(User user) async {
    final db = await database;
    var res = await db
        .update("User", user.toJson(), where: "id = ?", whereArgs: [user.id]);
    return res;
  }

  deleteUser(int id) async {
    final db = await database;
    db.delete("User", where: "id = ?", whereArgs: [id]);
  }

  newSong(Song song) async {
    final db = await database;
    var res = await db.insert("Song", song.toJson());
    return res;
  }

  updateSong(Song song) async {
    final db = await database;
    var res = await db.update("Song", song.toJson(),
        where: "songId = ?", whereArgs: [song.song_id]);
    return res;
  }

  deleteAllSongs() async {
    final db = await database;
    db.rawDelete("Delete * from Song");
  }

  deleteSong(int id) async {
    final db = await database;
    db.delete("Song", where: "song_id = ?", whereArgs: [id]);
  }

  getSong(int id) async {
    final db = await database;
    var res = await db.query("Song", where: "song_id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Song.fromJson(res.first) : null;
  }

  getAllUserSongs(int id) async {
    if (id == -1) {
      return null;
    }

    final db = await database;
    var res = await db.query("Song", where: "user_id = ?", whereArgs: [id]);
    List<Song> list =
        res.isNotEmpty ? res.map((c) => Song.fromJson(c)).toList() : [];
    return list;
  }
}
