import 'hash_password.dart';

// fake hash for unknown usernames. login checks against it so unknown user
// takes same time as wrong password → timing can't reveal real usernames.
// top-level final = made once, on first use.
final dummyHash = hashPassword('not-a-real-password');
