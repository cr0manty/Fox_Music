import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fox_music/provider/download_data.dart';
import 'package:fox_music/ui/Music/playlist_add_song.dart';
import 'package:fox_music/utils/bottom_route.dart';
import 'package:fox_music/provider/database.dart';
import 'package:fox_music/utils/tile_list.dart';
import 'package:provider/provider.dart';
import 'package:fox_music/utils/apple_search.dart';
import 'package:fox_music/utils/hex_color.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:fox_music/functions/utils/pick_dialog.dart';
import 'package:fox_music/models/playlist.dart';
import 'package:fox_music/provider/music_data.dart';
import 'package:fox_music/models/song.dart';
import 'package:fox_music/functions/format/time.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum ButtonState { SHARE, DELETE }
enum PageType { SAVED, PLAYLIST }

class MusicListPage extends StatefulWidget {
  final PageType _pageType;
  final Playlist playlist;

  MusicListPage({this.playlist})
      : _pageType = playlist != null ? PageType.PLAYLIST : PageType.SAVED;

  State<StatefulWidget> createState() => MusicListPageState();
}

class MusicListPageState extends State<MusicListPage>
    with SingleTickerProviderStateMixin {
  TextEditingController controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Song> _musicList = [];
  List<Song> _musicListSorted = [];
  List<Playlist> _playlistList = [];
  bool init = true;

  void _updateMusicList(MusicData musicData) async {
    if (init) {
      musicData.playlistUpdate = true;
    }
    if ((widget._pageType == PageType.PLAYLIST && musicData.playlistUpdate) ||
        (widget._pageType == PageType.SAVED && musicData.localUpdate)) {
      _loadMusicList(musicData, null);
      if (widget._pageType == PageType.PLAYLIST) {
        musicData.playlistUpdate = false;
      } else {
        musicData.localUpdate = false;
      }
    }
    if (widget._pageType == PageType.SAVED && musicData.playlistListUpdate) {
      List<Playlist> playlistList = await DBProvider.db.getAllPlaylist();

      setState(() {
        _playlistList = playlistList;
        musicData.playlistListUpdate = false;
      });
    }
  }

  void _addToPlaylist(MusicData musicData) {
    FocusScope.of(context).requestFocus(FocusNode());
    Navigator.of(context, rootNavigator: true).push(BottomRoute(
        page: ChangeNotifierProvider<MusicData>.value(
            value: musicData,
            child: AddToPlaylistPage(playlist: widget.playlist))));
  }

  @override
  Widget build(BuildContext context) {
    MusicDownloadData downloadData = Provider.of<MusicDownloadData>(context);
    _updateMusicList(downloadData.musicData);
    init = false;

    return Material(
        child: CupertinoPageScaffold(
            key: _scaffoldKey,
            navigationBar: CupertinoNavigationBar(
                actionsForegroundColor: main_color,
                middle: Text(widget._pageType == PageType.PLAYLIST
                    ? widget.playlist.title
                    : 'Media'),
                previousPageTitle: 'Back',
                trailing: widget._pageType == PageType.PLAYLIST
                    ? GestureDetector(
                        child: Icon(SFSymbols.plus, size: 25),
                        onTap: () => _addToPlaylist(downloadData.musicData))
                    : null),
            child: _buildBody(downloadData)));
  }

  _buildBody(MusicDownloadData downloadData) {
    return SafeArea(
        child: CustomScrollView(slivers: <Widget>[
      CupertinoSliverRefreshControl(
        onRefresh: () =>
            _loadMusicList(downloadData.musicData, null, update: true),
      ),
      SliverList(
          delegate: SliverChildListDelegate(List.generate(
              _musicListSorted.length + 1,
              (index) => _buildSongListTile(index, downloadData))))
    ]));
  }

  _loadMusicList(MusicData musicData, Song song, {bool update = false}) async {
    if (widget._pageType == PageType.SAVED) {
      List<Playlist> playlistList = await DBProvider.db.getAllPlaylist();
      if (update) await musicData.loadSavedMusic();
      setState(() {
        _playlistList = playlistList;
        _musicList = musicData.localSongs;
        _musicListSorted = _musicList;
        _filterSongs(controller.text);
      });
    } else {
      Playlist newPlaylist =
          await DBProvider.db.getPlaylist(widget.playlist.id);
      List<String> songIdList = newPlaylist.splitSongList();
      List<Song> songList = await musicData.loadPlaylistTrack(songIdList);
      if (mounted) {
        setState(() {
          _musicList = songList;
          _musicListSorted = _musicList;
          _filterSongs(controller.text);
        });
      }
    }
    if (song != null) {
      musicData.setPlaylistSongs(_musicList, song);
    }
  }

  _deleteSong(MusicDownloadData downloadData, Song song) {
    showDialog(
        context: context,
        builder: (BuildContext context) => new CupertinoAlertDialog(
                title: Text('Delete file'),
                content: Text('Are you sure you want to delete this file?'),
                actions: [
                  CupertinoDialogAction(
                      isDefaultAction: true,
                      child: Text("Cancel"),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                  CupertinoDialogAction(
                      isDefaultAction: true,
                      isDestructiveAction: true,
                      child: Text("Delete"),
                      onPressed: () {
                        Navigator.pop(context);
                        try {
                          downloadData.musicData.deleteSong(song);
                          downloadData.downloadMark(song, downloaded: false);
                          File(song.path).deleteSync();
                          setState(() {
                            downloadData.musicData.localUpdate = true;
                            _musicList.remove(song);
                          });
                        } catch (e) {
                          print(e);
                        }
                      })
                ]));
  }

  _renameSongDialog(MusicData musicData, Song song) async {
    final TextEditingController artistFilter = new TextEditingController();
    final TextEditingController titleFilter = new TextEditingController();

    artistFilter.text = song.artist;
    titleFilter.text = song.title;

    showDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Rename'),
          content: Padding(
              padding: EdgeInsets.only(top: 10),
              child: Card(
                  color: Colors.transparent,
                  elevation: 0.0,
                  child: Column(children: <Widget>[
                    CupertinoTextField(
                      controller: artistFilter,
                      placeholder: 'Artist',
                      decoration: BoxDecoration(
                          color: HexColor('#303030'),
                          borderRadius: BorderRadius.circular(9)),
                    ),
                    Divider(height: 10, color: Colors.transparent),
                    CupertinoTextField(
                      controller: titleFilter,
                      placeholder: 'Title',
                      decoration: BoxDecoration(
                          color: HexColor('#303030'),
                          borderRadius: BorderRadius.circular(9)),
                    ),
                  ]))),
          actions: <Widget>[
            CupertinoDialogAction(
                isDestructiveAction: true,
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                }),
            CupertinoDialogAction(
                isDefaultAction: true,
                child: Text("Rename"),
                onPressed: () {
                  if (artistFilter.text.isNotEmpty &&
                      titleFilter.text.isNotEmpty) {
                    setState(() {
                      song.title = titleFilter.text;
                      song.artist = artistFilter.text;
                    });
                    musicData.renameSong(song);
                  }
                  Navigator.pop(context);
                }),
          ],
        );
      },
    );
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

  void deleteSongFromPlaylist(MusicData musicData, Song song) {
    setState(() {
      widget.playlist.deleteSong(song.song_id);
      _musicList.remove(song);
      _musicListSorted.remove(song);
      musicData.localUpdate = true;
    });
  }

  _shareSong(Song song) async {
    final File bytes = await File(song.path);
    await WcFlutterShare.share(
        sharePopupTitle: 'Share',
        fileName: song.toFileName() + '.mp3',
        mimeType: 'song/mp3',
        bytesOfFile: bytes.readAsBytesSync());
  }

  List<Widget> _actionsPane(MusicData musicData, Song song) {
    List<Widget> actions = [];
    if (widget._pageType == PageType.SAVED) {
      actions.add(SlideAction(
        color: HexColor('#3a4e93'),
        child: SvgPicture.asset('assets/svg/add_to_playlist.svg',
            color: Colors.white, height: 18, width: 18),
        onTap: () =>
            showPickerDialog(context, musicData, _playlistList, song.song_id),
      ));
    }
    actions.add(SlideAction(
      color: HexColor('#a04db5'),
      child: Icon(SFSymbols.pencil, color: Colors.white),
      onTap: () => _renameSongDialog(musicData, song),
    ));
    return actions;
  }

  _buildSongListTile(int index, MusicDownloadData downloadData) {
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
    return Stack(children: [
      Column(children: <Widget>[
        Slidable(
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.25,
          child: Container(
              height: 60,
              child: TileList(
                padding: EdgeInsets.only(left: 30, right: 20),
                title: Text(song.title,
                    style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
                subtitle: Text(song.artist,
                    style: TextStyle(color: Color.fromRGBO(150, 150, 150, 1))),
                onTap: () async {
                  _loadMusicList(downloadData.musicData, song);
                  downloadData.musicData.isLocal = true;

                  if (downloadData.musicData.currentSong != null &&
                      downloadData.musicData.currentSong.song_id ==
                          song.song_id) {
                    await downloadData.musicData.playerResume();
                  } else {
                    await downloadData.musicData.playerPlay(song);
                  }
                },
                trailing: Text(formatDuration(song.duration),
                    style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
              )),
          actions: _actionsPane(downloadData.musicData, song),
          secondaryActions: <Widget>[
            SlideAction(
              color: HexColor('#5994ce'),
              child: Icon(
                CupertinoIcons.share_up,
                color: Colors.white,
              ),
              onTap: () => _shareSong(song),
            ),
            SlideAction(
              color: HexColor('#d62d2d'),
              child: Icon(
                SFSymbols.trash,
                color: Colors.white,
              ),
              onTap: () => widget._pageType == PageType.SAVED
                  ? _deleteSong(downloadData, song)
                  : deleteSongFromPlaylist(downloadData.musicData, song),
            ),
          ],
        ),
        Padding(
            padding: EdgeInsets.only(left: 12.0),
            child: Divider(height: 1, color: Colors.grey))
      ]),
      downloadData.musicData.isPlaying(song.song_id)
          ? Container(
              height: 60,
              width: 3,
              decoration: BoxDecoration(color: Colors.white),
            )
          : Container(),
    ]);
  }
}
