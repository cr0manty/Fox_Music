import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:image_picker/image_picker.dart';

import 'package:vk_parse/widgets/AppBarDrawer.dart';
import 'package:vk_parse/utils/colors.dart';
import 'package:vk_parse/functions/save/saveCurrentRoute.dart';
import 'package:vk_parse/models/User.dart';
import 'package:vk_parse/utils/urls.dart';
import 'package:vk_parse/functions/utils/chooseDialog.dart';
import 'package:vk_parse/api/requestProfile.dart';
import 'package:vk_parse/utils/routes.dart';

class Account extends StatefulWidget {
  final AudioPlayer _audioPlayer;
  final User _user;

  Account(this._audioPlayer, this._user);

  @override
  State<StatefulWidget> createState() => new AccountState(_audioPlayer, _user);
}

enum AccountType { self, friend, request, block, send_request }

class AccountState extends State<Account> {
  final GlobalKey<ScaffoldState> _menuKey = new GlobalKey<ScaffoldState>();
  final AudioPlayer _audioPlayer;
  final User _user;

  AccountState(this._audioPlayer, this._user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _menuKey,
      drawer: AppBarDrawer(_audioPlayer),
      appBar: makeAppBar('User account', _menuKey),
      backgroundColor: lightGrey,
      body: _build(),
    );
  }

  @override
  void initState() {
    super.initState();
    saveCurrentRoute(route: 2);
  }

  _build() {
    return Container(
        child: Column(
      children: [
        new Padding(
            padding: EdgeInsets.only(top: 20, left: 20, bottom: 20),
            child: new FlatButton(
                child: new CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.grey,
                    backgroundImage:
                        new Image.network(BASE_URL + _user.image).image),
                onPressed: () async {
                  print('icon pressed');
                  var imageFile;
                  chooseDialog(_menuKey.currentContext, 'Upload photo from...',
                      'Gallery', 'Take photo', firstFunction: () async {
                    imageFile = await ImagePicker.pickImage(
                        source: ImageSource.gallery);
                    if (await requestProfilePost(body: {
                      'image': base64Encode(imageFile.readAsBytesSync())
                    })) print('saved');
                  }, secondFunction: () async {
                    imageFile =
                        await ImagePicker.pickImage(source: ImageSource.camera);
                    if (await requestProfilePost(body: {
                      'image': base64Encode(imageFile.readAsBytesSync())
                    })) print('saved');
                    print('saved');
                  });
                },
                shape: CircleBorder())),
        new Column(
          children: [
            new Padding(
                padding: EdgeInsets.only(top: 20, left: 20, bottom: 20),
                child: new Text(_user.username,
                    style:
                        TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
            new Text('First name:'),
            new Text(_user.first_name),
            new Text('Last name:'),
            new Text(_user.last_name),
            new Divider(),
            new Text('Email:'),
            new Text(_user.email),
          ],
        )
      ],
    ));
  }
}
