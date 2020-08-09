import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fox_music/instances/account_data.dart';
import 'package:fox_music/utils/api.dart';
import 'package:fox_music/instances/key.dart';
import 'package:fox_music/utils/help_tools.dart';
import 'package:fox_music/widgets/apple_text.dart';
import 'package:fox_music/utils/hex_color.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class VKAuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => VKAuthState();
}

class VKAuthState extends State<VKAuthPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameFilter = TextEditingController();
  final TextEditingController _passwordFilter = TextEditingController();
  final TextEditingController _captchaController = TextEditingController();
  String _username = "";
  String _password = "";
  bool _obscureText = true;
  bool _disabled = false;

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

  showPickerDialog(Map data) async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Captcha needed'),
          actions: <Widget>[
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: Navigator.of(context).pop,
              child: Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () async {
                Navigator.of(context).pop();
                _loginPressed(
                    sid: data['sid'], captcha: _captchaController.text);
              },
              child: Text('Confirm'),
            )
          ],
          content: Padding(
            padding: EdgeInsets.only(top: 10),
            child: SingleChildScrollView(
                child: Material(
                    color: Colors.transparent,
                    child: Column(children: <Widget>[
                      Container(
                        height: 75,
                        width: 200,
                        child: FittedBox(
                          child: Image.network(data['url']),
                          fit: BoxFit.fill,
                        ),
                      ),
                      Divider(height: 15),
                      CupertinoTextField(
                        controller: _captchaController,
                        placeholder: 'Captcha...',
                        decoration: BoxDecoration(
                            color: HexColor.mainText(),
                            borderRadius: BorderRadius.circular(9)),
                      ),
                    ]))),
          ),
        );
      },
    );
  }

  _loginPressed({String sid, String captcha}) async {
    setState(() => _disabled = true);

    Map authStatus = await Api.vkAuth(_username, _password, sid, captcha);

    if (authStatus['code'] == 302) {
      showPickerDialog(authStatus);
    } else if (authStatus['code'] == 200) {
      await AccountData.instance.getUserProfile();
      Navigator.of(context).pop();
    } else {
      HelpTools.infoDialog(context, 'Smth went wrong', "Can't connect to vk servers");
    }
    setState(() => _disabled = false);
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width * 0.3;
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            middle: Text('VK Auth'), previousPageTitle: 'Back'),
        child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: ModalProgressHUD(
                progressIndicator: CupertinoActivityIndicator(),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      Center(
                          child: Container(
                              height: MediaQuery.of(context).size.height * 0.25,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/app-logo.png'))))),
                      _buildForm(),
                      Container(
                        margin: EdgeInsets.only(
                            top: 30, bottom: 5, left: size, right: size),
                        child: CupertinoButton(
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 30),
                          color: HexColor.main(),
                          onPressed: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            if (_formKey.currentState.validate()) {
                              _loginPressed();
                            }
                          },
                          child: Text('Login',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
                inAsyncCall: _disabled)));
  }
}
