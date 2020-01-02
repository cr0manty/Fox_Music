import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import 'package:vk_parse/functions/infoDialog.dart';
import 'package:vk_parse/utils/urls.dart';

requestRegistration(BuildContext context, String username, String password,
    int userId) async {
  Map<String, dynamic> body = {
    'username': username,
    'password': password,
    'user_id': userId,
  };
  try {
    final response = await http
        .post(
          REGISTRATION_URL,
          body: body,
        )
        .timeout(Duration(seconds: 30));
    if (response.statusCode == 200) {
      showTextDialog(context, "You have successfully registered!",
          "Now you need to log in.", "OK");
      return true;
    } else {
      showTextDialog(context, "Unable to register",
          "You may have supplied an duplicate 'Username' or 'User Id'.", "OK");
      return false;
    }
  } on TimeoutException catch (_) {
    showTextDialog(context, "Server Error", "Can't connect to server", "OK");
    return false;
  } catch (e) {
    print(e);
    showTextDialog(context, "Unable to register",
        "You may have supplied an duplicate 'Username' or 'User Id'.", "OK");
    return false;
  }
}
