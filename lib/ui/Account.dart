import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vk_parse/functions/get/getCurrentUser.dart';
import 'package:vk_parse/functions/save/saveCurrentUser.dart';
import 'package:vk_parse/models/User.dart';

import 'package:vk_parse/widgets/AppBarDrawer.dart';
import 'package:vk_parse/utils/colors.dart';
import 'package:vk_parse/functions/save/saveCurrentRoute.dart';
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

enum AccountType { SELF_SHOW, SELF_EDIT, USER }

enum RelationShipStatus { FRIEND, REQUEST, BLOCK, UNKNOWN, SELF_REQUEST }

class AccountState extends State<Account> {
  final GlobalKey<ScaffoldState> _menuKey = new GlobalKey<ScaffoldState>();
  final AudioPlayer _audioPlayer;
  User _user;
  AccountType _accountType = AccountType.SELF_SHOW;

  File _image;

  AccountState(this._audioPlayer, this._user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _menuKey,
      drawer: AppBarDrawer(_audioPlayer),
      appBar: new AppBar(
          leading: new IconButton(
              icon: new Icon(Icons.menu),
              onPressed: () => _menuKey.currentState.openDrawer()),
          title: Text('User account'),
          centerTitle: true,
          actions: _accountType == AccountType.SELF_SHOW ||
                  _accountType == AccountType.SELF_EDIT
              ? [
                  IconButton(
                    icon: Icon(_accountType == AccountType.SELF_EDIT
                        ? Icons.done
                        : Icons.edit),
                    onPressed: () {
                      setState(() {
                        if (_accountType == AccountType.SELF_EDIT) {
                          _accountType = AccountType.SELF_SHOW;
                          _updateData();
                        } else {
                          _accountType = AccountType.SELF_EDIT;
                        }
                      });
                    },
                  )
                ]
              : null),
      backgroundColor: lightGrey,
      body: _switchBuilders(),
    );
  }

  @override
  void initState() {
    super.initState();

    saveCurrentRoute(route: 2);
  }

  _updateData() async {
    if (_image != null) {
      if (await requestProfilePost(body: {'image': _image})) {
        User user = await requestProfileGet();
        if (user != null) {
          setState(() {
            _user = user;
            saveCurrentUser(_user);
          });
        }
      }
    }
  }

  _buildSelfShow() {
    return Container(
        child: Column(
      children: [
        new Padding(
            padding: EdgeInsets.only(top: 20, left: 20, bottom: 20),
            child: new CircleAvatar(
                radius: 100,
                backgroundColor: Colors.grey,
                backgroundImage:
                    new Image.network(BASE_URL + _user.image).image)),
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

  _buildSelfEdit() {
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
                  var imageFile;
                  chooseDialog(_menuKey.currentContext, 'Upload photo from...',
                      'Gallery', 'Take photo', firstFunction: () async {
                    _image = await ImagePicker.pickImage(
                        source: ImageSource.gallery);
                  }, secondFunction: () async {
                    _image =
                        await ImagePicker.pickImage(source: ImageSource.camera);
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

  _buildUser() {}

  _switchBuilders() {
    switch (_accountType) {
      case AccountType.SELF_SHOW:
        return _buildSelfShow();
      case AccountType.SELF_EDIT:
        return _buildSelfEdit();
      case AccountType.USER:
        return _buildUser();
    }
  }
}
