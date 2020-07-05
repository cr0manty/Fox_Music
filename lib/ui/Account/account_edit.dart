import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fox_music/instances/key.dart';
import 'package:fox_music/utils/help.dart';
import 'package:fox_music/widgets/apple_text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:fox_music/instances/account_data.dart';

class AccountEditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AccountEditPageState();
}

class AccountEditPageState extends State<AccountEditPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameFilter = TextEditingController();
  final TextEditingController _lastNameFilter = TextEditingController();
  final TextEditingController _emailFilter = TextEditingController();
  final TextEditingController _passwordConfirmFilter = TextEditingController();
  final TextEditingController _usernameFilter = TextEditingController();
  final TextEditingController _passwordFilter = TextEditingController();
  String _firstName = "";
  String _lastName = "";
  String _email = "";
  String _passwordConfirm = "";
  String _username = "";
  String _password = "";
  File _image;
  bool _updating = false;

  AccountEditPageState() {
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

  _setFilter() {
    _usernameFilter.text = AccountData.instance.user.username;
    _emailFilter.text = AccountData.instance.user.email;
    _firstNameFilter.text = AccountData.instance.user.first_name;
    _lastNameFilter.text = AccountData.instance.user.last_name;
  }

  @override
  Widget build(BuildContext context) {
    _setFilter();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
          actionsForegroundColor: Color.fromRGBO(193, 39, 45, 1),
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
                    HelpTools.infoDialog(context, 'Oops...', 'Passwords do not match');
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
                AccountData.instance.updateUserData(data);
                Navigator.of(context).pop();
              }
            },
          )),
      child: SafeArea(
          child: Material(color: Colors.transparent, child: _buildSelfEdit())),
    );
  }

  _changeAreaForm() {
    return [
      AppleTextInput(
        controller: _firstNameFilter,
        labelText: 'First name',
        hintText: 'Enter first name',
      ),
      Divider(height: 10, color: Colors.transparent),
      AppleTextInput(
        controller: _lastNameFilter,
        labelText: 'Last name',
        hintText: 'Enter last name',
      ),
      Divider(height: 10, color: Colors.transparent),
      AppleTextInput(
        controller: _emailFilter,
        labelText: 'Email',
        hintText: 'Enter email',
      ),
      Divider(height: 10, color: Colors.transparent),
      AppleTextInput(
        controller: _usernameFilter,
        labelText: 'Username',
        hintText: 'Enter username',
      ),
      Divider(height: 10, color: Colors.transparent),
      AppleTextInput(
        controller: _passwordFilter,
        labelText: 'Password',
        hintText: 'Enter password',
        validator: (value) {
          if (value.isNotEmpty) {
            if (value.length < 8) {
              return 'Password must be more than 8 characters';
            }
          }
          return null;
        },
      ),
      Divider(height: 10, color: Colors.transparent),
      AppleTextInput(
        controller: _passwordConfirmFilter,
        labelText: 'Password confirm',
        hintText: 'Confirm password',
      ),
      SizedBox(height: 50)
    ];
  }

  _buildSelfEdit() {
    return Container(
        child: SingleChildScrollView(
            padding: EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                    padding: EdgeInsets.only(bottom: 20, top: 15),
                    child: GestureDetector(
                      onTap: () {
                        FocusScope.of(context)
                            .requestFocus(FocusNode());
                        showCupertinoModalPopup(
                            context: context,
                            builder: (context) {
                              return CupertinoActionSheet(
                                actions: <Widget>[
                                  CupertinoActionSheetAction(
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        _image = await ImagePicker.pickImage(
                                            source: ImageSource.camera);
                                        AccountData.instance
                                            .setNewImage(_image);
                                      },
                                      child: Text('Camera',
                                          style:
                                              TextStyle(color: Colors.blue))),
                                  CupertinoActionSheetAction(
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        _image = await ImagePicker.pickImage(
                                            source: ImageSource.gallery);
                                        AccountData.instance
                                            .setNewImage(_image);
                                      },
                                      child: Text('Gallery',
                                          style: TextStyle(color: Colors.blue)))
                                ],
                              );
                            });
                      },
                      child: Stack(children: <Widget>[
                        ClipOval(
                            child: CircleAvatar(
                                radius: 75,
                                backgroundColor: Colors.grey,
                                backgroundImage: AccountData
                                            .instance.newImage !=
                                        null
                                    ? Image.file(AccountData.instance.newImage)
                                        .image
                                    : Image.network(AccountData.instance.user
                                            .imageUrl())
                                        .image)),
                        ClipOval(
                            child: Container(
                          height: 150,
                          width: 150,
                          color: Colors.black54,
                          child: Icon(CupertinoIcons.photo_camera,
                              color: Colors.white, size: 75),
                        )),
                      ]),
                    )),
                Divider(height: 10),
                ModalProgressHUD(
                    progressIndicator: CupertinoActivityIndicator(),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(8.0),
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
