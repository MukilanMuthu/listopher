import 'package:shelf/shelf.dart';

import 'json_response.dart';

// error reply: {"error": "<short message>"}.
Response jsonError(int status, String message) => jsonResponse(status, {'error': message});
