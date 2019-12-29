import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/User.dart';
import '../functions/saveLogin.dart';
import '../utils/urls.dart';
import '../functions/infoDialog.dart';

Future<User> requestProfile(BuildContext context, String token) async {
  Map<String, String> headers = {
    'Authorization': "Token $token",
  };

  final response = await http.get(
    PROFILE_URL,
    headers: headers,
  );
  try {
    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      responseJson['token'] = token;
      var user = new User.fromJson(responseJson);

      saveCurrentLogin(responseJson);
      Navigator.of(context).pushReplacementNamed('/home');

      return user;
    } else {
      return null;
    }
  }
  catch (e) {
    print(e);
    showTextDialog(context, "Unable to Login",
          "Cant get user profile info.",
          "OK");
  }
}
