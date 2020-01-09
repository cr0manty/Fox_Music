import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:vk_parse/utils/urls.dart';
import 'package:vk_parse/models/User.dart';
import 'package:vk_parse/functions/format/headersToken.dart';
import 'package:vk_parse/functions/get/getToken.dart';

requestFriendList() async {
  try {
    final token = await getToken();
    final response = await http.get(FRIEND_LIST_URL, headers: formatToken(token));

    if (response.statusCode == 200) {
      var friendData =
          (json.decode(response.body) as Map) as Map<String, dynamic>;

      var friendList = List<User>();
      friendData['result'].forEach((value) async {
        var fiend = new User.fromJson(value['to_user']);
        friendList.add(fiend);
      });
      return friendList.reversed.toList();
    }
  } catch (e) {
    print(e);
  }
}
