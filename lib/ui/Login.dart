import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:vk_parse/api/requestLogin.dart';
import 'package:vk_parse/api/requestRegistration.dart';
import 'package:vk_parse/functions/save/saveCurrentRoute.dart';
import 'package:vk_parse/functions/utils/infoDialog.dart';
import 'package:vk_parse/utils/routes.dart';

class Login extends StatefulWidget {
  final AudioPlayer _audioPlayer;

  Login(this._audioPlayer);

  @override
  State<StatefulWidget> createState() => new LoginState(_audioPlayer);
}

enum FormType { login, register }

class LoginState extends State<Login> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _firstNameFilter = new TextEditingController();
  final TextEditingController _lastNameFilter = new TextEditingController();
  final TextEditingController _emailFilter = new TextEditingController();
  final TextEditingController _usernameFilter = new TextEditingController();
  final TextEditingController _passwordFilter = new TextEditingController();
  final AudioPlayer _audioPlayer;
  String _firstName = "";
  String _lastName = "";
  String _email = "";
  String _username = "";
  String _password = "";
  FormType _form = FormType
      .login; // our default setting is to login, and we should switch to creating an account when the user chooses to
  bool _disabled = false;

  LoginState(this._audioPlayer) {
    saveCurrentRoute();
    _lastNameFilter.addListener(_lastNameListen);
    _firstNameFilter.addListener(_firstNameListen);
    _emailFilter.addListener(_emailListen);
    _usernameFilter.addListener(_usernameListen);
    _passwordFilter.addListener(_passwordListen);
  }

  void _lastNameListen() {
    if (_lastNameFilter.text.isEmpty) {
      _lastName = "";
    } else {
      _lastName = _lastNameFilter.text;
    }
  }

  void _firstNameListen() {
    if (_firstNameFilter.text.isEmpty) {
      _firstName = "";
    } else {
      _firstName = _firstNameFilter.text;
    }
  }

  void _usernameListen() {
    if (_usernameFilter.text.isEmpty) {
      _username = "";
    } else {
      _username = _usernameFilter.text;
    }
  }

  void _passwordListen() {
    if (_passwordFilter.text.isEmpty) {
      _password = "";
    } else {
      _password = _passwordFilter.text;
    }
  }

  void _emailListen() {
    if (_emailFilter.text.isEmpty) {
      _email = "";
    } else {
      _email = _emailFilter.text;
    }
  }

  void _formChange() async {
    setState(() {
      if (_form == FormType.register) {
        _form = FormType.login;
      } else {
        _form = FormType.register;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        key: _scaffoldKey,
        appBar: _buildBar(context),
        body: ModalProgressHUD(
            child: new Container(
              padding: EdgeInsets.all(16.0),
              child: new Column(
                children: <Widget>[
                  _buildTextFields(),
                  _buildButtons(),
                ],
              ),
            ),
            inAsyncCall: _disabled));
  }

  Widget _buildBar(BuildContext context) {
    return new AppBar(
      title: new Text("Auth"),
      centerTitle: true,
    );
  }

  Widget _buildTextFields() {
    return new Container(
      child: new Column(
        children: <Widget>[
          new Container(
            child: new TextField(
              controller: _usernameFilter,
              decoration: new InputDecoration(labelText: 'Login'),
            ),
          ),
          new Container(
            child: new TextField(
              controller: _passwordFilter,
              decoration: new InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  _setButtonStatus() {
    setState(() {
      _disabled = !_disabled;
    });
  }

  Widget _buildButtons() {
    if (_form == FormType.login) {
      return new Container(
        child: new Column(
          children: <Widget>[
            new RaisedButton(
                child: new Text('Login'),
                onPressed: _disabled ? null : () => _loginPressed()),
            new FlatButton(
              child: new Text('Dont have an account? Tap here to register.'),
              onPressed: _disabled ? null : () => _formChange(),
            ),
          ],
        ),
      );
    } else {
      return new Container(
        child: new Column(
          children: <Widget>[
            new Container(
              child: new TextField(
                controller: _emailFilter,
                decoration: new InputDecoration(labelText: 'Email'),
              ),
            ),
            new Container(
              child: new TextField(
                controller: _firstNameFilter,
                decoration: new InputDecoration(labelText: 'First name'),
              ),
            ),
            new Container(
              child: new TextField(
                controller: _lastNameFilter,
                decoration: new InputDecoration(labelText: 'Last name'),
              ),
            ),
            new RaisedButton(
                child: new Text('Create an Account'),
                onPressed: _disabled ? null : () => _createAccountPressed()),
            new FlatButton(
              child: new Text('Have an account? Click here to login.'),
              onPressed: _disabled ? null : _formChange,
            )
          ],
        ),
      );
    }
  }

  _loginPressed() async {
    _setButtonStatus();
    final login = await requestLogin(_username, _password);
    if (login != null) {
      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) =>
              switchRoutes(_audioPlayer, route: 1)));
    } else {
      infoDialog(context, "Unable to Login",
          "You may have supplied an invalid 'Username' / 'Password' combination.");
    }
    _setButtonStatus();
  }

  _createAccountPressed() async {
    _setButtonStatus();
    final reg = await requestRegistration(
        _username, _password, _email, _firstName, _lastName);
    if (reg != null) {
      infoDialog(context, "You have successfully registered!",
          "Now you need to log in.");
      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => switchRoutes(_audioPlayer)));
    } else {
      infoDialog(context, "Unable to register",
          "Not all data was entered or you may have supplied an duplicate 'Username'");
    }
    _setButtonStatus();
  }
}
