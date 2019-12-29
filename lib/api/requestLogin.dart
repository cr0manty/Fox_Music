import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/User.dart';
import '../functions/infoDialog.dart';
import '../api/requestProfile.dart';
import '../utils/urls.dart';


Future<User> requestLogin(BuildContext context, String username, String password) async {

  Map<String, String> body = {
    'username': username,
    'password': password,
  };

  final response = await http.post(
    AUTH_URL,
    body: body,
  );
  try {
    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      return requestProfile(context, responseJson['token']);
    } else {
      showTextDialog(context, "Unable to Login",
          "You may have supplied an invalid 'Username' / 'Password' combination.",
          "OK");
      return null;
    }
  }
  catch (e) {
    print(e);
    showTextDialog(context, "Unable to Login",
          "You may have supplied an invalid 'Username' / 'Password' combination.",
          "OK");
  }
}
