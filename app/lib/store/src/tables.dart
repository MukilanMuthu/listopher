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

/// shopping lists. view of the op log.
@DataClassName('ListRow')
class Lists extends Table {
  TextColumn get id => text()();
  TextColumn get groupId => text().nullable()(); // null = local-only list
  TextColumn get name => text()();
  DateTimeColumn get date => dateTime().nullable()(); // shopping day
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// list items. view of the op log.
@DataClassName('ItemRow')
class Items extends Table {
  TextColumn get id => text()();
  TextColumn get listId => text()();
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
  TextColumn get listId => text()();
  IntColumn get serverSeq => integer().nullable()();
  TextColumn get json => text()(); // jsonEncode(opToJson(op))
}
