import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:fox_music/utils/urls.dart';
import 'package:fox_music/functions/get/token.dart';

addNewSong(Map body) async {
  try {
    final token = await getToken();
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
