import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:vk_parse/models/User.dart';
import 'package:vk_parse/functions/saveLogin.dart';
import 'package:vk_parse/utils/urls.dart';
import 'package:vk_parse/functions/infoDialog.dart';
import 'package:vk_parse/functions/formatToken.dart';

Future<User> requestProfile(BuildContext context, String token) async {
  final response = await http.get(
    PROFILE_URL,
    headers: formatToken(token),
  ).timeout(Duration(seconds: 30));
  try {
    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      responseJson['token'] = token;
      var user = new User.fromJson(responseJson);

      saveCurrentLogin(responseJson);
      Navigator.of(context).pushReplacementNamed('/MusicListRequest');

      return user;
    } else {
      return null;
    }
  } on TimeoutException catch (_) {
    showTextDialog(context, "Server Error", "Can't connect to server", "OK");
    return null;
  } catch (e) {
    print(e);
    showTextDialog(
        context, "Unable to Login", "Cant get user profile info.", "OK");
  }
}
