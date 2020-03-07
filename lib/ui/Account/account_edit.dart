import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:fox_music/functions/format/image.dart';

import 'package:fox_music/provider/account_data.dart';
import 'package:fox_music/functions/utils/info_dialog.dart';

class AccountEditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AccountEditPageState();
}

class AccountEditPageState extends State<AccountEditPage> {
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
    AccountData accountData = Provider.of<AccountData>(context);

    _setFilter(accountData);
    return CupertinoPageScaffold(
      key: _scaffoldKey,
      navigationBar: CupertinoNavigationBar(
          actionsForegroundColor: Colors.redAccent,
          middle: Text('Profile edit'),
          previousPageTitle: 'Back',
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Text(
              'Done',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
            ),
            onPressed: () {
              FocusScope.of(context).requestFocus(FocusNode());
              if (_formKey.currentState.validate()) {
                if (_password.isNotEmpty) {
                  if (_password != _passwordConfirm) {
                    infoDialog(context, 'Oops...', 'Passwords do not match');
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
                accountData.updateUserData(data);
                Navigator.pop(context);
              }
            },
          )),
      child: SafeArea(
          child: Material(
              color: Colors.transparent, child: _buildSelfEdit(accountData))),
    );
  }

  _changeAreaForm() {
    return [
      TextFormField(
        controller: _firstNameFilter,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
            labelText: 'First name',
            labelStyle: TextStyle(color: Colors.white)),
      ),
      TextFormField(
        style: TextStyle(color: Colors.white),
        controller: _lastNameFilter,
        decoration: InputDecoration(
            labelText: 'Last name', labelStyle: TextStyle(color: Colors.white)),
      ),
      TextFormField(
        style: TextStyle(color: Colors.white),
        controller: _emailFilter,
        decoration: InputDecoration(
            labelText: 'Email', labelStyle: TextStyle(color: Colors.white)),
      ),
      TextFormField(
        style: TextStyle(color: Colors.white),
        controller: _usernameFilter,
        decoration: InputDecoration(
            labelText: 'Login', labelStyle: TextStyle(color: Colors.white)),
      ),
      TextFormField(
        style: TextStyle(color: Colors.white),
        controller: _passwordFilter,
        decoration: InputDecoration(
            labelText: 'Password', labelStyle: TextStyle(color: Colors.white)),
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
            labelStyle: TextStyle(color: Colors.white)),
      ),
      SizedBox(height: 30)
    ];
  }

  _buildSelfEdit(AccountData accountData) {
    return Container(
        child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                    padding: EdgeInsets.only(bottom: 20, top: 15),
                    child: GestureDetector(
                      onTap: () {
                        FocusScope.of(_scaffoldKey.currentContext)
                            .requestFocus(FocusNode());
                        showCupertinoModalPopup(
                            context: _scaffoldKey.currentContext,
                            builder: (context) {
                              return CupertinoActionSheet(
                                actions: <Widget>[
                                  CupertinoActionSheetAction(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        _image = await ImagePicker.pickImage(
                                            source: ImageSource.camera);
                                        accountData.setNewImage(_image);
                                      },
                                      child: Text('Camera')),
                                  CupertinoActionSheetAction(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        _image = await ImagePicker.pickImage(
                                            source: ImageSource.gallery);
                                        accountData.setNewImage(_image);
                                      },
                                      child: Text(
                                        'Gallery',
                                      ))
                                ],
                              );
                            });
                      },
                      child: Stack(children: <Widget>[
                        ClipOval(
                            child: CircleAvatar(
                                radius: 75,
                                backgroundColor: Colors.grey,
                                backgroundImage: accountData.newImage != null
                                    ? Image.file(accountData.newImage).image
                                    : Image.network(
                                            formatImage(accountData.user.image))
                                        .image)),
                        ClipOval(
                            child: Container(
                          height: 150,
                          width: 150,
                          color: Colors.black54,
                              child: Icon(CupertinoIcons.photo_camera, color: Colors.white,size: 75),
                        )),
                      ]),
                    )),
                Divider(height: 10),
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
}
