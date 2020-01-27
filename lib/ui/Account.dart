import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:vk_parse/api/requestMusicList.dart';
import 'package:vk_parse/functions/save/saveCurrentUser.dart';
import 'package:vk_parse/functions/utils/infoDialog.dart';
import 'package:vk_parse/models/User.dart';

import 'package:vk_parse/utils/urls.dart';
import 'package:vk_parse/functions/utils/chooseDialog.dart';
import 'package:vk_parse/api/requestProfile.dart';

enum AccountType { SELF_SHOW, SELF_EDIT }

class Account extends StatefulWidget {
  final User _user;
  final User friend;

  Account(this._user, {this.friend});

  @override
  State<StatefulWidget> createState() => new AccountState(_user, friend);
}

class AccountState extends State<Account> {
  final GlobalKey<ScaffoldState> _menuKey = new GlobalKey<ScaffoldState>();
  User _user;
  User friend;
  AccountType _accountType;
  bool _updating = false;
  File _image;

  AccountState(this._user, this.friend) {
    if (friend == null) {
      _accountType = AccountType.SELF_SHOW;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _menuKey,
      appBar: new AppBar(
          title: Text('Profile'),
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
      backgroundColor: Color.fromRGBO(35, 35, 35, 1),
      body: new ModalProgressHUD(
          child: _switchBuilders(), inAsyncCall: _updating),
    );
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

  _setUpdating() {
    setState(() {
      _updating = !_updating;
    });
  }

  _buildSelfShow() {
    return Container(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        new Padding(
            padding: EdgeInsets.only(top: 20, left: 20, bottom: 20),
            child: new CircleAvatar(
                radius: 70,
                backgroundColor: Colors.grey,
                backgroundImage:
                    new Image.network(BASE_URL + _user.image).image)),
        new Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: new Text(
                _user.last_name.isEmpty && _user.first_name.isEmpty
                    ? ''
                    : '${_user.first_name} ${_user.last_name}',
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white))),
        _buildTabList(),
      ],
    ));
  }

  _buildTabList() {
    return new Expanded(
        child: ListView(
      children: [
        Divider(color: Colors.black87),
        ListTile(
          title: Text(
            'VK Music',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        Divider(color: Colors.black87),
        Divider(color: Colors.black87),
        ListTile(
            title: Text(
              'Update music',
              style: TextStyle(color: Colors.grey),
            ),
            onTap: () async {
              try {
                _setUpdating();
                final listNewSong = await requestMusicListPost();
                if (listNewSong != null) {
                  infoDialog(_menuKey.currentContext, "New songs",
                      "${listNewSong['added']} new songs.\n${listNewSong['updated']} updated songs.");
                } else {
                  infoDialog(_menuKey.currentContext, "Something went wrong",
                      "Unable to get Music List.");
                }
              } catch (e) {
                print(e);
              } finally {
                _setUpdating();
              }
            }),
        Divider(color: Colors.black87),
        Divider(color: Colors.black87),
        ListTile(
          title: Text(
            'Friends',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        Divider(color: Colors.black87),
        Divider(color: Colors.black87),
        ListTile(
          title: Text(
            'Search',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        Divider(color: Colors.black87),
        Divider(color: Colors.black87),
        ListTile(
          title: Text(
            'Download all',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        Divider(color: Colors.black87),
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
                child: new Text(
                    _user.username.isEmpty ? 'Unknown' : _user.username,
                    style:
                        TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
            new Divider(),
            new Text('First name:'),
            new Text('Last name:'),
            new Divider(),
            new Text('Email:'),
          ],
        )
      ],
    ));
  }

  _switchBuilders() {
    switch (_accountType) {
      case AccountType.SELF_EDIT:
        return _buildSelfEdit();
      default:
        return _buildSelfShow();
    }
  }
}
