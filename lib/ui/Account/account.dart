import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fox_music/provider/check_connection.dart';
import 'package:fox_music/widgets/offline.dart';
import 'package:provider/provider.dart';
import 'package:fox_music/functions/format/image.dart';
import 'package:fox_music/provider/account_data.dart';
import 'package:fox_music/provider/download_data.dart';
import 'package:fox_music/ui/Account/friends.dart';
import 'package:fox_music/ui/Account/auth_vk.dart';
import 'package:fox_music/ui/Account/account_edit.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:fox_music/ui/Music/search_music.dart';
import 'package:fox_music/ui/Account/search_people.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AccountPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool init = true;
  bool visible = true;

  Widget _body(MusicDownloadData downloadData) {
    return ListView(children: [
      Padding(
          padding: EdgeInsets.only(bottom: 15, top: 15),
          child: GestureDetector(
            onTap: () {
              showCupertinoModalPopup(
                  context: _scaffoldKey.currentContext,
                  builder: (context) {
                    return CupertinoActionSheet(
                      actions: <Widget>[
                        CupertinoActionSheetAction(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.of(_scaffoldKey.currentContext,
                                      rootNavigator: true)
                                  .push(CupertinoPageRoute(
                                      builder: (context) => AccountEditPage()));
                            },
                            child: Text(
                              'Edit',
                              style: TextStyle(color: Colors.blue),
                            )),
                        CupertinoActionSheetAction(
                            onPressed: () async {
                              await AccountData.instance.makeLogout();
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Logout',
                            ))
                      ],
                    );
                  });
            },
            child: Center(
                child: CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.grey,
                    backgroundImage: ConnectionsCheck.instance.isOnline
                        ? NetworkImage(
                            formatImage(AccountData.instance.user?.image))
                        : null)),
          )),
      Padding(
          padding: EdgeInsets.only(bottom: 25),
          child: Center(
              child: Text(
                  AccountData.instance.user?.last_name?.isEmpty == null &&
                          AccountData.instance.user?.first_name?.isEmpty == null
                      ? ''
                      : '${AccountData.instance.user.first_name} ${AccountData.instance.user.last_name}',
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)))),
      Divider(height: 1, color: Colors.grey),
      Material(
          color: Colors.transparent,
          child: ListTile(
            leading: SvgPicture.asset('assets/svg/search_music.svg',
                color: Colors.white, height: 22, width: 22),
            onTap: () {
              Navigator.of(_scaffoldKey.currentContext, rootNavigator: true)
                  .push(CupertinoPageRoute(
                      builder: (context) => MultiProvider(providers: [
                            ChangeNotifierProvider<MusicDownloadData>.value(
                                value: downloadData),
                          ], child: SearchMusicPage())));
            },
            title: Text(
              'Music Search',
              style: TextStyle(color: Colors.white),
            ),
          )),
      Divider(height: 1, color: Colors.grey),
      Material(
          color: Colors.transparent,
          child: ListTile(
            leading: SvgPicture.asset('assets/svg/search_friends.svg',
                color: Colors.white, height: 22, width: 22),
            onTap: () {
              Navigator.of(_scaffoldKey.currentContext, rootNavigator: true)
                  .push(CupertinoPageRoute(
                      builder: (context) =>
                          ChangeNotifierProvider<MusicDownloadData>.value(
                              value: downloadData, child: SearchPeoplePage())));
            },
            title: Text(
              'People Search',
              style: TextStyle(color: Colors.white),
            ),
          )),
      Divider(height: 1, color: Colors.grey),
      Material(
          color: Colors.transparent,
          child: ListTile(
            leading: Icon(SFSymbols.person_2_alt, color: Colors.white),
            onTap: () {
              Navigator.of(_scaffoldKey.currentContext, rootNavigator: true)
                  .push(CupertinoPageRoute(
                      builder: (context) =>
                          ChangeNotifierProvider<MusicDownloadData>.value(
                              value: downloadData, child: FriendListPage())));
            },
            title: Text(
              'Friends',
              style: TextStyle(color: Colors.white),
            ),
          )),
      Divider(height: 1, color: Colors.grey),
      Material(
          color: Colors.transparent,
          child: ListTile(
            leading: Icon(SFSymbols.arrow_down_to_line, color: Colors.white),
            onTap: () => _downloadAll(downloadData),
            title: Text(
              'Download all',
              style: TextStyle(color: Colors.white),
            ),
          )),
      Divider(height: 1, color: Colors.grey),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    MusicDownloadData downloadData = Provider.of<MusicDownloadData>(context);

    if ((AccountData.instance.user == null ||
            AccountData.instance.needUpdate) &&
        ConnectionsCheck.instance.isOnline) {
      AccountData.instance.init();
    }

    if (init) {
      visible = ConnectionsCheck.instance.isOnline;
      init = false;
    }

    return CupertinoPageScaffold(
        key: _scaffoldKey,
        navigationBar: CupertinoNavigationBar(
          middle: Text('Profile'),
          trailing: CupertinoButton(
            onPressed: ConnectionsCheck.instance.isOnline
                ? () => Navigator.of(_scaffoldKey.currentContext,
                        rootNavigator: true)
                    .push(CupertinoPageRoute(
                        builder: (context) => AccountEditPage()))
                : null,
            child: Text('Edit'),
            padding: EdgeInsets.zero,
          ),
        ),
        child: Stack(children: <Widget>[
          _body(downloadData),
          AnimatedOpacity(
              onEnd: () => setState(() => visible = !visible),
              opacity: ConnectionsCheck.instance.isOnline ? 0 : 1,
              duration: Duration(milliseconds: 800),
              child: !visible ? OfflinePage() : Container())
        ]));
  }

  _downloadAll(MusicDownloadData downloadData) async {
    if (AccountData.instance.user.can_use_vk) {
      await downloadData.musicData.loadSavedMusic();
      downloadData.multiQuery = downloadData.musicData.localSongs;
    } else {
      showDialog(
          context: _scaffoldKey.currentContext,
          builder: (BuildContext context) => CupertinoAlertDialog(
                  title: Text('Error'),
                  content: Text(
                      'In order to download, you have to allow access to your account details'),
                  actions: [
                    CupertinoDialogAction(
                        isDefaultAction: true,
                        child: Text("Later"),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    CupertinoDialogAction(
                        isDefaultAction: true,
                        child: Text("Submit"),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(_scaffoldKey.currentContext).push(
                              CupertinoPageRoute(
                                  builder: (context) => VKAuthPage()));
                        })
                  ]));
    }
  }
}
