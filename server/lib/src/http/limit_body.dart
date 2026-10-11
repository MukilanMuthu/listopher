import 'package:shelf/shelf.dart';

import 'json_error.dart';

const _maxBytes = 1024 * 1024; // 1 MB

// middleware: read whole body, over 1 MB → 413.
// counts real bytes, so chunked uploads can not dodge the cap.
Middleware limitBody() => (inner) => (req) async {
      final bytes = <int>[];
      await for (final chunk in req.read()) {
        bytes.addAll(chunk);
        if (bytes.length > _maxBytes) return jsonError(413, 'body too large');
      }
      return inner(req.change(body: bytes)); // hand on a fresh readable body
    };
