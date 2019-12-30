import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import 'package:vk_parse/functions/infoDialog.dart';
import 'package:vk_parse/utils/urls.dart';

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
  ).timeout(Duration(seconds: 30));
  try {
    if (response.statusCode == 200) {
      showTextDialog(context, "You have successfully registered!",
          "Now you need to log in.", "OK");
      Navigator.of(context).pushReplacementNamed('/Login');
    } else {
      showTextDialog(context, "Unable to register",
          "You may have supplied an duplicate 'Username' or 'User Id'.", "OK");
      return false;
    }
  } on TimeoutException catch (_) {
    showTextDialog(context, "Server Error", "Can't connect to server", "OK");
    return null;
  } catch (e) {
    print(e);
    showTextDialog(context, "Unable to register",
        "You may have supplied an duplicate 'Username' or 'User Id'.", "OK");
  }
}
