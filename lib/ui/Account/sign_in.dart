import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fox_music/provider/api.dart';
import 'package:fox_music/provider/shared_prefs.dart';
import 'package:fox_music/ui/Account/sign_up.dart';
import 'package:fox_music/utils/bottom_route.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:fox_music/provider/account_data.dart';
import 'package:fox_music/functions/utils/info_dialog.dart';
import 'package:fox_music/provider/download_data.dart';
import 'package:fox_music/widgets/apple_text.dart';
import 'package:fox_music/utils/hex_color.dart';

class SignIn extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SignInState();
}

enum FormType { login, register }

class SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameFilter = TextEditingController();
  final TextEditingController _passwordFilter = TextEditingController();
  String _username = "";
  String _password = "";
  bool _obscureText = true;
  bool _disabled = false;

  @override
  Widget build(BuildContext context) {
    MusicDownloadData downloadData = Provider.of<MusicDownloadData>(context);

    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(middle: Text('Auth')),
        child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: ModalProgressHUD(
                progressIndicator: CupertinoActivityIndicator(),
                child: SafeArea(
                    child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView(
                    children: <Widget>[
                      Center(
                          child: Container(
                              height: MediaQuery.of(context).size.height * 0.25,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/app-logo.png'))))),
                      _buildForm(),
                      _buildButtons(downloadData),
                    ],
                  ),
                )),
                inAsyncCall: _disabled)));
  }

  Widget _buildForm() {
    return Form(
        key: _formKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
            ]));
  }

  _setButtonStatus() {
    setState(() {
      _disabled = !_disabled;
    });
  }

  Widget _buildButtons(MusicDownloadData downloadData) {
    return Align(
        alignment: FractionalOffset.bottomCenter,
        child: Column(children: <Widget>[
          Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 5),
              child: CupertinoButton(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                color: HexColor.main(),
                onPressed: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  if (_formKey.currentState.validate()) {
                    _loginPressed(downloadData);
                  }
                },
                child: Text('Login', style: TextStyle(color: Colors.white)),
              )),
          FlatButton(
              child: Text(
                "Don't have an account? Sign up.",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: _disabled
                  ? null
                  : () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      Navigator.of(context, rootNavigator: true)
                          .push(BottomRoute(page: SignUp()));
                    }),
        ]));
  }

  _loginPressed(MusicDownloadData downloadData) async {
    _setButtonStatus();
    final user = await Api.loginPost(_username, _password);
    if (user != null) {
      downloadData.loadMusic();
      AccountData.instance.user = user;
      SharedPrefs.saveUser(user);
    } else {
      infoDialog(context, "Unable to Login",
          "You may have supplied an invalid 'Username'/'Password' combination.");
    }
    _setButtonStatus();
  }
}
