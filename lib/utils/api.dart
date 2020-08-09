import 'dart:async';

import 'package:fox_music/models/relationship.dart';
import 'package:fox_music/models/song.dart';
import 'package:fox_music/models/user.dart';
import 'package:fox_music/instances/shared_prefs.dart';
import 'package:fox_music/utils/closable_http_requuest.dart';
import 'package:fox_music/utils/constants.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:http_interceptor/http_interceptor.dart';

class LogInterceptor implements InterceptorContract {
  void printWrapped(String text) {
    final pattern = new RegExp('.{1,800}');
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  String prettyJson(String jsonString) {
    return JsonEncoder.withIndent('  ').convert(json.decode(jsonString));
  }

  @override
  Future<RequestData> interceptRequest({RequestData data}) async {
    print(
        "Request Method: ${data.method} , Url: ${data.url} Headers: ${data.headers}");
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({ResponseData data}) async {
    printWrapped(
        "Response Method: ${data.method} , Url: ${data.url}, Status Code: ${data.statusCode}");
    printWrapped('Body: ${prettyJson(data.body)}');
    return data;
  }
}

abstract class Api {
  static Client client = HttpClientWithInterceptor.build(
      interceptors: [LogInterceptor()], requestTimeout: Duration(seconds: 30));

  static Map<String, String> _token() {
    return {
      'Authorization': "Token ${SharedPrefs.getToken()}",
    };
  }

  static Map _contentType() {
    return {
      'Authorization': 'Token ${SharedPrefs.getToken()}',
      'Content-Type': 'application/json',
    };
  }

  static Future addNewSong(Map body) async {
    final response = await client.post(
      ADD_NEW_SONG_URL,
      body: json.encode(body),
      headers: _contentType(),
    );

    Map<String, dynamic> result = {
      'success': response.statusCode == 201,
      'body': json.decode(response.body)
    };
    return result;
  }

  static Future appVersionGet() async {
    final response =
        await client.get(APP_VERSION_URL).timeout(Duration(seconds: 20));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
  }

  static Future authCheckGet() async {
    final response = await client.get(AUTH_CHECK, headers: _token());
    return response.statusCode == 200;
  }

  static Future friendListGet() async {
    String url = FRIEND_URL + '?status_code=2';
    List<Relationship> friendList = [];

    final response = await client.get(url, headers: _token());

    if (response.statusCode == 200) {
      var friendData =
          (json.decode(response.body) as Map) as Map<String, dynamic>;

      friendData['result'].forEach((value) async {
        var friend = User.fromJson(value['to_user']);
        friendList.add(Relationship(friend, statusId: value['status']));
      });
    }
    return friendList;
  }

  static Future friendListIdGet() async {
    Map<int, int> friendList = {};
    String url = FRIEND_URL + '?status_code=all';

    final response = await client.get(url, headers: _token());

    if (response.statusCode == 200) {
      var friendData =
          (json.decode(response.body) as Map) as Map<String, dynamic>;

      friendData['result'].forEach((value) async {
        friendList[value['to_user']['id']] = value['status'];
      });
    }
    return friendList;
  }

  static Future loginPost(String username, String password) async {
    Map<String, String> body = {
      'username': username,
      'password': password,
    };
    final response = await client.post(AUTH_URL, body: body);
    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      SharedPrefs.saveToken(responseJson['token']);
      final user = await profileGet();
      if (user != null) {
        return user;
      }
    }
  }

  static Future registrationPost(String username, String password,
      String firstName, String lastName) async {
    Map<String, dynamic> body = {
      'username': username,
      'password': password,
      'first_name': firstName,
      'last_name': lastName
    };
    final response = await client
        .post(REGISTRATION_URL, body: body)
        .timeout(Duration(seconds: 60));
    if (response.statusCode == 201) {
      return true;
    }
  }

  static Future musicListGet({int page = -1}) async {
    String url = page != -1 ? SONG_LIST_URL + '?page=$page' : SONG_LIST_URL;

    final response = await client.get(url, headers: _token());

    if (response.statusCode == 200) {
      var songsData =
          (json.decode(response.body) as Map)['results'] as List<dynamic>;

      var songList = List<Song>();
      songsData.forEach((dynamic value) async {
        var song = Song.fromJson(value);
        songList.add(song);
      });
      return songList.reversed.toList();
    }
    return List<Song>();
  }

  static Future musicListPost({page: int}) async {
    String url = page != -1 ? SONG_LIST_URL + '?page=$page' : SONG_LIST_URL;
    final response = await client.post(url, headers: _token());

    return response.statusCode == 201;
  }

  static Future musicSearchGet(String search) async {
    var songList = List<Song>();
    final url = SONG_SEARCH_URL + '?search=$search';

    final response = await client.get(url, headers: _token());

    if (response.statusCode == 200) {
      var songsData = json.decode(response.body) as List<dynamic>;

      songsData.forEach((dynamic value) async {
        var song = Song.fromJson(value);
        songList.add(song);
      });
    }
    return songList;
  }

  static Future hideMusic(int id) async {
    String url = SONG_DELETE_URL + '$id/';
    final response = await client.post(url, headers: _token());
    return response.statusCode == 201;
  }

  static Future addMusic(int id) async {
    String url = SONG_ADD_URL + '$id/';

    final response = await client.post(url, headers: _token());
    if (response.statusCode == 409) return null;
    return response.statusCode == 201;
  }

  static Future profileGet({int friendId}) async {
    String url = PROFILE_URL + (friendId != null ? '?user_id=$friendId' : '');
    final response = await client.get(url, headers: _token());
    if (response.statusCode == 200) {
      final responseJson = await json.decode(response.body);

      var user = await User.fromJson(responseJson);
      if (user != null) {
        return user;
      }
    }
  }

  static Future profilePost({body}) async {
    final uri = Uri.parse(PROFILE_URL);
    CloseableMultipartRequest request = CloseableMultipartRequest('POST', uri);

    if (body['image'] != null) {
      MultipartFile multipartFile =
          await MultipartFile.fromPath('image', body['image'].path);
      request.files.add(multipartFile);
    }
    await body.remove('image');

    for (var field in body.entries) {
      request.fields[field.key] = await field.value;
    }

    request.headers.addAll(_token());

    StreamedResponse response = await request.send();
    return response.statusCode == 201;
  }

  static Future userSearchGet(String search) async {
    var userList = List<User>();

    final searchUrl = SEARCH_USER_URL + '?search=$search';
    final response = await client.get(searchUrl, headers: _token());

    if (response.statusCode == 200) {
      var userData = json.decode(response.body) as List<dynamic>;

      userData.forEach((dynamic value) async {
        var user = User.fromJson(value);
        userList.add(user);
      });
    }
    return userList;
  }

  static Future vkAuth(
      String username, String password, String sid, String captcha) async {
    Map<String, String> body = {
      'username': username,
      'password': password,
    };
    if (sid != null && captcha != null) {
      body['sid'] = sid;
      body['captcha'] = captcha;
    }
    Map<String, dynamic> status = {'code': 0};
    final response =
        await client.post(VK_AUTH_URL, body: body, headers: _token());
    status['code'] = response.statusCode;

    if (response.statusCode == 200) {
      await profileGet();
    } else if (response.statusCode == 302) {
      var data = json.decode(response.body) as Map<String, dynamic>;
      status['url'] = data['url'];
      status['sid'] = data['sid'];
    }
    return status;
  }
}
