import 'package:fox_music/functions/format/token.dart';
import 'package:fox_music/functions/get/token.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:fox_music/api/profile.dart';
import 'package:fox_music/utils/urls.dart';

vkAuth(String username, String password, String sid, String captcha) async {
  final token = await getToken();
  Map<String, String> body = {
    'username': username,
    'password': password,
  };
  if (sid != null && captcha != null) {
    body['sid'] = sid;
    body['captcha'] = captcha;
  }
  Map<String, dynamic> status = {'code': 0};
  try {
    final response = await http
        .post(VK_AUTH_URL, body: body, headers: formatToken(token))
        .timeout(Duration(seconds: 30));
    status['code'] = response.statusCode;
    if (response.statusCode == 200) {
      await profileGet();
    } else if (response.statusCode == 302) {
      var data = json.decode(response.body) as Map<String, dynamic>;
      status['url'] = data['url'];
      status['sid'] = data['sid'];
    }
  } on TimeoutException catch (_) {} catch (e) {
    print(e);
  }
  return status;
}
