import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:sqlite3/sqlite3.dart';

import '../accounts/accounts.dart';
import '../spaces/spaces.dart';
import 'authed.dart';
import 'bearer_token.dart';
import 'catch_bad_request.dart';
import 'create_space_route.dart';
import 'get_ops_route.dart';
import 'in_space.dart';
import 'join_route.dart';
import 'json_response.dart';
import 'limit_body.dart';
import 'login_route.dart';
import 'post_ops_route.dart';

// all routes of ADR 8 wired to the modules. clock is injectable for tests.
Handler buildHandler(Database db, {DateTime Function() clock = DateTime.now}) {
  final router = Router()
    ..post('/auth/login', (Request r) => loginRoute(db, r, clock()))
    ..post('/auth/logout', (Request r) => authed(db, r, (me) {
          deleteSession(db, bearerToken(r)!); // authed means token exists
          return jsonResponse(200, {});
        }))
    ..get('/me/delete-preview',
        (Request r) => authed(db, r, (me) => jsonResponse(200, deletePreview(db, me))))
    ..delete('/me', (Request r) => authed(db, r, (me) {
          deleteAccount(db, me);
          return jsonResponse(200, {});
        }))
    ..get('/me/spaces', (Request r) => authed(
        db, r, (me) => jsonResponse(200, {'space_ids': listMySpaces(db, me)})))
    ..post('/spaces', (Request r) => createSpaceRoute(db, r, clock()))
    ..delete('/spaces/<id>', (Request r, String id) => inSpace(db, r, id, (me) {
          deleteSpace(db, id);
          return jsonResponse(200, {});
        }, ownerOnly: true))
    ..post('/spaces/<id>/invite', (Request r, String id) => inSpace(
        db, r, id, (me) => jsonResponse(200, {'invite': rotateInvite(db, id)}),
        ownerOnly: true))
    ..post('/spaces/<id>/join', (Request r, String id) => joinRoute(db, r, id, clock()))
    ..get('/spaces/<id>/members', (Request r, String id) =>
        inSpace(db, r, id, (me) => jsonResponse(200, listMembers(db, id))))
    ..post('/spaces/<id>/ops', (Request r, String id) => postOpsRoute(db, r, id, clock()))
    ..get('/spaces/<id>/ops', (Request r, String id) => getOpsRoute(db, r, id));
  return const Pipeline()
      .addMiddleware(catchBadRequest())
      .addMiddleware(limitBody())
      .addHandler(router.call);
}
