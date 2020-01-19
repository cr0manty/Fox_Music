import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:vk_parse/api/requestProfile.dart';
import 'package:vk_parse/utils/urls.dart';
import 'package:vk_parse/functions/save/saveCurrentUser.dart';

requestLogin(String username, String password) async {
  Map<String, String> body = {
    'username': username,
    'password': password,
  };
  try {
    final response = await http
        .post(
          AUTH_URL,
          body: body,
        )
        .timeout(Duration(seconds: 30));
    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      final user = await requestProfileGet(responseJson['token']);
      if (user != null) {
        await saveCurrentUser(user);
        return true;
      }
    }
  } on TimeoutException catch (_) {} catch (e) {
    print(e);
  }
}
