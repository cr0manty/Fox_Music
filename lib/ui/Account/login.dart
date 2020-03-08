import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:fox_music/provider/account_data.dart';
import 'package:fox_music/api/login.dart';
import 'package:fox_music/functions/utils/info_dialog.dart';
import 'package:fox_music/provider/download_data.dart';
import 'package:fox_music/utils/apple_text.dart';
import 'package:fox_music/utils/hex_color.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new LoginPageState();
}

enum FormType { login, register }

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameFilter = new TextEditingController();
  final TextEditingController _lastNameFilter = new TextEditingController();
  final TextEditingController _usernameFilter = new TextEditingController();
  final TextEditingController _passwordFilter = new TextEditingController();
  String _firstName = "";
  String _lastName = "";
  String _username = "";
  String _password = "";
  FormType _form = FormType.login;
  bool _obscureText = true;
  bool _disabled = false;

  _clearFiller() {
    _usernameFilter.text = "";
    _passwordFilter.text = "";
    _firstNameFilter.text = "";
    _lastNameFilter.text = "";
    _firstName = "";
    _lastName = "";
    _username = "";
    _password = "";
  }

  void _formChange() async {
    setState(() {
      _clearFiller();
      _formKey.currentState.reset();
      if (_form == FormType.register) {
        _form = FormType.login;
      } else {
        _form = FormType.register;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    AccountData accountData = Provider.of<AccountData>(context);
    MusicDownloadData downloadData = Provider.of<MusicDownloadData>(context);

    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(middle: Text('Auth')),
        child: ModalProgressHUD(
            child: SafeArea(
                child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Center(
                      child: Container(
                          height: MediaQuery.of(context).size.height * 0.3,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(
                                      'assets/images/app-logo.png'))))),
                  _buildForm(),
                  _buildButtons(accountData, downloadData),
                ],
              ),
            )),
            inAsyncCall: _disabled));
  }

  List<Widget> _loginAreaForm() {
    return <Widget>[
      AppleTextInput(
        controller: _usernameFilter,
        hintText: 'Enter your username',
        labelText: 'Username',
        validator: (value) {
          if (value.isEmpty) {
            return "First name can't be empty";
          }
          return null;
        },
        onChanged: (text) {
          setState(() {
            _username = text;
          });
        },
        inputAction: TextInputAction.continueAction,
      ),
      Divider(height: 20, color: Colors.transparent),
      AppleTextInput(
        controller: _passwordFilter,
        hintText: 'Enter your password',
        obscureText: _obscureText,
        labelText: 'Password',
        onChanged: (text) {
          setState(() {
            _password = text;
          });
        },
        validator: (value) {
          if (value.isEmpty) {
            return "First name can't be empty";
          }
          return null;
        },
        suffixIcon: _password.isEmpty
            ? null
            : GestureDetector(
                child: Icon(
                    _obscureText ? Icons.remove_red_eye : Icons.visibility_off,
                    color: HexColor('#8c8c8c')),
                onTap: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                }),
        inputAction: TextInputAction.send,
      ),
    ];
  }

  List<Widget> _registrationAreaForm() {
    return <Widget>[
          AppleTextInput(
            controller: _firstNameFilter,
            hintText: 'Enter your first name',
            labelText: 'First name',
            onChanged: (text) {
              setState(() {
                _firstName = text;
              });
            },
            validator: (value) {
              if (value.isEmpty) {
                return "First name can't be empty";
              }
              return null;
            },
            inputAction: TextInputAction.continueAction,
          ),
          Divider(height: 20, color: Colors.transparent),
          AppleTextInput(
            controller: _lastNameFilter,
            hintText: 'Enter your last name',
            labelText: 'Last name',
            onChanged: (text) {
              setState(() {
                _lastName = text;
              });
            },
            validator: (value) {
              if (value.isEmpty) {
                return "First name can't be empty";
              }
              return null;
            },
            inputAction: TextInputAction.continueAction,
          ),
          Divider(height: 20, color: Colors.transparent),
        ] +
        _loginAreaForm();
  }

  _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _form == FormType.login
              ? _loginAreaForm()
              : _registrationAreaForm()),
    );
  }

  _setButtonStatus() {
    setState(() {
      _disabled = !_disabled;
    });
  }

  Widget _buildButtons(
      AccountData accountData, MusicDownloadData downloadData) {
    return Align(
        alignment: FractionalOffset.bottomCenter,
        child: Column(children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 5),
            child: CupertinoButton(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
              color: main_color,
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  if (_form == FormType.login) {
                    _loginPressed(accountData, downloadData);
                  } else {
                    _createAccountPressed();
                  }
                }
              },
              child: Text(_form == FormType.login ? 'Login' : 'Create',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
          FlatButton(
            child: Text(
              _form == FormType.login
                  ? "Don't have an account? Sign up."
                  : 'Have an account? Sign in.',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: _disabled ? null : () => _formChange(),
          ),
        ]));
  }

  _loginPressed(AccountData accountData, MusicDownloadData downloadData) async {
    _setButtonStatus();
    final user = await loginPost(_username, _password);
    if (user != null) {
      await downloadData.loadMusic();
      accountData.setUser(user);
    } else {
      infoDialog(context, "Unable to Login",
          "You may have supplied an invalid 'Username' / 'Password' combination.");
    }
    _setButtonStatus();
  }

  _createAccountPressed() async {
    _setButtonStatus();
    final reg =
        await registrationPost(_username, _password, _firstName, _lastName);
    if (reg != null) {
      infoDialog(context, "You have successfully registered!",
          "Now you need to log in.");
      _formChange();
    } else {
      infoDialog(context, "Unable to register",
          "Not all data was entered or you may have supplied an duplicate 'Username'");
    }
    _setButtonStatus();
  }
}
