import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

import 'package:vk_parse/models/AccountData.dart';
import 'package:vk_parse/models/MusicData.dart';
import 'package:vk_parse/functions/utils/infoDialog.dart';
import 'package:vk_parse/ui/FriendListPage.dart';
import 'package:vk_parse/ui/VKMusicListPage.dart';
import 'package:vk_parse/utils/urls.dart';

class AccountPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameFilter = new TextEditingController();
  final TextEditingController _lastNameFilter = new TextEditingController();
  final TextEditingController _emailFilter = new TextEditingController();
  final TextEditingController _passwordConfirmFilter =
      new TextEditingController();
  final TextEditingController _usernameFilter = new TextEditingController();
  final TextEditingController _passwordFilter = new TextEditingController();
  String _firstName = "";
  String _lastName = "";
  String _email = "";
  String _passwordConfirm = "";
  String _username = "";
  String _password = "";
  File _image;
  bool _updating = false;

  AccountPage() {
    _lastNameFilter.addListener(_lastNameListen);
    _firstNameFilter.addListener(_firstNameListen);
    _emailFilter.addListener(_emailListen);
    _passwordConfirmFilter.addListener(_passwordConfirmListen);
    _usernameFilter.addListener(_usernameListen);
    _passwordFilter.addListener(_passwordListen);
  }

  void _lastNameListen() {
    if (_lastNameFilter.text.isEmpty) {
      _lastName = null;
    } else {
      _lastName = _lastNameFilter.text;
    }
  }

  void _firstNameListen() {
    if (_firstNameFilter.text.isEmpty) {
      _firstName = null;
    } else {
      _firstName = _firstNameFilter.text;
    }
  }

  void _emailListen() {
    if (_emailFilter.text.isEmpty) {
      _email = null;
    } else {
      _email = _emailFilter.text;
    }
  }

  void _usernameListen() {
    if (_usernameFilter.text.isEmpty) {
      _username = null;
    } else {
      _username = _usernameFilter.text;
    }
  }

  void _passwordListen() {
    if (_passwordFilter.text.isEmpty) {
      _password = null;
    } else {
      _password = _passwordFilter.text;
    }
  }

  void _passwordConfirmListen() {
    if (_passwordConfirmFilter.text.isEmpty) {
      _passwordConfirm = null;
    } else {
      _passwordConfirm = _passwordConfirmFilter.text;
    }
  }

  _setFilter(AccountData data) {
    _usernameFilter.text = data.user.username;
    _emailFilter.text = data.user.email;
    _firstNameFilter.text = data.user.first_name;
    _lastNameFilter.text = data.user.last_name;
  }

  @override
  Widget build(BuildContext context) {
    final _data = Provider.of<AccountData>(context);
    final musicData = Provider.of<MusicData>(context);
    if (_data.accountType == AccountType.SELF_EDIT) {
      _setFilter(_data);
    }
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      key: _scaffoldKey,
      appBar: new AppBar(
          title: Text(_data.accountType == AccountType.SELF_EDIT
              ? 'Profile edit'
              : 'Profile'),
          centerTitle: true,
          actions: _data.accountType == AccountType.SELF_EDIT
              ? [
                  IconButton(
                    icon: Icon(Icons.done),
                    onPressed: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      if (_formKey.currentState.validate()) {
                        if (_password.isNotEmpty) {
                          if (_password != _passwordConfirm) {
                            infoDialog(
                                context, 'Oops...', 'Passwords do not match');
                          }
                        }
                        var data = {
                          'image': _image,
                          'first_name': _firstName,
                          'last_name': _lastName,
                          'email': _email,
                          'password': _password,
                          'username': _username
                        };
                        _data.updateUserData(data);
                      }
                    },
                  ),
                  IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        _data.setNewImage(null);
                        _data.changeAccountState();
                      })
                ]
              : null),
      body: _switchBuilders(_data, musicData),
    );
  }

  _buildSelfShow(AccountData _data, MusicData musicData) {
    return Container(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
                                _data.changeAccountState();
                                Navigator.pop(context);
                              },
                              child: Text('Edit')),
                          CupertinoActionSheetAction(
                              onPressed: () async {
                                await _data.makeLogout();
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Logout',
                                style: TextStyle(color: Colors.red),
                              ))
                        ],
                      );
                    });
              },
              child: ClipOval(
                  child: CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.grey,
                      backgroundImage:
                          Image.network(BASE_URL + _data.user.image).image)),
            )),
        Padding(
            padding: EdgeInsets.only(bottom: 25),
            child: new Text(
                _data.user.last_name.isEmpty && _data.user.first_name.isEmpty
                    ? ''
                    : '${_data.user.first_name} ${_data.user.last_name}',
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white))),
        _buildTabList(_data, musicData),
      ],
    ));
  }

  _buildTabList(AccountData _data, MusicData musicData) {
    return Expanded(
        child: Padding(
            padding: EdgeInsets.all(10),
            child: ListView(
              children: [
                Card(
                    child: ListTile(
                  leading: Icon(Icons.search, color: Colors.white),
                  title: Text(
                    'Search',
                    style: TextStyle(color: Colors.white),
                  ),
                )),
                Card(
                    child: ListTile(
                  leading: Icon(Icons.people, color: Colors.white),
                  onTap: () {
                    Navigator.of(_scaffoldKey.currentContext).push(
                        MaterialPageRoute(
                            builder: (context) =>
                                ChangeNotifierProvider<MusicData>.value(
                                    value: musicData,
                                    child: FriendListPage())));
                  },
                  title: Text(
                    'Friends',
                    style: TextStyle(color: Colors.white),
                  ),
                )),
                Card(
                    child: ListTile(
                  leading: Icon(Icons.file_download, color: Colors.white),
                  title: Text(
                    'Download all',
                    style: TextStyle(color: Colors.white),
                  ),
                ))
              ],
            )));
  }

  _changeAreaForm() {
    return [
      TextFormField(
        controller: _firstNameFilter,
        decoration: InputDecoration(
          labelText: 'First name',
        ),
      ),
      TextFormField(
        controller: _lastNameFilter,
        decoration: InputDecoration(
          labelText: 'Last name',
        ),
      ),
      TextFormField(
        controller: _emailFilter,
        decoration: InputDecoration(
          labelText: 'Email',
        ),
      ),
      TextFormField(
        controller: _usernameFilter,
        decoration: InputDecoration(
          labelText: 'Username',
        ),
      ),
      TextFormField(
        controller: _passwordFilter,
        decoration: InputDecoration(
          labelText: 'Password',
        ),
        validator: (value) {
          if (value.isNotEmpty) {
            if (value.length < 8) {
              return 'Password must be more than 8 characters';
            }
          }
          return null;
        },
      ),
      TextFormField(
        controller: _passwordConfirmFilter,
        decoration: InputDecoration(
          labelText: 'Password confirm',
        ),
      ),
    ];
  }

  _buildSelfEdit(AccountData _data) {
    return Container(
        child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                    padding: EdgeInsets.only(bottom: 15, top: 15),
                    child: GestureDetector(
                      onTap: () {
                        FocusScope.of(_scaffoldKey.currentContext)
                            .requestFocus(FocusNode());
                        showCupertinoModalPopup(
                            context: _scaffoldKey.currentContext,
                            builder: (context) {
                              return CupertinoActionSheet(
                                title: Text('Choose image from...'),
                                actions: <Widget>[
                                  CupertinoActionSheetAction(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        _image = await ImagePicker.pickImage(
                                            source: ImageSource.camera);
                                        _data.setNewImage(_image);
                                      },
                                      child: Text('Camera')),
                                  CupertinoActionSheetAction(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        _image = await ImagePicker.pickImage(
                                            source: ImageSource.gallery);
                                      },
                                      child: Text(
                                        'Gallery',
                                      ))
                                ],
                              );
                            });
                      },
                      child: ClipOval(
                          child: CircleAvatar(
                              radius: 100,
                              backgroundColor: Colors.grey,
                              backgroundImage: _data.newImage != null
                                  ? Image.file(_data.newImage).image
                                  : Image.network(BASE_URL + _data.user.image)
                                      .image)),
                    )),
                Divider(height: 10),
                Text(
                  'Login and password must match your VK account',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                ModalProgressHUD(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16.0),
                      child: Form(
                          key: _formKey,
                          child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _changeAreaForm())),
                    ),
                    inAsyncCall: _updating)
              ],
            )));
  }

  _switchBuilders(AccountData _data, MusicData musicData) {
    switch (_data.accountType) {
      case AccountType.SELF_EDIT:
        return _buildSelfEdit(_data);
      default:
        return _buildSelfShow(_data, musicData);
    }
  }
}
