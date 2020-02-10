import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:vk_parse/models/Song.dart';
import 'package:vk_parse/models/Playlist.dart';

class DBProvider {
  static const dbName = 'vk_music4.db';

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
      await db.execute("CREATE TABLE Song ("
          "song_id INTEGER PRIMARY KEY,"
          "title TEXT,"
          "String TEXT,"
          "duration INTEGER,"
          "download TEXT,"
          "path TEXT,"
          "image BLOB"
          ")");
      await db.execute("CREATE TABLE Playlist ("
          "id INTEGER PRIMARY KEY,"
          "title INTEGER,"
          "image BLOB,"
          "songList TEXT"
          ")");
    });
  }

  newSong(Song song) async {
    final db = await database;
    var res = await db.insert("Song", song.toJson());
    return res;
  }

  newPlaylist(Playlist playlist) async {
    final db = await database;
    playlist.id = new Random().nextInt(20000000);
    var res = await db.insert("Playlist", playlist.toJson());
    return res;
  }

  getSong(int id) async {
    final db = await database;
    var res = await db.query("Song", where: "song_id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Song.fromJson(res.first) : null;
  }

  getPlaylist(int id) async {
    final db = await database;
    var res = await db.query("Playlist", where: "song_id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Song.fromJson(res.first) : null;
  }

  getAllSong() async {
    final db = await database;
    var res = await db.query("Song");
    List<Song> list =
        res.isNotEmpty ? res.map((c) => Song.fromJson(c)).toList() : [];
    return list;
  }

  getAllPlaylist() async {
    final db = await database;
    var res = await db.query("Playlist");
    List<Playlist> list =
        res.isNotEmpty ? res.map((c) => Playlist.fromJson(c)).toList() : [];
    return list;
  }

  updateSong(Song song) async {
    final db = await database;
    var res = await db.update("Song", song.toJson(),
        where: "song_id = ?", whereArgs: [song.song_id]);
    return res;
  }

   updatePlaylist(Playlist playlist) async {
    final db = await database;
    var res = await db.update("Playlist", playlist.toJson(),
        where: "id = ?", whereArgs: [playlist.id]);
    return res;
  }

  deleteAllSongs() async {
    final db = await database;
    db.rawDelete("Delete * from Song");
  }

   deleteAllPlaylist() async {
    final db = await database;
    db.rawDelete("Delete * from Playlist");
  }

  deleteSong(int id) async {
    final db = await database;
    db.delete("Song", where: "song_id = ?", whereArgs: [id]);
  }

  deletePlaylist(int id) async {
    final db = await database;
    db.delete("Playlist", where: "id = ?", whereArgs: [id]);
  }
}
