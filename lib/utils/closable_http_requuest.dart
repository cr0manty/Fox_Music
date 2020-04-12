import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class CloseableMultipartRequest extends http.MultipartRequest {
  IOClient client = IOClient(HttpClient());

  CloseableMultipartRequest(String method, Uri uri) : super(method, uri);

  void close() => client.close();

  @override
  Future<http.StreamedResponse> send() async {
    try {
      var response = await client.send(this);
      var stream = onDone(response.stream, client.close);
      return new http.StreamedResponse(
        new http.ByteStream(stream),
        response.statusCode,
        contentLength: response.contentLength,
        request: response.request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase,
      );
    } catch (_) {
      client.close();
      rethrow;
    }
  }

  Stream<T> onDone<T>(Stream<T> stream, void onDone()) =>
      stream.transform(new StreamTransformer.fromHandlers(handleDone: (sink) {
        sink.close();
        onDone();
      }));
}