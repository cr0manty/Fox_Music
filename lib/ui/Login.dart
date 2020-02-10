import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:vk_parse/models/ProjectData.dart';
import 'package:vk_parse/api/requestLogin.dart';
import 'package:vk_parse/api/requestRegistration.dart';
import 'package:vk_parse/functions/utils/infoDialog.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new LoginState();
}

enum FormType { login, register }

class LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _firstNameFilter = new TextEditingController();
  final TextEditingController _lastNameFilter = new TextEditingController();
  final TextEditingController _emailFilter = new TextEditingController();
  final TextEditingController _usernameFilter = new TextEditingController();
  final TextEditingController _passwordFilter = new TextEditingController();
  String _firstName = "";
  String _lastName = "";
  String _email = "";
  String _username = "";
  String _password = "";
  FormType _form = FormType.login;
  bool _disabled = false;

  LoginState() {
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

  _clearFiller() {
    _usernameFilter.text = "";
    _passwordFilter.text = "";
    _emailFilter.text = "";
    _firstNameFilter.text = "";
    _lastNameFilter.text = "";
  }

  void _formChange() async {
    setState(() {
      _formKey.currentState.reset();
      _clearFiller();
      if (_form == FormType.register) {
        _form = FormType.login;
      } else {
        _form = FormType.register;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final _data = Provider.of<ProjectData>(context);
    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Auth"),
          centerTitle: true,
        ),
        body: ModalProgressHUD(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  _buildForm(),
                  _buildButtons(_data),
                ],
              ),
            ),
            inAsyncCall: _disabled));
  }

  _loginAreaForm() {
    return [
      TextFormField(
        controller: _usernameFilter,
        decoration: InputDecoration(
          labelText: 'Username',
        ),
        validator: (value) {
          if (value.isEmpty) {
            return "Username can't be empty";
          }
          return null;
        },
      ),
      TextFormField(
        controller: _passwordFilter,
        decoration: InputDecoration(
          labelText: 'Password',
        ),
        obscureText: true,
        validator: (value) {
          if (value.isEmpty) {
            return "Passwrod can't be empty";
          } else if (value.length < 8) {
            return 'Password must be more than 8 characters';
          }
          return null;
        },
      )
    ];
  }

  _registrationAreaForm() {
    return [
          TextFormField(
            controller: _firstNameFilter,
            decoration: InputDecoration(
              labelText: 'First name',
            ),
            validator: (value) {
              if (value.isEmpty) {
                return "First name can't be empty";
              }
              return null;
            },
          ),
          TextFormField(
            controller: _lastNameFilter,
            decoration: InputDecoration(
              labelText: 'Last name',
            ),
            validator: (value) {
              if (value.isEmpty) {
                return "Last name can't be empty";
              }
              return null;
            },
          ),
          TextFormField(
            controller: _emailFilter,
            decoration: InputDecoration(
              labelText: 'Email',
            ),
            validator: (value) {
              if (value.isEmpty) {
                return "Email can't be empty";
              }
              return null;
            },
          ),
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

  Widget _buildButtons(data) {
    return Column(children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(top: 30, bottom: 5),
        child: CupertinoButton(
          borderRadius: BorderRadius.all(Radius.circular(50)),
          minSize:  MediaQuery.of(context).size.height * 0.001,
          color: Colors.redAccent,
          onPressed: () {
            if (_formKey.currentState.validate()) {
              if (_form == FormType.login) {
                _loginPressed(data);
              } else {
                _createAccountPressed();
              }
            }
          },
          child: Text(_form == FormType.login ? 'Login' : 'Create an Account'),
        ),
      ),
      FlatButton(
        child: Text(_form == FormType.login
            ? 'Dont have an account? Tap here to register.'
            : 'Have an account? Click here to login.', style: TextStyle(color: Colors.grey),),
        onPressed: _disabled ? null : () => _formChange(),
      ),
    ]);
  }

  _loginPressed(ProjectData data) async {
    _setButtonStatus();
    final user = await requestLogin(_username, _password);
    if (user != null) {
      data.setUser(user);
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
      _formChange();
    } else {
      infoDialog(context, "Unable to register",
          "Not all data was entered or you may have supplied an duplicate 'Username'");
    }
    _setButtonStatus();
  }
}