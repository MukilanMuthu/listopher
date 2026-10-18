import 'package:drift/drift.dart';

// all tables in one file: drift codegen needs them together.
// see docs/adr/0005-data-model.md.

/// people. isMe = the profile of this phone's owner.
@DataClassName('UserRow')
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get displayName => text()();
  TextColumn get serverAccountId => text().nullable()(); // null = local-only profile
  BoolColumn get isMe => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// spaces: where items live. view of the op log.
@DataClassName('SpaceRow')
class Spaces extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  BoolColumn get private => boolean()(); // true = this phone only, never shared
  TextColumn get serverUrl => text().nullable()(); // null = not shared yet
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// space items. view of the op log.
@DataClassName('ItemRow')
class Items extends Table {
  TextColumn get id => text()();
  TextColumn get spaceId => text()();
  TextColumn get name => text()();
  RealColumn get quantity => real().nullable()();
  TextColumn get unit => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get requestedBy => text()();
  DateTimeColumn get requestedAt => dateTime()();
  BoolColumn get checked => boolean().withDefault(const Constant(false))();
  TextColumn get checkedBy => text().nullable()();
  DateTimeColumn get checkedAt => dateTime().nullable()();
  TextColumn get fulfilledBy => text().nullable()(); // who bought it
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// op log. serverSeq null = still in outbox (no separate outbox table).
@DataClassName('OpRow')
class Ops extends Table {
  IntColumn get seq => integer().autoIncrement()(); // local insertion order
  TextColumn get id => text().unique()();
  TextColumn get spaceId => text()();
  IntColumn get serverSeq => integer().nullable()();
  TextColumn get json => text()(); // jsonEncode(opToJson(op))
}

/// my account on one server. one row per server url.
@DataClassName('ServerAccountRow')
class ServerAccounts extends Table {
  TextColumn get url => text()();
  TextColumn get accountId => text()(); // my user id in that server's spaces
  TextColumn get displayName => text()();
  TextColumn get token => text()(); // session token for api calls

  @override
  Set<Column> get primaryKey => {url};
}

/// who is in a shared space, as the server last told us. names and owner work offline.
@DataClassName('MemberRow')
class Members extends Table {
  TextColumn get spaceId => text()();
  TextColumn get userId => text()();
  TextColumn get displayName => text()();
  TextColumn get role => text()(); // 'owner' or 'member', as the server says

  @override
  Set<Column> get primaryKey => {spaceId, userId};
}
