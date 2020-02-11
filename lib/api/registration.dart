import 'package:http/http.dart' as http;
import 'dart:async';

import 'package:vk_parse/utils/urls.dart';

registrationPost(String username, String password,
    String firstName, String lastName) async {
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
