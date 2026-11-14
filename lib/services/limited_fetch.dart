import 'dart:async';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// A GET that reads no more of the answer than [maxBytes].
///
/// `http.get` reads the whole body before anyone can look at it: a link to
/// a film or a disk image is downloaded in full before the import says it is
/// no recipe page. Here the headers come first. When [skipBody] turns the
/// Content-Type down, or the Content-Length is over [maxBytes], the body is
/// not read at all and the answer comes back with an empty one (its headers
/// still say what it was). Otherwise the body is read until it ends or goes
/// past [maxBytes]; then reading stops, and the answer holds the first
/// `maxBytes + 1` bytes, so the caller can tell that it was too large.
///
/// [timeout] is for the answer to start and for each part of the body
/// after that. [client] is used when given; otherwise one is opened and
/// closed here (`http.runWithClient` still decides which).
Future<http.Response> getLimited(
  Uri url, {
  Map<String, String>? headers,
  required int maxBytes,
  Duration timeout = const Duration(seconds: 20),
  http.Client? client,
  bool Function(String contentType)? skipBody,
}) async {
  final own = client == null ? http.Client() : null;
  final c = client ?? own!;
  try {
    final request = http.Request('GET', url);
    if (headers != null) request.headers.addAll(headers);
    final streamed = await c.send(request).timeout(timeout);
    final declared = streamed.contentLength;
    http.Response answer(List<int> bytes) => http.Response.bytes(
          bytes,
          streamed.statusCode,
          // The length the answer stated, also when its body was not read.
          headers: {
            ...streamed.headers,
            if (declared != null && !streamed.headers.containsKey('content-length')) 'content-length': '$declared',
          },
          request: streamed.request,
          reasonPhrase: streamed.reasonPhrase,
          isRedirect: streamed.isRedirect,
          persistentConnection: streamed.persistentConnection,
        );

    final type = (streamed.headers['content-type'] ?? '').toLowerCase();
    if ((skipBody?.call(type) ?? false) || (declared != null && declared > maxBytes)) {
      // Not read: cancelling the body closes the connection.
      unawaited(streamed.stream.listen(null).cancel());
      return answer(const []);
    }

    final body = BytesBuilder(copy: false);
    await for (final chunk in streamed.stream.timeout(timeout)) {
      if (body.length + chunk.length > maxBytes) {
        body.add(Uint8List.sublistView(Uint8List.fromList(chunk), 0, maxBytes + 1 - body.length));
        break; // leaving the loop cancels the rest of the body
      }
      body.add(chunk);
    }
    return answer(body.takeBytes());
  } finally {
    own?.close();
  }
}

/// Whether [response] is larger than [maxBytes] by what [getLimited] read
/// of it or by the length its headers state.
bool isOverLimit(http.Response response, int maxBytes) {
  if (response.bodyBytes.length > maxBytes) return true;
  final declared = int.tryParse(response.headers['content-length'] ?? '');
  return declared != null && declared > maxBytes;
}
