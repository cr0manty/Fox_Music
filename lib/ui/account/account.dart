import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fox_music/instances/check_connection.dart';
import 'package:fox_music/instances/music_data.dart';
import 'package:fox_music/widgets/offline.dart';
import 'package:fox_music/instances/account_data.dart';
import 'package:fox_music/instances/download_data.dart';
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
  Widget _body() {
    return ListView(children: [
      Padding(
          padding: EdgeInsets.only(bottom: 15, top: 15),
          child: GestureDetector(
            onTap: () {
              showCupertinoModalPopup(
                  context: context,
                  builder: (context) {
                    return CupertinoActionSheet(
                      actions: <Widget>[
                        CupertinoActionSheetAction(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(CupertinoPageRoute(
                                  builder: (context) => AccountEditPage()));
                            },
                            child: Text(
                              'Edit',
                              style: TextStyle(color: Colors.blue),
                            )),
                        CupertinoActionSheetAction(
                            onPressed: () async {
                              await AccountData.instance.makeLogout();
                              Navigator.of(context).pop();
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
                        ? NetworkImage(AccountData.instance.user.imageUrl())
                        : null)),
          )),
      Padding(
          padding: EdgeInsets.only(bottom: 25),
          child: Center(
              child: Text(
                  AccountData.instance.user?.lastName?.isEmpty == null &&
                          AccountData.instance.user?.firstName?.isEmpty == null
                      ? ''
                      : '${AccountData.instance.user.firstName} ${AccountData.instance.user.lastName}',
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
              Navigator.of(context).push(
                  CupertinoPageRoute(builder: (context) => SearchMusicPage()));
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
              Navigator.of(context).push(
                  CupertinoPageRoute(builder: (context) => SearchPeoplePage()));
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
              Navigator.of(context).push(
                  CupertinoPageRoute(builder: (context) => FriendListPage()));
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
            onTap: () => _downloadAll(),
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
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Account'),
          trailing: CupertinoButton(
            onPressed: ConnectionsCheck.instance.isOnline
                ? () => Navigator.of(context).push(
                    CupertinoPageRoute(builder: (context) => AccountEditPage()))
                : null,
            child: Text('Edit'),
            padding: EdgeInsets.zero,
          ),
        ),
        child: Stack(children: <Widget>[
          _body(),
          AnimatedOpacity(
              opacity: ConnectionsCheck.instance.isOnline ? 0 : 1,
              duration: Duration(milliseconds: 800),
              child: !ConnectionsCheck.instance.isOnline
                  ? OfflinePage()
                  : Container())
        ]));
  }

  _downloadAll() async {
    if (AccountData.instance.user.canUseVk) {
      await MusicData.instance.loadSavedMusic();
      MusicDownloadData.instance.multiQuery = MusicData.instance.localSongs;
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
                  title: Text('Error'),
                  content: Text(
                      'In order to download, you have to allow access to your account details'),
                  actions: [
                    CupertinoDialogAction(
                        isDefaultAction: true,
                        child: Text("Later"),
                        onPressed: Navigator.of(context).pop),
                    CupertinoDialogAction(
                        isDefaultAction: true,
                        child: Text("Submit"),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(CupertinoPageRoute(
                              builder: (context) => VKAuthPage()));
                        })
                  ]));
    }
  }
}
