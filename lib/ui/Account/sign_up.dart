import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fox_music/instances/api.dart';
import 'package:fox_music/instances/key.dart';
import 'package:fox_music/utils/utils.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:fox_music/widgets/apple_text.dart';
import 'package:fox_music/utils/hex_color.dart';

class SignUp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SignUpState();
}

class SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameFilter = TextEditingController();
  final TextEditingController _lastNameFilter = TextEditingController();
  final TextEditingController _usernameFilter = TextEditingController();
  final TextEditingController _passwordFilter = TextEditingController();
  final TextEditingController _passwordConfirm = TextEditingController();
  String _firstName = "";
  String _lastName = "";
  String _username = "";
  String _password = "";
  bool _obscureText = true;
  bool _disabled = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Sign Up'),
          actionsForegroundColor: HexColor.main(),
          previousPageTitle: 'Back',
        ),
        child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: ModalProgressHUD(
                progressIndicator: CupertinoActivityIndicator(),
                child: SafeArea(
                    child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Center(
                          child: Container(
                              height: MediaQuery.of(context).size.height * 0.25,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/app-logo.png'))))),
                      _buildForm(),
                      _buildButtons(),
                      SizedBox(height: 30)
                    ],
                  ),
                )),
                inAsyncCall: _disabled)));
  }

  _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
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
                  return "Last name can't be empty";
                }
                return null;
              },
              inputAction: TextInputAction.continueAction,
            ),
            Divider(height: 20, color: Colors.transparent),
            AppleTextInput(
              controller: _usernameFilter,
              hintText: 'Enter your username',
              labelText: 'Username',
              validator: (value) {
                if (value.isEmpty) {
                  return "Username can't be empty";
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
                  return "Password can't be empty";
                }
                if (value != _passwordConfirm.text) {
                  return "Password does not match";
                }
                return null;
              },
              suffixIcon: _password.isEmpty
                  ? null
                  : GestureDetector(
                      child: Icon(
                          _obscureText
                              ? Icons.remove_red_eye
                              : Icons.visibility_off,
                          color: HexColor.icon()),
                      onTap: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      }),
              inputAction: TextInputAction.send,
            ),
            Divider(height: 20, color: Colors.transparent),
            AppleTextInput(
              controller: _passwordConfirm,
              hintText: 'Confirm your password',
              obscureText: _obscureText,
              labelText: 'Confirm password',
              validator: (value) {
                if (value != _passwordFilter.text) {
                  return "Password does not match";
                }
                return null;
              },
              suffixIcon: _password.isEmpty
                  ? null
                  : GestureDetector(
                      child: Icon(
                          _obscureText
                              ? Icons.remove_red_eye
                              : Icons.visibility_off,
                          color: HexColor.icon()),
                      onTap: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      }),
              inputAction: TextInputAction.send,
            ),
          ]),
    );
  }

  _setButtonStatus() {
    setState(() {
      _disabled = !_disabled;
    });
  }

  Widget _buildButtons() {
    return Align(
        alignment: FractionalOffset.bottomCenter,
        child: Column(children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 30, bottom: 5),
            child: CupertinoButton(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
              color: HexColor.main(),
              onPressed: () {
                FocusScope.of(context).requestFocus(FocusNode());
                if (_formKey.currentState.validate()) {
                  _createAccountPressed();
                }
              },
              child: Text('Create', style: TextStyle(color: Colors.white)),
            ),
          ),
        ]));
  }

  _createAccountPressed() async {
    _setButtonStatus();
    final reg =
        await Api.registrationPost(_username, _password, _firstName, _lastName);
    if (reg != null) {
      Utils.infoDialog(context,
          "You have successfully registered!", "Now you need to log in.");
      Navigator.of(context).pop();
    } else {
      Utils.infoDialog(context, "Unable to register",
          "Not all data was entered or you may have supplied an duplicate 'Username'");
    }
    _setButtonStatus();
  }
}
