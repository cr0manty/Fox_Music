import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import 'package:vk_parse/functions/utils/infoDialog.dart';
import 'package:vk_parse/utils/urls.dart';

requestRegistration(
    BuildContext context, String username, String password, int userId) async {
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
      infoDialog(context, "You have successfully registered!",
          "Now you need to log in.");
      return true;
    } else {
      infoDialog(context, "Unable to register",
          "You may have supplied an duplicate 'Username' or 'User Id'.");
      return false;
    }
  } on TimeoutException catch (_) {
    infoDialog(context, "Server Error", "Can't connect to server");
    return false;
  } catch (e) {
    print(e);
    infoDialog(context, "Unable to register",
        "You may have supplied an duplicate 'Username' or 'User Id'.");
    return false;
  }
}
