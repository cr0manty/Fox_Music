import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:fox_music/api/profile.dart';
import 'package:fox_music/functions/save/token.dart';
import 'package:fox_music/utils/urls.dart';

loginPost(String username, String password) async {
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
      await saveToken(responseJson['token']);
      final user = await profileGet();
      if (user != null) {
        return user;
      }
    }
  } on TimeoutException catch (_) {} catch (e) {
    print(e);
  }
}

registrationPost(
    String username, String password, String firstName, String lastName) async {
  Map<String, dynamic> body = {
    'username': username,
    'password': password,
    'first_name': firstName,
    'last_name': lastName
  };
  try {
    final response = await http
        .post(
          REGISTRATION_URL,
          body: body,
        )
        .timeout(Duration(seconds: 60));
    if (response.statusCode == 201) {
      return true;
    }
  } on TimeoutException catch (_) {} catch (e) {
    print(e);
  }
}
