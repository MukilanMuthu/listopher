// tests go through the module interface only: buildHandler + the cli functions.
import 'dart:convert';

import 'package:listopher_server/server.dart';
import 'package:shelf/shelf.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

late Database db;
late Handler handler;
var now = DateTime.utc(2026, 1, 1); // tests move this to test lockout

/// one reply: status + decoded json body.
typedef Reply = ({int status, dynamic body});

/// call handler like a client would.
Future<Reply> call(String method, String path, {String? token, Object? body, String? raw}) async {
  final res = await handler(Request(
    method,
    Uri.parse('http://localhost$path'),
    headers: {if (token != null) 'authorization': 'Bearer $token'},
    body: raw ?? (body == null ? '' : jsonEncode(body)),
  ));
  final text = await res.readAsString();
  return (status: res.statusCode, body: text.isEmpty ? null : jsonDecode(text));
}

/// log in, return token (fails the test if login fails).
Future<String> tokenOf(String user, [String pw = 'pw']) async {
  final r = await call('POST', '/auth/login', body: {'username': user, 'password': pw});
  expect(r.status, 200);
  return r.body['token'] as String;
}

/// make op json. type item.add by default.
Map<String, Object?> op(String id, String space, String user) => {
      'id': id,
      'space_id': space,
      'item_id': 'i-$id',
      'user_id': user,
      'client_time': '2026-01-01T00:00:00.000Z',
      'server_seq': null,
      'type': 'item.add',
      'payload': {
        'name': 'milk',
        'quantity': 1.0,
        'unit': 'L',
        'note': null,
        'requested_by': user,
      },
    };

/// alice + bob, with their tokens and ids.
late String aliceId, bobId, alice, bob;

void main() {
  setUp(() async {
    now = DateTime.utc(2026, 1, 1);
    db = openServerDb(':memory:');
    handler = buildHandler(db, clock: () => now);
    aliceId = addUser(db, 'alice', 'Alice', 'pw');
    bobId = addUser(db, 'bob', 'Bob', 'pw');
    alice = await tokenOf('alice');
    bob = await tokenOf('bob');
  });
  tearDown(() => db.close());

  group('login', () {
    test('ok returns token, id, name', () async {
      final r = await call('POST', '/auth/login', body: {'username': 'alice', 'password': 'pw'});
      expect(r.status, 200);
      expect(r.body['user_id'], aliceId);
      expect(r.body['display_name'], 'Alice');
      expect(r.body['token'], isNotEmpty);
    });

    test('wrong password and unknown user look identical', () async {
      final wrong = await call('POST', '/auth/login', body: {'username': 'alice', 'password': 'x'});
      final unknown = await call('POST', '/auth/login', body: {'username': 'nobody', 'password': 'x'});
      expect(wrong.status, 401);
      expect(unknown.status, 401);
      expect(wrong.body, unknown.body);
    });

    test('5 failures lock, 15 min later works again', () async {
      for (var i = 0; i < 5; i++) {
        final r = await call('POST', '/auth/login', body: {'username': 'alice', 'password': 'x'});
        expect(r.status, 401);
      }
      // locked: even the right password is refused
      final locked = await call('POST', '/auth/login', body: {'username': 'alice', 'password': 'pw'});
      expect(locked.status, 429);
      now = now.add(const Duration(minutes: 14));
      expect((await call('POST', '/auth/login', body: {'username': 'alice', 'password': 'pw'})).status, 429);
      now = now.add(const Duration(minutes: 2));
      expect((await call('POST', '/auth/login', body: {'username': 'alice', 'password': 'pw'})).status, 200);
    });

    test('bad json is 400', () async {
      expect((await call('POST', '/auth/login', raw: 'nope')).status, 400);
    });
  });

  group('sessions', () {
    test('no token is 401', () async {
      expect((await call('GET', '/me/spaces')).status, 401);
      expect((await call('GET', '/me/spaces', token: 'junk')).status, 401);
    });

    test('logout kills the token', () async {
      expect((await call('POST', '/auth/logout', token: alice)).status, 200);
      expect((await call('GET', '/me/spaces', token: alice)).status, 401);
    });

    test('revoke-sessions kills all tokens of user', () async {
      final second = await tokenOf('alice');
      revokeSessions(db, 'alice');
      expect((await call('GET', '/me/spaces', token: alice)).status, 401);
      expect((await call('GET', '/me/spaces', token: second)).status, 401);
      expect((await call('GET', '/me/spaces', token: bob)).status, 200); // bob untouched
    });

    test('set-password changes login', () async {
      setPassword(db, 'alice', 'new');
      final old = await call('POST', '/auth/login', body: {'username': 'alice', 'password': 'pw'});
      expect(old.status, 401);
      await tokenOf('alice', 'new');
    });
  });

  group('spaces', () {
    test('create, duplicate 409, listed in me/spaces', () async {
      expect((await call('POST', '/spaces', token: alice, body: {'space_id': 's1'})).status, 201);
      expect((await call('POST', '/spaces', token: alice, body: {'space_id': 's1'})).status, 409);
      expect((await call('POST', '/spaces', token: bob, body: {'space_id': 's1'})).status, 409);
      final mine = await call('GET', '/me/spaces', token: alice);
      expect(mine.body['space_ids'], ['s1']);
      expect((await call('GET', '/me/spaces', token: bob)).body['space_ids'], isEmpty);
    });

    test('invite is owner only', () async {
      await call('POST', '/spaces', token: alice, body: {'space_id': 's1'});
      final invite = await call('POST', '/spaces/s1/invite', token: alice);
      await call('POST', '/spaces/s1/join', token: bob, body: {'invite': invite.body['invite']});
      expect((await call('POST', '/spaces/s1/invite', token: bob)).status, 403);
    });

    test('join: wrong invite 403, right ok, twice no-op, old invite dead', () async {
      await call('POST', '/spaces', token: alice, body: {'space_id': 's1'});
      // no invite made yet
      expect((await call('POST', '/spaces/s1/join', token: bob, body: {'invite': 'x'})).status, 403);
      final first = (await call('POST', '/spaces/s1/invite', token: alice)).body['invite'];
      expect((await call('POST', '/spaces/s1/join', token: bob, body: {'invite': 'wrong'})).status, 403);
      expect((await call('POST', '/spaces/s1/join', token: bob, body: {'invite': first})).status, 200);
      expect((await call('POST', '/spaces/s1/join', token: bob, body: {'invite': first})).status, 200);
      final members = await call('GET', '/spaces/s1/members', token: alice);
      expect((members.body as List).length, 2); // joined once only

      final second = (await call('POST', '/spaces/s1/invite', token: alice)).body['invite'];
      expect(second, isNot(first));
      final carol = addUser(db, 'carol', 'Carol', 'pw');
      expect(carol, isNotEmpty);
      final carolToken = await tokenOf('carol');
      expect((await call('POST', '/spaces/s1/join', token: carolToken, body: {'invite': first})).status, 403);
      expect((await call('POST', '/spaces/s1/join', token: carolToken, body: {'invite': second})).status, 200);
    });

    test('join unknown space is 404', () async {
      expect((await call('POST', '/spaces/nope/join', token: bob, body: {'invite': 'x'})).status, 404);
    });

    test('members list has id, name, role', () async {
      await call('POST', '/spaces', token: alice, body: {'space_id': 's1'});
      final invite = (await call('POST', '/spaces/s1/invite', token: alice)).body['invite'];
      await call('POST', '/spaces/s1/join', token: bob, body: {'invite': invite});
      final r = await call('GET', '/spaces/s1/members', token: bob);
      expect(r.body, [
        {'user_id': aliceId, 'display_name': 'Alice', 'role': 'owner'},
        {'user_id': bobId, 'display_name': 'Bob', 'role': 'member'},
      ]);
    });

    test('non-member 403, unknown space 404', () async {
      await call('POST', '/spaces', token: alice, body: {'space_id': 's1'});
      expect((await call('GET', '/spaces/s1/members', token: bob)).status, 403);
      expect((await call('GET', '/spaces/s1/ops', token: bob)).status, 403);
      expect((await call('POST', '/spaces/s1/ops', token: bob, body: [])).status, 403);
      expect((await call('DELETE', '/spaces/s1', token: bob)).status, 403);
      expect((await call('GET', '/spaces/nope/ops', token: bob)).status, 404);
    });

    test('delete space: owner only, members then get 404', () async {
      await call('POST', '/spaces', token: alice, body: {'space_id': 's1'});
      final invite = (await call('POST', '/spaces/s1/invite', token: alice)).body['invite'];
      await call('POST', '/spaces/s1/join', token: bob, body: {'invite': invite});
      expect((await call('DELETE', '/spaces/s1', token: bob)).status, 403);
      expect((await call('DELETE', '/spaces/s1', token: alice)).status, 200);
      expect((await call('GET', '/spaces/s1/ops', token: bob)).status, 404);
      expect((await call('GET', '/spaces/s1/ops', token: alice)).status, 404);
      expect((await call('GET', '/me/spaces', token: bob)).body['space_ids'], isEmpty);
    });
  });

  group('ops', () {
    setUp(() async {
      await call('POST', '/spaces', token: alice, body: {'space_id': 's1'});
      await call('POST', '/spaces', token: alice, body: {'space_id': 's2'});
    });

    test('append gives seq 1,2,3 and reads back in order', () async {
      final r = await call('POST', '/spaces/s1/ops',
          token: alice, body: [op('a', 's1', aliceId), op('b', 's1', aliceId), op('c', 's1', aliceId)]);
      expect(r.status, 200);
      expect(r.body, {'a': 1, 'b': 2, 'c': 3});
      final got = await call('GET', '/spaces/s1/ops?after=1', token: alice);
      final ops = got.body['ops'] as List;
      expect(ops.map((o) => o['id']), ['b', 'c']);
      expect(ops.map((o) => o['server_seq']), [2, 3]); // seq stored in json
    });

    test('seq is per space', () async {
      await call('POST', '/spaces/s1/ops', token: alice, body: [op('a', 's1', aliceId)]);
      final r = await call('POST', '/spaces/s2/ops', token: alice, body: [op('b', 's2', aliceId)]);
      expect(r.body, {'b': 1});
    });

    test('resend same op returns same seq, no duplicate', () async {
      await call('POST', '/spaces/s1/ops', token: alice, body: [op('a', 's1', aliceId)]);
      final again = await call('POST', '/spaces/s1/ops',
          token: alice, body: [op('a', 's1', aliceId), op('b', 's1', aliceId)]);
      expect(again.body, {'a': 1, 'b': 2});
      final got = await call('GET', '/spaces/s1/ops', token: alice);
      expect((got.body['ops'] as List).length, 2);
    });

    test('wrong user_id is 403', () async {
      final invite = (await call('POST', '/spaces/s1/invite', token: alice)).body['invite'];
      await call('POST', '/spaces/s1/join', token: bob, body: {'invite': invite});
      final r = await call('POST', '/spaces/s1/ops', token: bob, body: [op('a', 's1', aliceId)]);
      expect(r.status, 403);
    });

    test('wrong space_id is 403', () async {
      final r = await call('POST', '/spaces/s1/ops', token: alice, body: [op('a', 's2', aliceId)]);
      expect(r.status, 403);
    });

    test('one bad op in batch is 400 and nothing stored', () async {
      final bad = op('b', 's1', aliceId)..remove('payload');
      final r = await call('POST', '/spaces/s1/ops', token: alice, body: [op('a', 's1', aliceId), bad]);
      expect(r.status, 400);
      final got = await call('GET', '/spaces/s1/ops', token: alice);
      expect(got.body['ops'], isEmpty);
    });

    test('non-json body is 400', () async {
      expect((await call('POST', '/spaces/s1/ops', token: alice, raw: '{{')).status, 400);
      expect((await call('POST', '/spaces/s1/ops', token: alice, body: {'not': 'a list'})).status, 400);
    });

    test('after: bad value acts as 0, page capped at 500', () async {
      final batch = [for (var i = 0; i < 520; i++) op('o$i', 's1', aliceId)];
      await call('POST', '/spaces/s1/ops', token: alice, body: batch);
      final first = (await call('GET', '/spaces/s1/ops', token: alice)).body['ops'] as List;
      expect(first.length, 500);
      expect(first.first['server_seq'], 1);
      expect(first.last['server_seq'], 500);
      final junk = (await call('GET', '/spaces/s1/ops?after=abc', token: alice)).body['ops'] as List;
      expect(junk.length, 500);
      final rest = (await call('GET', '/spaces/s1/ops?after=500', token: alice)).body['ops'] as List;
      expect(rest.map((o) => o['server_seq']), [for (var i = 501; i <= 520; i++) i]);
    });
  });

  group('delete account', () {
    test('transfers to oldest member, deletes solo space, keeps ops, preview matches', () async {
      // shared: alice owns, bob joins (then carol). solo: alice only.
      await call('POST', '/spaces', token: alice, body: {'space_id': 'shared'});
      await call('POST', '/spaces', token: alice, body: {'space_id': 'solo'});
      final invite = (await call('POST', '/spaces/shared/invite', token: alice)).body['invite'];
      now = now.add(const Duration(minutes: 1));
      await call('POST', '/spaces/shared/join', token: bob, body: {'invite': invite});
      addUser(db, 'carol', 'Carol', 'pw');
      final carol = await tokenOf('carol');
      now = now.add(const Duration(minutes: 1));
      await call('POST', '/spaces/shared/join', token: carol, body: {'invite': invite});
      await call('POST', '/spaces/shared/ops', token: alice, body: [op('a', 'shared', aliceId)]);

      final preview = await call('GET', '/me/delete-preview', token: alice);
      expect(preview.body, {'transfer': ['shared'], 'delete': ['solo']});

      expect((await call('DELETE', '/me', token: alice)).status, 200);
      expect((await call('GET', '/me/spaces', token: alice)).status, 401); // sessions gone
      expect((await call('POST', '/auth/login', body: {'username': 'alice', 'password': 'pw'})).status, 401);

      // bob (oldest other member) now owns shared; solo is gone
      final members = await call('GET', '/spaces/shared/members', token: bob);
      expect(members.body, [
        {'user_id': bobId, 'display_name': 'Bob', 'role': 'owner'},
        {'user_id': members.body[1]['user_id'], 'display_name': 'Carol', 'role': 'member'},
      ]);
      expect((await call('POST', '/spaces/shared/invite', token: bob)).status, 200); // owner powers
      expect((await call('GET', '/spaces/solo/ops', token: bob)).status, 404);
      // alice's op is still there
      final ops = await call('GET', '/spaces/shared/ops', token: bob);
      expect((ops.body['ops'] as List).single['user_id'], aliceId);
    });
  });

  group('limits', () {
    test('body over 1 MB is 413', () async {
      final big = 'x' * (1024 * 1024 + 1);
      final r = await call('POST', '/auth/login', raw: big);
      expect(r.status, 413);
    });
  });
}
