import 'package:shelf/shelf.dart';

import 'json_error.dart';

// middleware: bad json or wrong-typed field → 400.
// ponytail: also turns a server-side cast bug into 400 instead of 500. fine for now.
Middleware catchBadRequest() => (inner) => (req) async {
      try {
        return await inner(req);
      } on FormatException {
        return jsonError(400, 'bad request');
      } on TypeError {
        return jsonError(400, 'bad request');
      }
    };
