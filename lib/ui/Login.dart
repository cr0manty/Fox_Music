import 'package:flutter/material.dart';

import 'package:vk_parse/api/requestLogin.dart';
import 'package:vk_parse/api/requestRegistration.dart';
import 'package:vk_parse/functions/saveCurrentRoute.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginState();
}

enum FormType { login, register }

class _LoginState extends State<Login> {
  final TextEditingController _loginFilter = new TextEditingController();
  final TextEditingController _passwordFilter = new TextEditingController();
  final TextEditingController _userIDFilter = new TextEditingController();
  String _username = "";
  String _password = "";
  int _userID = 0;
  FormType _form = FormType
      .login; // our default setting is to login, and we should switch to creating an account when the user chooses to

  _LoginState() {
    _loginFilter.addListener(_usernameListen);
    _passwordFilter.addListener(_passwordListen);
    _userIDFilter.addListener(_userIDListen);
  }

  void _usernameListen() {
    if (_loginFilter.text.isEmpty) {
      _username = "";
    } else {
      _username = _loginFilter.text;
    }
  }

  int isNumeric(String str) {
    int value;
    try {
      value = int.parse(str);
    } on FormatException {
      return null;
    }
    return value;
  }

  void _userIDListen() {
    if (_userIDFilter.text.isEmpty) {
      _userID = 0;
    } else {
      _userID = isNumeric(_userIDFilter.text);
    }
  }

  void _passwordListen() {
    if (_passwordFilter.text.isEmpty) {
      _password = "";
    } else {
      _password = _passwordFilter.text;
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
    return new WillPopScope(
      onWillPop: () {
        Navigator.of(context).pushReplacementNamed('/MusicListRequest');
      },
      child: new Scaffold(
        appBar: _buildBar(context),
        body: new Container(
          padding: EdgeInsets.all(16.0),
          child: new Column(
            children: <Widget>[
              _buildTextFields(),
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBar(BuildContext context) {
    return new AppBar(
      title: new Text("Auth Page"),
      centerTitle: true,
    );
  }

  Widget _buildTextFields() {
    return new Container(
      child: new Column(
        children: <Widget>[
          new Container(
            child: new TextField(
              controller: _loginFilter,
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
    saveCurrentRoute("/Login");
  }

  Widget _buildButtons() {
    if (_form == FormType.login) {
      return new Container(
        child: new Column(
          children: <Widget>[
            new RaisedButton(
              child: new Text('Login'),
              onPressed: _loginPressed,
            ),
            new FlatButton(
              child: new Text('Dont have an account? Tap here to register.'),
              onPressed: _formChange,
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
                controller: _userIDFilter,
                decoration: new InputDecoration(labelText: 'User ID'),
                keyboardType: TextInputType.number,
              ),
            ),
            new RaisedButton(
              child: new Text('Create an Account'),
              onPressed: _createAccountPressed,
            ),
            new FlatButton(
              child: new Text('Have an account? Click here to login.'),
              onPressed: _formChange,
            )
          ],
        ),
      );
    }
  }

  void _loginPressed() async {
    print('Login - $_username');
    final login = await requestLogin(context, _username, _password);
    if (login != null) {
      final newRouteName = "/MusicListRequest";
      bool isNewRouteSameAsCurrent = false;

      Navigator.popUntil(context, (route) {
        if (route.settings.name == newRouteName) {
          isNewRouteSameAsCurrent = true;
        }
        return true;
      });

      if (!isNewRouteSameAsCurrent) {
        Navigator.pushNamed(context, newRouteName);
      }
    }
  }

  void _createAccountPressed() {
    print('Registration - $_username, $_userID');
    // TODO: check userID for num only
    final reg = requestRegistration(context, _username, _password, _userID);
    if (reg != null) {
      final newRouteName = "/Login";
      bool isNewRouteSameAsCurrent = false;

      Navigator.popUntil(context, (route) {
        if (route.settings.name == newRouteName) {
          isNewRouteSameAsCurrent = true;
        }
        return true;
      });

      if (!isNewRouteSameAsCurrent) {
        Navigator.pushNamed(context, newRouteName);
      }
    }
  }
}
