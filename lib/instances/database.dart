import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fox_music/models/playlist.dart';

class DBProvider {
  static const dbName = 'fox_music.db';

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
      await db.execute("CREATE TABLE Playlist ("
          "id INTEGER PRIMARY KEY,"
          "title TEXT,"
          "image BLOB,"
          "songList TEXT"
          ")");
      await db.execute("CREATE TABLE SongLyrics ("
          "id INTEGER PRIMARY KEY,"
          "songId int,"
          "text TEXT"
          ")");
    });
  }

  newPlaylist(Playlist playlist) async {
    final db = await database;
    playlist.id = Random().nextInt(20000000);
    var res = await db.insert("Playlist", playlist.toJson());
    return res;
  }

  getPlaylist(int id) async {
    final db = await database;
    var res = await db.query("Playlist", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Playlist.fromJson(res.first) : null;
  }

  getAllPlaylist() async {
    final db = await database;
    var res = await db.query("Playlist");
    List<Playlist> list =
        res.isNotEmpty ? res.map((c) => Playlist.fromJson(c)).toList() : [];
    return list;
  }

  updatePlaylist(Playlist playlist) async {
    final db = await database;
    var res = await db.update("Playlist", playlist.toJson(),
        where: "id = ?", whereArgs: [playlist.id]);
    return res;
  }

  deleteAllPlaylist() async {
    final db = await database;
    db.rawDelete("Delete * from Playlist");
  }

  deletePlaylist(int id) async {
    final db = await database;
    db.delete("Playlist", where: "id = ?", whereArgs: [id]);
  }

  getSongText(int songId) async {
    final db = await database;
    var res =
        await db.rawQuery("SELECT * FROM SongLyrics WHERE songId = ?",  [songId]);
    return res;
  }

  songLyricsUpdate(int id, String text) async {
    final exist = await getSongText(id);
    final db = await database;

    if (exist != null) {
      bool result = await songLyricsCreate(id, text);
      return result;
    } else {
      int updateCount = await db.rawUpdate(
          'UPDATE SongLyrics SET text = ? WHERE songId = ?', [text, id]);
      return updateCount > 0;
    }
  }

  songLyricsCreate(int songId, String text) async {
    final db = await database;
    int id = Random().nextInt(20000000);
    var res = await db
        .insert("SongLyrics", {'id': id, 'songId': songId, 'text': text});
    return res > 0;
  }
}
