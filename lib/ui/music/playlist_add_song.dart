import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:fox_music/instances/database.dart';
import 'package:fox_music/widgets/tile_list.dart';
import 'package:fox_music/widgets/apple_search.dart';
import 'package:fox_music/utils/hex_color.dart';
import 'package:fox_music/models/playlist.dart';
import 'package:fox_music/instances/music_data.dart';
import 'package:fox_music/models/song.dart';

class AddToPlaylistPage extends StatefulWidget {
  final Playlist playlist;

  AddToPlaylistPage({this.playlist});

  State<StatefulWidget> createState() => AddToPlaylistPageState();
}

class AddToPlaylistPageState extends State<AddToPlaylistPage> {
  TextEditingController controller = TextEditingController();
  List<Song> _musicList = [];
  List<Song> _musicListSorted = [];

  void _updateMusicList() async {
    _loadMusicList(null);
    MusicData.instance.localUpdate = false;
  }

  void _onSave() {
    String songList = '';
    _musicList.forEach((Song song) {
      if (song.inPlaylist) songList += '${song.song_id},';
    });
    widget.playlist.songList = songList;
    MusicData.instance.playlistUpdate = true;
    MusicData.instance.localUpdate = true;

    DBProvider.db.updatePlaylist(widget.playlist);
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    _updateMusicList();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
                actionsForegroundColor: HexColor.main(),
                middle: Text('Media'),
                previousPageTitle: 'Back',
                trailing: GestureDetector(
                    child: Text(
                      'Save',
                      style: TextStyle(color: HexColor.main()),
                    ),
                    onTap: () => _onSave())),
            child: _buildBody()));
  }

  _buildBody() {
    return SafeArea(
        child: CustomScrollView(slivers: <Widget>[
      CupertinoSliverRefreshControl(
        onRefresh: () => _loadMusicList(null, update: true),
      ),
      SliverList(
          delegate: SliverChildListDelegate(List.generate(
              _musicListSorted.length + 1,
              (index) => _buildSongListTile(index))))
    ]));
  }

  _loadMusicList(Song song, {bool update = false}) async {
    Playlist newPlaylist = await DBProvider.db.getPlaylist(widget.playlist.id);
    List<String> songIdList = newPlaylist.splitSongList();
    List<Song> songList =
        await MusicData.instance.loadPlaylistAddTrack(songIdList);
    setState(() {
      _musicList = songList;
      _musicListSorted = _musicList;
      _filterSongs(controller.text);
    });
    if (song != null) {
      MusicData.instance.setPlaylistSongs(_musicList, song);
    }
  }

  void _filterSongs(String value, {List<Song> musicList}) {
    String newValue = value.toLowerCase();
    setState(() {
      _musicListSorted = (musicList != null ? musicList : _musicList)
          .where((song) =>
              song.artist.toLowerCase().contains(newValue) ||
              song.title.toLowerCase().contains(newValue))
          .toList();
    });
  }

  _buildSongListTile(int index) {
    if (index == 0) {
      return AppleSearch(
        onChange: _filterSongs,
        controller: controller,
      );
    }

    Song song = _musicListSorted[index - 1];
    if (song == null) {
      return null;
    }
    return Column(children: <Widget>[
      Container(
          height: 60,
          child: TileList(
              padding: EdgeInsets.only(left: 30, right: 20),
              title: Text(song.title,
                  style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
              subtitle: Text(song.artist,
                  style: TextStyle(color: Color.fromRGBO(150, 150, 150, 1))),
              onTap: () async {
                setState(() {
                  song.inPlaylist = !song.inPlaylist;
                });
              },
              trailing: Row(
                children: <Widget>[
                  Text(song.formatDuration(),
                      style:
                          TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
                  SizedBox(
                    width: 20,
                  ),
                  Icon(
                    song.inPlaylist
                        ? SFSymbols.checkmark_circle_fill
                        : SFSymbols.circle,
                    color: Colors.grey,
                  )
                ],
              ))),
      Padding(
          padding: EdgeInsets.only(left: 12.0),
          child: Divider(height: 1, color: Colors.grey))
    ]);
  }
}
