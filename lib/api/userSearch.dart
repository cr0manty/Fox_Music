import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:vk_parse/utils/urls.dart';
import 'package:vk_parse/functions/format/headersToken.dart';
import 'package:vk_parse/functions/get/getToken.dart';
import 'package:vk_parse/models/User.dart';

userSearchGet(String search) async {
  var userList = List<User>();

  try {
    final token = await getToken();
    final searchUrl = SEARCH_USER_URL + '?search=$search';
    final response = await http.get(searchUrl, headers: formatToken(token));

    if (response.statusCode == 200) {
      var userData = json.decode(response.body) as List<dynamic>;

      userData.forEach((dynamic value) async {
        var user = new User.fromJson(value);
        userList.add(user);
      });
    }
  } catch (e) {
    print(e);
  }
  return userList.toList();
}
