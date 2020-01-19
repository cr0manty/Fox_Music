import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:vk_parse/utils/urls.dart';
import 'package:vk_parse/functions/format/headersToken.dart';
import 'package:vk_parse/models/User.dart';
import 'package:vk_parse/functions/get/getToken.dart';

requestProfileGet(String token, {int friendId}) async {
  try {
    final String profileUrl =
        PROFILE_URL + (friendId != null ? '?user_id=$friendId' : '');
    final response = await http
        .get(
          profileUrl,
          headers: formatToken(token),
        )
        .timeout(Duration(seconds: 30));
    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      responseJson['token'] = token;

      var user = User.fromJson(responseJson);
      if (user != null) {
        return user;
      }
    }
  } on TimeoutException catch (_) {} catch (e) {
    print(e);
  }
}

requestProfilePost({body}) async {
  try {
    final String token = await getToken();
    final String profileUrl = PROFILE_URL;
    final response = await http
        .post(profileUrl, headers: formatToken(token), body: body)
        .timeout(Duration(seconds: 30));
    return response.statusCode == 200;
  } on TimeoutException catch (_) {
    return false;
  } catch (e) {
    print(e);
    return false;
  }
}
