import 'dart:convert';

import 'package:shelf/shelf.dart';

// json body + status.
Response jsonResponse(int status, Object? body) => Response(
      status,
      body: jsonEncode(body),
      headers: {'content-type': 'application/json'},
    );
