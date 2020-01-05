import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:vk_parse/utils/urls.dart';
import 'package:vk_parse/models/Database.dart';
import 'package:vk_parse/models/User.dart';

requestRegistration(String username, String password) async {
  Map<String, dynamic> body = {
    'username': username,
    'password': password,
  };
  try {
    final response = await http
        .post(
          REGISTRATION_URL,
          body: body,
        )
        .timeout(Duration(seconds: 60));
    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      if (await DBProvider.db.newUser(new User.fromJson(responseJson)) !=
          null) {
        return true;
      }
    }
  } on TimeoutException catch (_) {} catch (e) {
    print(e);
  }
}
