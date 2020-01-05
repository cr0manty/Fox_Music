import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:vk_parse/functions/save/saveCurrentUser.dart';
import 'package:vk_parse/utils/urls.dart';
import 'package:vk_parse/functions/format/headersToken.dart';
import 'package:vk_parse/models/Database.dart';
import 'package:vk_parse/models/User.dart';

requestProfile(String token, {bool update}) async {
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

      var user = await DBProvider.db.getUser(responseJson['id']);
      if (user == null) {
        DBProvider.db.newUser(new User.fromJson(responseJson));
      }
      if (update != null && update) {
        DBProvider.db.updateUser(new User.fromJson(responseJson));
      }
      saveCurrentUser(responseJson['id'], token);
      return true;
    }
  } on TimeoutException catch (_) {} catch (e) {
    print(e);
  }
}
