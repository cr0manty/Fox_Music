import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:vk_parse/functions/saveLogin.dart';
import 'package:vk_parse/utils/urls.dart';
import 'package:vk_parse/functions/infoDialog.dart';
import 'package:vk_parse/functions/headersToken.dart';

requestProfile(BuildContext context, String token) async {
  try {
    final response = await http
        .get(
          PROFILE_URL,
          headers: formatToken(token),
        )
        .timeout(Duration(seconds: 30));
    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      responseJson['token'] = token;

      saveCurrentLogin(responseJson);
      return true;
    } else {
      return false;
    }
  } on TimeoutException catch (_) {
    showTextDialog(context, "Server Error", "Can't connect to server", "OK");
    return false;
  } catch (e) {
    print(e);
    showTextDialog(
        context, "Unable to Login", "Cant get user profile info.", "OK");
    return false;
  }
}
