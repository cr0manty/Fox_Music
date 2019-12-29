import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../functions/infoDialog.dart';
import '../utils/urls.dart';

requestRegistration(BuildContext context, String username, String password,
    String userId) async {
  Map<String, String> body = {
    'username': username,
    'password': password,
    'user_id': userId,
  };

  final response = await http.post(
    REGISTRATION_URL,
    body: body,
  );
  try {
    if (response.statusCode == 200) {
      showTextDialog(context, "You have successfully registered!",
          "Now you need to log in.", "OK");
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      showTextDialog(context, "Unable to register",
          "You may have supplied an duplicate 'Username' or 'User Id'.", "OK");
      return false;
    }
  } catch (e) {
    print(e);
    showTextDialog(context, "Unable to register",
        "You may have supplied an duplicate 'Username' or 'User Id'.", "OK");
  }
}
