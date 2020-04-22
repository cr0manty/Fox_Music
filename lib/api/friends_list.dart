import 'package:http/http.dart' as http;
import 'package:fox_music/models/relationship.dart';
import 'dart:convert';

import 'package:fox_music/utils/urls.dart';
import 'package:fox_music/models/user.dart';
import 'package:fox_music/functions/format/token.dart';
import 'package:fox_music/functions/get/token.dart';

friendListGet() async {
  try {
    String token = await getToken();
    String url = FRIEND_URL + '?status_code=2';
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
  return <Relationship>[];
}

friendListIdGet() async {
  Map<int, int> friendList = {};

  try {
    final token = await getToken();
    String url = FRIEND_URL + '?status_code=all';
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
