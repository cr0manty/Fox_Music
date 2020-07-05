import 'dart:async';

import 'package:fox_music/models/relationship.dart';
import 'package:fox_music/models/song.dart';
import 'package:fox_music/models/user.dart';
import 'package:fox_music/instances/shared_prefs.dart';
import 'package:fox_music/utils/closable_http_requuest.dart';
import 'package:fox_music/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class Api {
  static Map<String, String> _formatToken() {
    return {
      'Authorization': "Token ${SharedPrefs.getToken()}",
    };
  }

  static Future addNewSong(Map body) async {
    try {
      final token = SharedPrefs.getToken();
      final response = await http.post(
        ADD_NEW_SONG_URL,
        body: json.encode(body),
        headers: {
          'Authorization': "Token $token",
          "Content-Type": "application/json",
        },
      );

      Map<String, dynamic> result = {
        'success': response.statusCode == 201,
        'body': json.decode(response.body)
      };
      return result;
    } catch (e) {
      print(e);
    }
    return {'success': false, 'body': 'Api call error'};
  }

  static Future appVersionGet() async {
    try {
      final response =
          await http.get(APP_VERSION_URL).timeout(Duration(seconds: 20));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (_) {
      return;
    }
  }

  static Future authCheckGet() async {
    try {
      final response = await http
          .get(AUTH_CHECK, headers: _formatToken())
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } on TimeoutException catch (e) {
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future friendListGet() async {
    try {
      String url = FRIEND_URL + '?status_code=2';
      final response = await http.get(url, headers: _formatToken());

      if (response.statusCode == 200) {
        var friendData =
            (json.decode(response.body) as Map) as Map<String, dynamic>;

        List<Relationship> friendList = [];
        friendData['result'].forEach((value) async {
          var friend = User.fromJson(value['to_user']);
          friendList.add(Relationship(friend, statusId: value['status']));
        });
        return friendList;
      }
    } catch (e) {
      print(e);
    }
    return <Relationship>[];
  }

  static Future friendListIdGet() async {
    Map<int, int> friendList = {};

    try {
      String url = FRIEND_URL + '?status_code=all';
      final response = await http.get(url, headers: _formatToken());

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

  static Future loginPost(String username, String password) async {
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
        SharedPrefs.saveToken(responseJson['token']);
        final user = await profileGet();
        if (user != null) {
          return user;
        }
      }
    } on TimeoutException catch (_) {} catch (e) {
      print(e);
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

  static Future musicListGet({int page = -1}) async {
    try {
      String url = page != -1 ? SONG_LIST_URL + '?page=$page' : SONG_LIST_URL;
      final response = await http.get(url, headers: _formatToken());

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
    } catch (e) {
      print(e);
    }
    return List<Song>();
  }

  static Future musicListPost({page: int}) async {
    try {
      String url = page != null ? SONG_LIST_URL + '?page=$page' : SONG_LIST_URL;
      final response = await http.post(url, headers: _formatToken());

      if (response.statusCode == 201) {
        var songsData =
            (json.decode(response.body) as Map)['results'] as List<dynamic>;

        var songList = List<Song>();
        songsData.forEach((dynamic value) async {
          var song = Song.fromJson(value);
          songList.add(song);
        });
        return songList.reversed.toList();
      }
    } catch (e) {
      print(e);
    }
    return [];
  }

  static Future musicSearchGet(String search) async {
    var songList = List<Song>();
    try {
      final searchUrl = SONG_SEARCH_URL + '?search=$search';
      final response = await http.get(searchUrl, headers: _formatToken());

      if (response.statusCode == 200) {
        var songsData = json.decode(response.body) as List<dynamic>;

        songsData.forEach((dynamic value) async {
          var song = Song.fromJson(value);
          songList.add(song);
        });
      }
    } catch (e) {
      print(e);
    }
    return songList;
  }

  static Future hideMusic(int id) async {
    try {
      final response =
          await http.post(SONG_DELETE_URL + '$id/', headers: _formatToken());
      return response.statusCode == 201;
    } catch (e) {
      print(e);
    }
    return false;
  }

  static Future addMusic(int id) async {
    try {
      final response =
          await http.post(SONG_ADD_URL + '$id/', headers: _formatToken());
      if (response.statusCode == 409) return null;
      return response.statusCode == 201;
    } catch (e) {
      print(e);
    }
    return false;
  }

  static Future profileGet({int friendId}) async {
    try {
      final response = await http
          .get(
            PROFILE_URL + (friendId != null ? '?user_id=$friendId' : ''),
            headers: _formatToken(),
          )
          .timeout(Duration(seconds: 30));
      if (response.statusCode == 200) {
        final responseJson = await json.decode(response.body);

        var user = await User.fromJson(responseJson);
        if (user != null) {
          return user;
        }
      }
    } on TimeoutException catch (_) {} catch (e) {
      print(e);
    }
  }

  static Future profilePost({body}) async {
    try {
      final uri = Uri.parse(PROFILE_URL);
      CloseableMultipartRequest request =
          CloseableMultipartRequest('POST', uri);

      if (body['image'] != null) {
        http.MultipartFile multipartFile =
            await http.MultipartFile.fromPath('image', body['image'].path);
        request.files.add(multipartFile);
      }
      await body.remove('image');

      for (var field in body.entries) {
        request.fields[field.key] = await field.value;
      }

      request.headers.addAll(_formatToken());

      http.StreamedResponse response = await request.send();
      return response.statusCode == 201;
    } on TimeoutException catch (_) {
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future userSearchGet(String search) async {
    var userList = List<User>();

    try {
      final searchUrl = SEARCH_USER_URL + '?search=$search';
      final response = await http.get(searchUrl, headers: _formatToken());

      if (response.statusCode == 200) {
        var userData = json.decode(response.body) as List<dynamic>;

        userData.forEach((dynamic value) async {
          var user = User.fromJson(value);
          userList.add(user);
        });
      }
    } catch (e) {
      print(e);
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
    try {
      final response = await http
          .post(VK_AUTH_URL, body: body, headers: _formatToken())
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
}
