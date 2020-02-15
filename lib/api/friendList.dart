import 'package:http/http.dart' as http;
import 'package:vk_parse/models/Relationship.dart';
import 'dart:convert';

import 'package:vk_parse/utils/urls.dart';
import 'package:vk_parse/models/User.dart';
import 'package:vk_parse/functions/format/headersToken.dart';
import 'package:vk_parse/functions/get/getToken.dart';

friendListGet() async {
  try {
    String token = await getToken();
    String url = FRIEND_LIST_URL + '?status_code=2';
    final response =
        await http.get(url, headers: formatToken(token));

    if (response.statusCode == 200) {
      var friendData =
          (json.decode(response.body) as Map) as Map<String, dynamic>;

      List<Relationship> friendList = [];
      friendData['result'].forEach((value) async {
        var friend = new User.fromJson(value['to_user']);
        friendList.add(Relationship(friend, statusId: value['status']));
      });
      return friendList;
    }
  } catch (e) {
    print(e);
  }
}

friendListIdGet() async {
  Map<int, int> friendList = {};

  try {
    final token = await getToken();
    String url = FRIEND_LIST_URL + '?status_code=all';
    final response = await http.get(url, headers: formatToken(token));

    if (response.statusCode == 200) {
      var friendData =
          (json.decode(response.body) as Map) as Map<String, dynamic>;

      friendData['result'].forEach((value) async {
        friendList[value['to_user']['id']] = value['status'];
      });
      return friendList;
    }
  } catch (e) {
    print(e);
  }
  return friendList;
}
