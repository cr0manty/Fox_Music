import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fox_music/utils/check_connection.dart';
import 'package:fox_music/utils/offline.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Widget _body(AccountData accountData, MusicDownloadData downloadData,
      ConnectionsCheck connection) {
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
                                      builder: (context) =>
                                          ChangeNotifierProvider<
                                                  AccountData>.value(
                                              value: accountData,
                                              child: AccountEditPage())));
                            },
                            child: Text(
                              'Edit',
                              style: TextStyle(color: Colors.blue),
                            )),
                        CupertinoActionSheetAction(
                            onPressed: () async {
                              await accountData.makeLogout();
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
                    backgroundImage: connection.isOnline
                        ? NetworkImage(formatImage(accountData.user?.image))
                        : null)),
          )),
      Padding(
          padding: EdgeInsets.only(bottom: 25),
          child: Center(
              child: Text(
                  accountData.user?.last_name?.isEmpty == null &&
                          accountData.user?.first_name?.isEmpty == null
                      ? ''
                      : '${accountData.user.first_name} ${accountData.user.last_name}',
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
                      builder: (context) => MultiProvider(providers: [
                            ChangeNotifierProvider<MusicDownloadData>.value(
                                value: downloadData),
                            ChangeNotifierProvider<AccountData>.value(
                                value: accountData),
                          ], child: SearchPeoplePage())));
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
                      builder: (context) => MultiProvider(providers: [
                            ChangeNotifierProvider<MusicDownloadData>.value(
                                value: downloadData),
                            ChangeNotifierProvider<AccountData>.value(
                                value: accountData),
                          ], child: FriendListPage())));
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
            onTap: () => _downloadAll(accountData, downloadData),
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
    AccountData accountData = Provider.of<AccountData>(context);
    MusicDownloadData downloadData = Provider.of<MusicDownloadData>(context);
    ConnectionsCheck connection = Provider.of<ConnectionsCheck>(context);

    if ((accountData.user == null || accountData.needUpdate) &&
        connection.isOnline) {
      accountData.init(true);
    }

    return CupertinoPageScaffold(
        key: _scaffoldKey,
        navigationBar: CupertinoNavigationBar(middle: Text('Profile')),
        child: Stack(children: <Widget>[
          _body(accountData, downloadData, connection),
          AnimatedOpacity(
              opacity: connection.isOnline ? 0 : 1,
              duration: Duration(milliseconds: 800),
              child: OfflinePage())
        ]));
  }

  _downloadAll(AccountData accountData, MusicDownloadData downloadData) async {
    if (accountData.user.can_use_vk) {
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
                                  builder: (context) =>
                                      ChangeNotifierProvider<AccountData>.value(
                                          value: accountData,
                                          child: VKAuthPage(accountData))));
                        })
                  ]));
    }
  }
}
