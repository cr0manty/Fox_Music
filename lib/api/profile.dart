import 'package:fox_music/utils/closable_http_requuest.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:fox_music/utils/urls.dart';
import 'package:fox_music/functions/format/token.dart';
import 'package:fox_music/models/user.dart';
import 'package:fox_music/functions/get/token.dart';

profileGet({int friendId}) async {
  try {
    final String token = await getToken();
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

profilePost({body}) async {
  try {
    final String token = await getToken();
    final uri = Uri.parse(PROFILE_URL);
    CloseableMultipartRequest request = CloseableMultipartRequest('POST', uri);

    if (body['image'] != null) {
      http.MultipartFile multipartFile =
          await http.MultipartFile.fromPath('image', body['image'].path);
      request.files.add(multipartFile);
    }
    await body.remove('image');

    for (var field in body.entries) {
      request.fields[field.key] = await field.value;
    }

    request.headers.addAll(formatToken(token));

    http.StreamedResponse response = await request.send();
    return response.statusCode == 201;
  } on TimeoutException catch (_) {
    return false;
  } catch (e) {
    print(e);
    return false;
  }
}
