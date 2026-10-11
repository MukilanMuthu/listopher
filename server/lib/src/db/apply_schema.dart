import 'package:sqlite3/sqlite3.dart';

// make tables if missing. see docs/adr/0008-server-api.md "Storage".
// times = iso-8601 utc text.
// ponytail: no migrations. schema change later = write migration then.
void applySchema(Database db) {
  db.execute('''
    CREATE TABLE IF NOT EXISTS accounts (
      id TEXT PRIMARY KEY,
      username TEXT NOT NULL UNIQUE,
      password_hash TEXT NOT NULL,
      display_name TEXT NOT NULL,
      failed_logins INTEGER NOT NULL DEFAULT 0,
      locked_until TEXT,
      created_at TEXT NOT NULL
    );
    CREATE TABLE IF NOT EXISTS sessions (
      token_hash TEXT PRIMARY KEY,
      account_id TEXT NOT NULL REFERENCES accounts(id),
      created_at TEXT NOT NULL
    );
    CREATE TABLE IF NOT EXISTS spaces (
      id TEXT PRIMARY KEY,
      owner_id TEXT NOT NULL REFERENCES accounts(id),
      invite_token TEXT,
      created_at TEXT NOT NULL
    );
    CREATE TABLE IF NOT EXISTS members (
      space_id TEXT NOT NULL REFERENCES spaces(id),
      account_id TEXT NOT NULL REFERENCES accounts(id),
      role TEXT NOT NULL,
      joined_at TEXT NOT NULL,
      PRIMARY KEY (space_id, account_id)
    );
    -- no FK on account_id: ops outlive deleted accounts (blame)
    CREATE TABLE IF NOT EXISTS ops (
      space_id TEXT NOT NULL REFERENCES spaces(id),
      seq INTEGER NOT NULL,
      id TEXT NOT NULL UNIQUE,
      account_id TEXT NOT NULL,
      json TEXT NOT NULL,
      received_at TEXT NOT NULL,
      PRIMARY KEY (space_id, seq)
    );
  ''');
}
