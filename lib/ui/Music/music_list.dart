import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fox_music/instances/download_data.dart';
import 'package:fox_music/instances/utils.dart';
import 'package:fox_music/ui/Music/playlist_add_song.dart';
import 'package:fox_music/utils/bottom_route.dart';
import 'package:fox_music/instances/database.dart';
import 'package:fox_music/utils/help_tools.dart';
import 'package:fox_music/widgets/tile_list.dart';
import 'package:fox_music/widgets/apple_search.dart';
import 'package:fox_music/utils/hex_color.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:fox_music/models/playlist.dart';
import 'package:fox_music/instances/music_data.dart';
import 'package:fox_music/models/song.dart';
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
  StreamSubscription _filesystemStream;
  StreamSubscription _songStream;
  TextEditingController controller = TextEditingController();
  List<Song> _musicList = [];
  List<Song> _musicListSorted = [];
  List<Playlist> _playlistList = [];

  void _updateMusicList() async {
    if ((widget._pageType == PageType.PLAYLIST &&
            MusicData.instance.playlistUpdate) ||
        (widget._pageType == PageType.SAVED &&
            MusicData.instance.localUpdate)) {
      _loadMusicList(null);
      if (widget._pageType == PageType.PLAYLIST) {
        MusicData.instance.playlistUpdate = false;
      } else {
        MusicData.instance.localUpdate = false;
      }
    }
    if (widget._pageType == PageType.SAVED &&
        MusicData.instance.playlistListUpdate) {
      List<Playlist> playlistList = await DBProvider.db.getAllPlaylist();

      setState(() {
        _playlistList = playlistList;
        MusicData.instance.playlistListUpdate = false;
      });
    }
  }

  void _addToPlaylist() {
    FocusScope.of(context).requestFocus(FocusNode());
    Navigator.of(context, rootNavigator: true)
        .push(BottomRoute(page: AddToPlaylistPage(playlist: widget.playlist)));
  }

  @override
  void initState() {
    super.initState();
    _filesystemStream = MusicData.instance.filesystemStream.listen((event) {
      _updateMusicList();
    });
    _songStream = MusicData.instance.songUpdates.listen((event) {
      setState(() {
        _musicList = MusicData.instance.localSongs;
        _filterSongs(controller.text);
      });
    });
    MusicData.instance.playlistUpdate = true;
    _updateMusicList();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
                actionsForegroundColor: HexColor.main(),
                middle: Text(widget._pageType == PageType.PLAYLIST
                    ? widget.playlist.title
                    : 'Media'),
                previousPageTitle: 'Back',
                trailing: widget._pageType == PageType.PLAYLIST
                    ? GestureDetector(
                        child: Icon(SFSymbols.plus, size: 25),
                        onTap: () => _addToPlaylist())
                    : null),
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
              _musicListSorted.length + (Utils.instance.playerUsing ? 2 : 1),
              (index) => _buildSongListTile(index))))
    ]));
  }

  _loadMusicList(Song song, {bool update = false}) async {
    if (widget._pageType == PageType.SAVED) {
      List<Playlist> playlistList = await DBProvider.db.getAllPlaylist();
      if (update) await MusicData.instance.loadSavedMusic();
      setState(() {
        _playlistList = playlistList;
        _musicList = MusicData.instance.localSongs;
        _musicListSorted = _musicList;
        _filterSongs(controller.text);
      });
    } else {
      Playlist newPlaylist =
          await DBProvider.db.getPlaylist(widget.playlist.id);
      List<String> songIdList = newPlaylist.splitSongList();
      List<Song> songList =
          await MusicData.instance.loadPlaylistTrack(songIdList);
      if (mounted) {
        setState(() {
          _musicList = songList;
          _musicListSorted = _musicList;
          _filterSongs(controller.text);
        });
      }
    }
    if (song != null) {
      await MusicData.instance.setPlaylistSongs(_musicList, song);
    }
  }

  _deleteSong(Song song) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
                title: Text('Delete file'),
                content: Text('Are you sure you want to delete this file?'),
                actions: [
                  CupertinoDialogAction(
                      isDefaultAction: true,
                      child: Text("Cancel"),
                      onPressed: Navigator.of(context).pop),
                  CupertinoDialogAction(
                      isDefaultAction: true,
                      isDestructiveAction: true,
                      child: Text("Delete"),
                      onPressed: () {
                        Navigator.of(context).pop();
                        try {
                          MusicData.instance.deleteSong(song);
                          MusicDownloadData.instance
                              .downloadMark(song, downloaded: false);
                          File(song.path).deleteSync();
                          setState(() {
                            MusicData.instance.localUpdate = true;
                            _musicList.remove(song);
                          });
                        } catch (e) {
                          print(e);
                        }
                      })
                ]));
  }

  _renameSongDialog(Song song) async {
    final TextEditingController artistFilter = TextEditingController();
    final TextEditingController titleFilter = TextEditingController();

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
                          color: HexColor.mainText(),
                          borderRadius: BorderRadius.circular(9)),
                    ),
                    Divider(height: 10, color: Colors.transparent),
                    CupertinoTextField(
                      controller: titleFilter,
                      placeholder: 'Title',
                      decoration: BoxDecoration(
                          color: HexColor.mainText(),
                          borderRadius: BorderRadius.circular(9)),
                    ),
                  ]))),
          actions: <Widget>[
            CupertinoDialogAction(
                isDestructiveAction: true,
                child: Text("Cancel"),
                onPressed: Navigator.of(context).pop),
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
                    MusicData.instance.renameSong(song);
                  }
                  Navigator.of(context).pop();
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

  void deleteSongFromPlaylist(Song song) {
    setState(() {
      widget.playlist.deleteSong(song.song_id);
      _musicList.remove(song);
      _musicListSorted.remove(song);
      MusicData.instance.localUpdate = true;
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

  List<Widget> _actionsPane(Song song) {
    List<Widget> actions = [];
    if (widget._pageType == PageType.SAVED) {
      actions.add(SlideAction(
        color: HexColor('#3a4e93'),
        child: SvgPicture.asset('assets/svg/add_to_playlist.svg',
            color: Colors.white, height: 18, width: 18),
        onTap: () => HelpTools.showPickerDialog(
            context, MusicData.instance, _playlistList, song.song_id),
      ));
    }
    actions.add(SlideAction(
      color: HexColor('#a04db5'),
      child: Icon(SFSymbols.pencil, color: Colors.white),
      onTap: () => _renameSongDialog(song),
    ));
    return actions;
  }

  _buildSongListTile(int index) {
    if (index == 0) {
      return AppleSearch(
        onChange: _filterSongs,
        controller: controller,
      );
    }

    if (index >= _musicListSorted.length + 1) {
      return Container(height: 75);
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
                  bool isLocal = MusicData.instance.isLocal;
                  await _loadMusicList(song);

                  if (MusicData.instance.currentSong != null &&
                      MusicData.instance.currentSong.song_id == song.song_id &&
                      isLocal == true) {
                    await MusicData.instance.playerResume();
                  } else {
                    await MusicData.instance
                        .playerPlay(index: _musicList.indexOf(song));
                  }
                },
                trailing: Text(song.formatDuration(),
                    style: TextStyle(color: Color.fromRGBO(200, 200, 200, 1))),
              )),
          actions: _actionsPane(song),
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
                  ? _deleteSong(song)
                  : deleteSongFromPlaylist(song),
            ),
          ],
        ),
        Padding(
            padding: EdgeInsets.only(left: 12.0),
            child: Divider(height: 1, color: Colors.grey))
      ]),
      MusicData.instance.isPlaying(song.song_id)
          ? Container(
              height: 60,
              width: 3,
              decoration: BoxDecoration(color: Colors.white),
            )
          : Container(),
    ]);
  }

  @override
  void dispose() {
    super.dispose();
    _filesystemStream?.cancel();
    _songStream?.cancel();
  }
}
