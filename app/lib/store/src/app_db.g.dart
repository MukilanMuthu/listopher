// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_db.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, UserRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverAccountIdMeta = const VerificationMeta(
    'serverAccountId',
  );
  @override
  late final GeneratedColumn<String> serverAccountId = GeneratedColumn<String>(
    'server_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isMeMeta = const VerificationMeta('isMe');
  @override
  late final GeneratedColumn<bool> isMe = GeneratedColumn<bool>(
    'is_me',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_me" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    serverAccountId,
    isMe,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('server_account_id')) {
      context.handle(
        _serverAccountIdMeta,
        serverAccountId.isAcceptableOrUnknown(
          data['server_account_id']!,
          _serverAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('is_me')) {
      context.handle(
        _isMeMeta,
        isMe.isAcceptableOrUnknown(data['is_me']!, _isMeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      serverAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_account_id'],
      ),
      isMe: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_me'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class UserRow extends DataClass implements Insertable<UserRow> {
  final String id;
  final String displayName;
  final String? serverAccountId;
  final bool isMe;
  const UserRow({
    required this.id,
    required this.displayName,
    this.serverAccountId,
    required this.isMe,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || serverAccountId != null) {
      map['server_account_id'] = Variable<String>(serverAccountId);
    }
    map['is_me'] = Variable<bool>(isMe);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      displayName: Value(displayName),
      serverAccountId: serverAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverAccountId),
      isMe: Value(isMe),
    );
  }

  factory UserRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserRow(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      serverAccountId: serializer.fromJson<String?>(json['serverAccountId']),
      isMe: serializer.fromJson<bool>(json['isMe']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String>(displayName),
      'serverAccountId': serializer.toJson<String?>(serverAccountId),
      'isMe': serializer.toJson<bool>(isMe),
    };
  }

  UserRow copyWith({
    String? id,
    String? displayName,
    Value<String?> serverAccountId = const Value.absent(),
    bool? isMe,
  }) => UserRow(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    serverAccountId: serverAccountId.present
        ? serverAccountId.value
        : this.serverAccountId,
    isMe: isMe ?? this.isMe,
  );
  UserRow copyWithCompanion(UsersCompanion data) {
    return UserRow(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      serverAccountId: data.serverAccountId.present
          ? data.serverAccountId.value
          : this.serverAccountId,
      isMe: data.isMe.present ? data.isMe.value : this.isMe,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserRow(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('serverAccountId: $serverAccountId, ')
          ..write('isMe: $isMe')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, displayName, serverAccountId, isMe);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserRow &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.serverAccountId == this.serverAccountId &&
          other.isMe == this.isMe);
}

class UsersCompanion extends UpdateCompanion<UserRow> {
  final Value<String> id;
  final Value<String> displayName;
  final Value<String?> serverAccountId;
  final Value<bool> isMe;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.serverAccountId = const Value.absent(),
    this.isMe = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String displayName,
    this.serverAccountId = const Value.absent(),
    this.isMe = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       displayName = Value(displayName);
  static Insertable<UserRow> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<String>? serverAccountId,
    Expression<bool>? isMe,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (serverAccountId != null) 'server_account_id': serverAccountId,
      if (isMe != null) 'is_me': isMe,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String>? displayName,
    Value<String?>? serverAccountId,
    Value<bool>? isMe,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      serverAccountId: serverAccountId ?? this.serverAccountId,
      isMe: isMe ?? this.isMe,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (serverAccountId.present) {
      map['server_account_id'] = Variable<String>(serverAccountId.value);
    }
    if (isMe.present) {
      map['is_me'] = Variable<bool>(isMe.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('serverAccountId: $serverAccountId, ')
          ..write('isMe: $isMe, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ListsTable extends Lists with TableInfo<$ListsTable, ListRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ListsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    groupId,
    name,
    date,
    createdBy,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lists';
  @override
  VerificationContext validateIntegrity(
    Insertable<ListRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ListRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ListRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ListsTable createAlias(String alias) {
    return $ListsTable(attachedDatabase, alias);
  }
}

class ListRow extends DataClass implements Insertable<ListRow> {
  final String id;
  final String? groupId;
  final String name;
  final DateTime? date;
  final String createdBy;
  final DateTime createdAt;
  const ListRow({
    required this.id,
    this.groupId,
    required this.name,
    this.date,
    required this.createdBy,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<String>(groupId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || date != null) {
      map['date'] = Variable<DateTime>(date);
    }
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ListsCompanion toCompanion(bool nullToAbsent) {
    return ListsCompanion(
      id: Value(id),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
      name: Value(name),
      date: date == null && nullToAbsent ? const Value.absent() : Value(date),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
    );
  }

  factory ListRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ListRow(
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String?>(json['groupId']),
      name: serializer.fromJson<String>(json['name']),
      date: serializer.fromJson<DateTime?>(json['date']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String?>(groupId),
      'name': serializer.toJson<String>(name),
      'date': serializer.toJson<DateTime?>(date),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ListRow copyWith({
    String? id,
    Value<String?> groupId = const Value.absent(),
    String? name,
    Value<DateTime?> date = const Value.absent(),
    String? createdBy,
    DateTime? createdAt,
  }) => ListRow(
    id: id ?? this.id,
    groupId: groupId.present ? groupId.value : this.groupId,
    name: name ?? this.name,
    date: date.present ? date.value : this.date,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
  );
  ListRow copyWithCompanion(ListsCompanion data) {
    return ListRow(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      name: data.name.present ? data.name.value : this.name,
      date: data.date.present ? data.date.value : this.date,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ListRow(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('name: $name, ')
          ..write('date: $date, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, groupId, name, date, createdBy, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ListRow &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.name == this.name &&
          other.date == this.date &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt);
}

class ListsCompanion extends UpdateCompanion<ListRow> {
  final Value<String> id;
  final Value<String?> groupId;
  final Value<String> name;
  final Value<DateTime?> date;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ListsCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.name = const Value.absent(),
    this.date = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ListsCompanion.insert({
    required String id,
    this.groupId = const Value.absent(),
    required String name,
    this.date = const Value.absent(),
    required String createdBy,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdBy = Value(createdBy),
       createdAt = Value(createdAt);
  static Insertable<ListRow> custom({
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<String>? name,
    Expression<DateTime>? date,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (name != null) 'name': name,
      if (date != null) 'date': date,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ListsCompanion copyWith({
    Value<String>? id,
    Value<String?>? groupId,
    Value<String>? name,
    Value<DateTime?>? date,
    Value<String>? createdBy,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ListsCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      date: date ?? this.date,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ListsCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('name: $name, ')
          ..write('date: $date, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemsTable extends Items with TableInfo<$ItemsTable, ItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<String> listId = GeneratedColumn<String>(
    'list_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _requestedByMeta = const VerificationMeta(
    'requestedBy',
  );
  @override
  late final GeneratedColumn<String> requestedBy = GeneratedColumn<String>(
    'requested_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestedAtMeta = const VerificationMeta(
    'requestedAt',
  );
  @override
  late final GeneratedColumn<DateTime> requestedAt = GeneratedColumn<DateTime>(
    'requested_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checkedMeta = const VerificationMeta(
    'checked',
  );
  @override
  late final GeneratedColumn<bool> checked = GeneratedColumn<bool>(
    'checked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("checked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _checkedByMeta = const VerificationMeta(
    'checkedBy',
  );
  @override
  late final GeneratedColumn<String> checkedBy = GeneratedColumn<String>(
    'checked_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checkedAtMeta = const VerificationMeta(
    'checkedAt',
  );
  @override
  late final GeneratedColumn<DateTime> checkedAt = GeneratedColumn<DateTime>(
    'checked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fulfilledByMeta = const VerificationMeta(
    'fulfilledBy',
  );
  @override
  late final GeneratedColumn<String> fulfilledBy = GeneratedColumn<String>(
    'fulfilled_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    listId,
    name,
    quantity,
    unit,
    note,
    requestedBy,
    requestedAt,
    checked,
    checkedBy,
    checkedAt,
    fulfilledBy,
    deleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('list_id')) {
      context.handle(
        _listIdMeta,
        listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta),
      );
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('requested_by')) {
      context.handle(
        _requestedByMeta,
        requestedBy.isAcceptableOrUnknown(
          data['requested_by']!,
          _requestedByMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestedByMeta);
    }
    if (data.containsKey('requested_at')) {
      context.handle(
        _requestedAtMeta,
        requestedAt.isAcceptableOrUnknown(
          data['requested_at']!,
          _requestedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestedAtMeta);
    }
    if (data.containsKey('checked')) {
      context.handle(
        _checkedMeta,
        checked.isAcceptableOrUnknown(data['checked']!, _checkedMeta),
      );
    }
    if (data.containsKey('checked_by')) {
      context.handle(
        _checkedByMeta,
        checkedBy.isAcceptableOrUnknown(data['checked_by']!, _checkedByMeta),
      );
    }
    if (data.containsKey('checked_at')) {
      context.handle(
        _checkedAtMeta,
        checkedAt.isAcceptableOrUnknown(data['checked_at']!, _checkedAtMeta),
      );
    }
    if (data.containsKey('fulfilled_by')) {
      context.handle(
        _fulfilledByMeta,
        fulfilledBy.isAcceptableOrUnknown(
          data['fulfilled_by']!,
          _fulfilledByMeta,
        ),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      listId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}list_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      requestedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}requested_by'],
      )!,
      requestedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}requested_at'],
      )!,
      checked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}checked'],
      )!,
      checkedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checked_by'],
      ),
      checkedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}checked_at'],
      ),
      fulfilledBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fulfilled_by'],
      ),
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }
}

class ItemRow extends DataClass implements Insertable<ItemRow> {
  final String id;
  final String listId;
  final String name;
  final double? quantity;
  final String? unit;
  final String? note;
  final String requestedBy;
  final DateTime requestedAt;
  final bool checked;
  final String? checkedBy;
  final DateTime? checkedAt;
  final String? fulfilledBy;
  final bool deleted;
  const ItemRow({
    required this.id,
    required this.listId,
    required this.name,
    this.quantity,
    this.unit,
    this.note,
    required this.requestedBy,
    required this.requestedAt,
    required this.checked,
    this.checkedBy,
    this.checkedAt,
    this.fulfilledBy,
    required this.deleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['list_id'] = Variable<String>(listId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || quantity != null) {
      map['quantity'] = Variable<double>(quantity);
    }
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['requested_by'] = Variable<String>(requestedBy);
    map['requested_at'] = Variable<DateTime>(requestedAt);
    map['checked'] = Variable<bool>(checked);
    if (!nullToAbsent || checkedBy != null) {
      map['checked_by'] = Variable<String>(checkedBy);
    }
    if (!nullToAbsent || checkedAt != null) {
      map['checked_at'] = Variable<DateTime>(checkedAt);
    }
    if (!nullToAbsent || fulfilledBy != null) {
      map['fulfilled_by'] = Variable<String>(fulfilledBy);
    }
    map['deleted'] = Variable<bool>(deleted);
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      id: Value(id),
      listId: Value(listId),
      name: Value(name),
      quantity: quantity == null && nullToAbsent
          ? const Value.absent()
          : Value(quantity),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      requestedBy: Value(requestedBy),
      requestedAt: Value(requestedAt),
      checked: Value(checked),
      checkedBy: checkedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(checkedBy),
      checkedAt: checkedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(checkedAt),
      fulfilledBy: fulfilledBy == null && nullToAbsent
          ? const Value.absent()
          : Value(fulfilledBy),
      deleted: Value(deleted),
    );
  }

  factory ItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemRow(
      id: serializer.fromJson<String>(json['id']),
      listId: serializer.fromJson<String>(json['listId']),
      name: serializer.fromJson<String>(json['name']),
      quantity: serializer.fromJson<double?>(json['quantity']),
      unit: serializer.fromJson<String?>(json['unit']),
      note: serializer.fromJson<String?>(json['note']),
      requestedBy: serializer.fromJson<String>(json['requestedBy']),
      requestedAt: serializer.fromJson<DateTime>(json['requestedAt']),
      checked: serializer.fromJson<bool>(json['checked']),
      checkedBy: serializer.fromJson<String?>(json['checkedBy']),
      checkedAt: serializer.fromJson<DateTime?>(json['checkedAt']),
      fulfilledBy: serializer.fromJson<String?>(json['fulfilledBy']),
      deleted: serializer.fromJson<bool>(json['deleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'listId': serializer.toJson<String>(listId),
      'name': serializer.toJson<String>(name),
      'quantity': serializer.toJson<double?>(quantity),
      'unit': serializer.toJson<String?>(unit),
      'note': serializer.toJson<String?>(note),
      'requestedBy': serializer.toJson<String>(requestedBy),
      'requestedAt': serializer.toJson<DateTime>(requestedAt),
      'checked': serializer.toJson<bool>(checked),
      'checkedBy': serializer.toJson<String?>(checkedBy),
      'checkedAt': serializer.toJson<DateTime?>(checkedAt),
      'fulfilledBy': serializer.toJson<String?>(fulfilledBy),
      'deleted': serializer.toJson<bool>(deleted),
    };
  }

  ItemRow copyWith({
    String? id,
    String? listId,
    String? name,
    Value<double?> quantity = const Value.absent(),
    Value<String?> unit = const Value.absent(),
    Value<String?> note = const Value.absent(),
    String? requestedBy,
    DateTime? requestedAt,
    bool? checked,
    Value<String?> checkedBy = const Value.absent(),
    Value<DateTime?> checkedAt = const Value.absent(),
    Value<String?> fulfilledBy = const Value.absent(),
    bool? deleted,
  }) => ItemRow(
    id: id ?? this.id,
    listId: listId ?? this.listId,
    name: name ?? this.name,
    quantity: quantity.present ? quantity.value : this.quantity,
    unit: unit.present ? unit.value : this.unit,
    note: note.present ? note.value : this.note,
    requestedBy: requestedBy ?? this.requestedBy,
    requestedAt: requestedAt ?? this.requestedAt,
    checked: checked ?? this.checked,
    checkedBy: checkedBy.present ? checkedBy.value : this.checkedBy,
    checkedAt: checkedAt.present ? checkedAt.value : this.checkedAt,
    fulfilledBy: fulfilledBy.present ? fulfilledBy.value : this.fulfilledBy,
    deleted: deleted ?? this.deleted,
  );
  ItemRow copyWithCompanion(ItemsCompanion data) {
    return ItemRow(
      id: data.id.present ? data.id.value : this.id,
      listId: data.listId.present ? data.listId.value : this.listId,
      name: data.name.present ? data.name.value : this.name,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      note: data.note.present ? data.note.value : this.note,
      requestedBy: data.requestedBy.present
          ? data.requestedBy.value
          : this.requestedBy,
      requestedAt: data.requestedAt.present
          ? data.requestedAt.value
          : this.requestedAt,
      checked: data.checked.present ? data.checked.value : this.checked,
      checkedBy: data.checkedBy.present ? data.checkedBy.value : this.checkedBy,
      checkedAt: data.checkedAt.present ? data.checkedAt.value : this.checkedAt,
      fulfilledBy: data.fulfilledBy.present
          ? data.fulfilledBy.value
          : this.fulfilledBy,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemRow(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('note: $note, ')
          ..write('requestedBy: $requestedBy, ')
          ..write('requestedAt: $requestedAt, ')
          ..write('checked: $checked, ')
          ..write('checkedBy: $checkedBy, ')
          ..write('checkedAt: $checkedAt, ')
          ..write('fulfilledBy: $fulfilledBy, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    listId,
    name,
    quantity,
    unit,
    note,
    requestedBy,
    requestedAt,
    checked,
    checkedBy,
    checkedAt,
    fulfilledBy,
    deleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemRow &&
          other.id == this.id &&
          other.listId == this.listId &&
          other.name == this.name &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.note == this.note &&
          other.requestedBy == this.requestedBy &&
          other.requestedAt == this.requestedAt &&
          other.checked == this.checked &&
          other.checkedBy == this.checkedBy &&
          other.checkedAt == this.checkedAt &&
          other.fulfilledBy == this.fulfilledBy &&
          other.deleted == this.deleted);
}

class ItemsCompanion extends UpdateCompanion<ItemRow> {
  final Value<String> id;
  final Value<String> listId;
  final Value<String> name;
  final Value<double?> quantity;
  final Value<String?> unit;
  final Value<String?> note;
  final Value<String> requestedBy;
  final Value<DateTime> requestedAt;
  final Value<bool> checked;
  final Value<String?> checkedBy;
  final Value<DateTime?> checkedAt;
  final Value<String?> fulfilledBy;
  final Value<bool> deleted;
  final Value<int> rowid;
  const ItemsCompanion({
    this.id = const Value.absent(),
    this.listId = const Value.absent(),
    this.name = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.note = const Value.absent(),
    this.requestedBy = const Value.absent(),
    this.requestedAt = const Value.absent(),
    this.checked = const Value.absent(),
    this.checkedBy = const Value.absent(),
    this.checkedAt = const Value.absent(),
    this.fulfilledBy = const Value.absent(),
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemsCompanion.insert({
    required String id,
    required String listId,
    required String name,
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.note = const Value.absent(),
    required String requestedBy,
    required DateTime requestedAt,
    this.checked = const Value.absent(),
    this.checkedBy = const Value.absent(),
    this.checkedAt = const Value.absent(),
    this.fulfilledBy = const Value.absent(),
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       listId = Value(listId),
       name = Value(name),
       requestedBy = Value(requestedBy),
       requestedAt = Value(requestedAt);
  static Insertable<ItemRow> custom({
    Expression<String>? id,
    Expression<String>? listId,
    Expression<String>? name,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<String>? note,
    Expression<String>? requestedBy,
    Expression<DateTime>? requestedAt,
    Expression<bool>? checked,
    Expression<String>? checkedBy,
    Expression<DateTime>? checkedAt,
    Expression<String>? fulfilledBy,
    Expression<bool>? deleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (listId != null) 'list_id': listId,
      if (name != null) 'name': name,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (note != null) 'note': note,
      if (requestedBy != null) 'requested_by': requestedBy,
      if (requestedAt != null) 'requested_at': requestedAt,
      if (checked != null) 'checked': checked,
      if (checkedBy != null) 'checked_by': checkedBy,
      if (checkedAt != null) 'checked_at': checkedAt,
      if (fulfilledBy != null) 'fulfilled_by': fulfilledBy,
      if (deleted != null) 'deleted': deleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? listId,
    Value<String>? name,
    Value<double?>? quantity,
    Value<String?>? unit,
    Value<String?>? note,
    Value<String>? requestedBy,
    Value<DateTime>? requestedAt,
    Value<bool>? checked,
    Value<String?>? checkedBy,
    Value<DateTime?>? checkedAt,
    Value<String?>? fulfilledBy,
    Value<bool>? deleted,
    Value<int>? rowid,
  }) {
    return ItemsCompanion(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      note: note ?? this.note,
      requestedBy: requestedBy ?? this.requestedBy,
      requestedAt: requestedAt ?? this.requestedAt,
      checked: checked ?? this.checked,
      checkedBy: checkedBy ?? this.checkedBy,
      checkedAt: checkedAt ?? this.checkedAt,
      fulfilledBy: fulfilledBy ?? this.fulfilledBy,
      deleted: deleted ?? this.deleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (listId.present) {
      map['list_id'] = Variable<String>(listId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (requestedBy.present) {
      map['requested_by'] = Variable<String>(requestedBy.value);
    }
    if (requestedAt.present) {
      map['requested_at'] = Variable<DateTime>(requestedAt.value);
    }
    if (checked.present) {
      map['checked'] = Variable<bool>(checked.value);
    }
    if (checkedBy.present) {
      map['checked_by'] = Variable<String>(checkedBy.value);
    }
    if (checkedAt.present) {
      map['checked_at'] = Variable<DateTime>(checkedAt.value);
    }
    if (fulfilledBy.present) {
      map['fulfilled_by'] = Variable<String>(fulfilledBy.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('note: $note, ')
          ..write('requestedBy: $requestedBy, ')
          ..write('requestedAt: $requestedAt, ')
          ..write('checked: $checked, ')
          ..write('checkedBy: $checkedBy, ')
          ..write('checkedAt: $checkedAt, ')
          ..write('fulfilledBy: $fulfilledBy, ')
          ..write('deleted: $deleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OpsTable extends Ops with TableInfo<$OpsTable, OpRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OpsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<String> listId = GeneratedColumn<String>(
    'list_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [seq, id, listId, serverSeq, json];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ops';
  @override
  VerificationContext validateIntegrity(
    Insertable<OpRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('list_id')) {
      context.handle(
        _listIdMeta,
        listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta),
      );
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seq};
  @override
  OpRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OpRow(
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      listId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}list_id'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
    );
  }

  @override
  $OpsTable createAlias(String alias) {
    return $OpsTable(attachedDatabase, alias);
  }
}

class OpRow extends DataClass implements Insertable<OpRow> {
  final int seq;
  final String id;
  final String listId;
  final int? serverSeq;
  final String json;
  const OpRow({
    required this.seq,
    required this.id,
    required this.listId,
    this.serverSeq,
    required this.json,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seq'] = Variable<int>(seq);
    map['id'] = Variable<String>(id);
    map['list_id'] = Variable<String>(listId);
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    map['json'] = Variable<String>(json);
    return map;
  }

  OpsCompanion toCompanion(bool nullToAbsent) {
    return OpsCompanion(
      seq: Value(seq),
      id: Value(id),
      listId: Value(listId),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
      json: Value(json),
    );
  }

  factory OpRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OpRow(
      seq: serializer.fromJson<int>(json['seq']),
      id: serializer.fromJson<String>(json['id']),
      listId: serializer.fromJson<String>(json['listId']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
      json: serializer.fromJson<String>(json['json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seq': serializer.toJson<int>(seq),
      'id': serializer.toJson<String>(id),
      'listId': serializer.toJson<String>(listId),
      'serverSeq': serializer.toJson<int?>(serverSeq),
      'json': serializer.toJson<String>(json),
    };
  }

  OpRow copyWith({
    int? seq,
    String? id,
    String? listId,
    Value<int?> serverSeq = const Value.absent(),
    String? json,
  }) => OpRow(
    seq: seq ?? this.seq,
    id: id ?? this.id,
    listId: listId ?? this.listId,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
    json: json ?? this.json,
  );
  OpRow copyWithCompanion(OpsCompanion data) {
    return OpRow(
      seq: data.seq.present ? data.seq.value : this.seq,
      id: data.id.present ? data.id.value : this.id,
      listId: data.listId.present ? data.listId.value : this.listId,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      json: data.json.present ? data.json.value : this.json,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OpRow(')
          ..write('seq: $seq, ')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('json: $json')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(seq, id, listId, serverSeq, json);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OpRow &&
          other.seq == this.seq &&
          other.id == this.id &&
          other.listId == this.listId &&
          other.serverSeq == this.serverSeq &&
          other.json == this.json);
}

class OpsCompanion extends UpdateCompanion<OpRow> {
  final Value<int> seq;
  final Value<String> id;
  final Value<String> listId;
  final Value<int?> serverSeq;
  final Value<String> json;
  const OpsCompanion({
    this.seq = const Value.absent(),
    this.id = const Value.absent(),
    this.listId = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.json = const Value.absent(),
  });
  OpsCompanion.insert({
    this.seq = const Value.absent(),
    required String id,
    required String listId,
    this.serverSeq = const Value.absent(),
    required String json,
  }) : id = Value(id),
       listId = Value(listId),
       json = Value(json);
  static Insertable<OpRow> custom({
    Expression<int>? seq,
    Expression<String>? id,
    Expression<String>? listId,
    Expression<int>? serverSeq,
    Expression<String>? json,
  }) {
    return RawValuesInsertable({
      if (seq != null) 'seq': seq,
      if (id != null) 'id': id,
      if (listId != null) 'list_id': listId,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (json != null) 'json': json,
    });
  }

  OpsCompanion copyWith({
    Value<int>? seq,
    Value<String>? id,
    Value<String>? listId,
    Value<int?>? serverSeq,
    Value<String>? json,
  }) {
    return OpsCompanion(
      seq: seq ?? this.seq,
      id: id ?? this.id,
      listId: listId ?? this.listId,
      serverSeq: serverSeq ?? this.serverSeq,
      json: json ?? this.json,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (listId.present) {
      map['list_id'] = Variable<String>(listId.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OpsCompanion(')
          ..write('seq: $seq, ')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('json: $json')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  $AppDbManager get managers => $AppDbManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $ListsTable lists = $ListsTable(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final $OpsTable ops = $OpsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    lists,
    items,
    ops,
  ];
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  required String displayName,
  Value<String?> serverAccountId,
  Value<bool> isMe,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<String> displayName,
  Value<String?> serverAccountId,
  Value<bool> isMe,
  Value<int> rowid,
});

class $$UsersTableFilterComposer extends Composer<_$AppDb, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverAccountId => $composableBuilder(
    column: $table.serverAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMe => $composableBuilder(
    column: $table.isMe,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer extends Composer<_$AppDb, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverAccountId => $composableBuilder(
    column: $table.serverAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMe => $composableBuilder(
    column: $table.isMe,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer extends Composer<_$AppDb, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverAccountId => $composableBuilder(
    column: $table.serverAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isMe =>
      $composableBuilder(column: $table.isMe, builder: (column) => column);
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $UsersTable,
          UserRow,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (UserRow, BaseReferences<_$AppDb, $UsersTable, UserRow>),
          UserRow,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDb db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> serverAccountId = const Value.absent(),
                Value<bool> isMe = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                displayName: displayName,
                serverAccountId: serverAccountId,
                isMe: isMe,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String displayName,
                Value<String?> serverAccountId = const Value.absent(),
                Value<bool> isMe = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                displayName: displayName,
                serverAccountId: serverAccountId,
                isMe: isMe,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UsersTable, UserRow>(table),
                  BaseReferences<_$AppDb, $UsersTable, UserRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $UsersTable,
      UserRow,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (UserRow, BaseReferences<_$AppDb, $UsersTable, UserRow>),
      UserRow,
      PrefetchHooks Function()
    >;
typedef $$ListsTableCreateCompanionBuilder = ListsCompanion Function({
  required String id,
  Value<String?> groupId,
  required String name,
  Value<DateTime?> date,
  required String createdBy,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$ListsTableUpdateCompanionBuilder = ListsCompanion Function({
  Value<String> id,
  Value<String?> groupId,
  Value<String> name,
  Value<DateTime?> date,
  Value<String> createdBy,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$ListsTableFilterComposer extends Composer<_$AppDb, $ListsTable> {
  $$ListsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ListsTableOrderingComposer extends Composer<_$AppDb, $ListsTable> {
  $$ListsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ListsTableAnnotationComposer extends Composer<_$AppDb, $ListsTable> {
  $$ListsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ListsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ListsTable,
          ListRow,
          $$ListsTableFilterComposer,
          $$ListsTableOrderingComposer,
          $$ListsTableAnnotationComposer,
          $$ListsTableCreateCompanionBuilder,
          $$ListsTableUpdateCompanionBuilder,
          (ListRow, BaseReferences<_$AppDb, $ListsTable, ListRow>),
          ListRow,
          PrefetchHooks Function()
        > {
  $$ListsTableTableManager(_$AppDb db, $ListsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ListsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ListsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ListsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime?> date = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ListsCompanion(
                id: id,
                groupId: groupId,
                name: name,
                date: date,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> groupId = const Value.absent(),
                required String name,
                Value<DateTime?> date = const Value.absent(),
                required String createdBy,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ListsCompanion.insert(
                id: id,
                groupId: groupId,
                name: name,
                date: date,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ListsTable, ListRow>(table),
                  BaseReferences<_$AppDb, $ListsTable, ListRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ListsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ListsTable,
      ListRow,
      $$ListsTableFilterComposer,
      $$ListsTableOrderingComposer,
      $$ListsTableAnnotationComposer,
      $$ListsTableCreateCompanionBuilder,
      $$ListsTableUpdateCompanionBuilder,
      (ListRow, BaseReferences<_$AppDb, $ListsTable, ListRow>),
      ListRow,
      PrefetchHooks Function()
    >;
typedef $$ItemsTableCreateCompanionBuilder = ItemsCompanion Function({
  required String id,
  required String listId,
  required String name,
  Value<double?> quantity,
  Value<String?> unit,
  Value<String?> note,
  required String requestedBy,
  required DateTime requestedAt,
  Value<bool> checked,
  Value<String?> checkedBy,
  Value<DateTime?> checkedAt,
  Value<String?> fulfilledBy,
  Value<bool> deleted,
  Value<int> rowid,
});
typedef $$ItemsTableUpdateCompanionBuilder = ItemsCompanion Function({
  Value<String> id,
  Value<String> listId,
  Value<String> name,
  Value<double?> quantity,
  Value<String?> unit,
  Value<String?> note,
  Value<String> requestedBy,
  Value<DateTime> requestedAt,
  Value<bool> checked,
  Value<String?> checkedBy,
  Value<DateTime?> checkedAt,
  Value<String?> fulfilledBy,
  Value<bool> deleted,
  Value<int> rowid,
});

class $$ItemsTableFilterComposer extends Composer<_$AppDb, $ItemsTable> {
  $$ItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get listId => $composableBuilder(
    column: $table.listId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestedBy => $composableBuilder(
    column: $table.requestedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get requestedAt => $composableBuilder(
    column: $table.requestedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get checked => $composableBuilder(
    column: $table.checked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checkedBy => $composableBuilder(
    column: $table.checkedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get checkedAt => $composableBuilder(
    column: $table.checkedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fulfilledBy => $composableBuilder(
    column: $table.fulfilledBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ItemsTableOrderingComposer extends Composer<_$AppDb, $ItemsTable> {
  $$ItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get listId => $composableBuilder(
    column: $table.listId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestedBy => $composableBuilder(
    column: $table.requestedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get requestedAt => $composableBuilder(
    column: $table.requestedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get checked => $composableBuilder(
    column: $table.checked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checkedBy => $composableBuilder(
    column: $table.checkedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get checkedAt => $composableBuilder(
    column: $table.checkedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fulfilledBy => $composableBuilder(
    column: $table.fulfilledBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItemsTableAnnotationComposer extends Composer<_$AppDb, $ItemsTable> {
  $$ItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get listId =>
      $composableBuilder(column: $table.listId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get requestedBy => $composableBuilder(
    column: $table.requestedBy,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get requestedAt => $composableBuilder(
    column: $table.requestedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get checked =>
      $composableBuilder(column: $table.checked, builder: (column) => column);

  GeneratedColumn<String> get checkedBy =>
      $composableBuilder(column: $table.checkedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get checkedAt =>
      $composableBuilder(column: $table.checkedAt, builder: (column) => column);

  GeneratedColumn<String> get fulfilledBy => $composableBuilder(
    column: $table.fulfilledBy,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);
}

class $$ItemsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ItemsTable,
          ItemRow,
          $$ItemsTableFilterComposer,
          $$ItemsTableOrderingComposer,
          $$ItemsTableAnnotationComposer,
          $$ItemsTableCreateCompanionBuilder,
          $$ItemsTableUpdateCompanionBuilder,
          (ItemRow, BaseReferences<_$AppDb, $ItemsTable, ItemRow>),
          ItemRow,
          PrefetchHooks Function()
        > {
  $$ItemsTableTableManager(_$AppDb db, $ItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> listId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double?> quantity = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> requestedBy = const Value.absent(),
                Value<DateTime> requestedAt = const Value.absent(),
                Value<bool> checked = const Value.absent(),
                Value<String?> checkedBy = const Value.absent(),
                Value<DateTime?> checkedAt = const Value.absent(),
                Value<String?> fulfilledBy = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemsCompanion(
                id: id,
                listId: listId,
                name: name,
                quantity: quantity,
                unit: unit,
                note: note,
                requestedBy: requestedBy,
                requestedAt: requestedAt,
                checked: checked,
                checkedBy: checkedBy,
                checkedAt: checkedAt,
                fulfilledBy: fulfilledBy,
                deleted: deleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String listId,
                required String name,
                Value<double?> quantity = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required String requestedBy,
                required DateTime requestedAt,
                Value<bool> checked = const Value.absent(),
                Value<String?> checkedBy = const Value.absent(),
                Value<DateTime?> checkedAt = const Value.absent(),
                Value<String?> fulfilledBy = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemsCompanion.insert(
                id: id,
                listId: listId,
                name: name,
                quantity: quantity,
                unit: unit,
                note: note,
                requestedBy: requestedBy,
                requestedAt: requestedAt,
                checked: checked,
                checkedBy: checkedBy,
                checkedAt: checkedAt,
                fulfilledBy: fulfilledBy,
                deleted: deleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ItemsTable, ItemRow>(table),
                  BaseReferences<_$AppDb, $ItemsTable, ItemRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ItemsTable,
      ItemRow,
      $$ItemsTableFilterComposer,
      $$ItemsTableOrderingComposer,
      $$ItemsTableAnnotationComposer,
      $$ItemsTableCreateCompanionBuilder,
      $$ItemsTableUpdateCompanionBuilder,
      (ItemRow, BaseReferences<_$AppDb, $ItemsTable, ItemRow>),
      ItemRow,
      PrefetchHooks Function()
    >;
typedef $$OpsTableCreateCompanionBuilder = OpsCompanion Function({
  Value<int> seq,
  required String id,
  required String listId,
  Value<int?> serverSeq,
  required String json,
});
typedef $$OpsTableUpdateCompanionBuilder = OpsCompanion Function({
  Value<int> seq,
  Value<String> id,
  Value<String> listId,
  Value<int?> serverSeq,
  Value<String> json,
});

class $$OpsTableFilterComposer extends Composer<_$AppDb, $OpsTable> {
  $$OpsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get listId => $composableBuilder(
    column: $table.listId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OpsTableOrderingComposer extends Composer<_$AppDb, $OpsTable> {
  $$OpsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get listId => $composableBuilder(
    column: $table.listId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OpsTableAnnotationComposer extends Composer<_$AppDb, $OpsTable> {
  $$OpsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get listId =>
      $composableBuilder(column: $table.listId, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);
}

class $$OpsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $OpsTable,
          OpRow,
          $$OpsTableFilterComposer,
          $$OpsTableOrderingComposer,
          $$OpsTableAnnotationComposer,
          $$OpsTableCreateCompanionBuilder,
          $$OpsTableUpdateCompanionBuilder,
          (OpRow, BaseReferences<_$AppDb, $OpsTable, OpRow>),
          OpRow,
          PrefetchHooks Function()
        > {
  $$OpsTableTableManager(_$AppDb db, $OpsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OpsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OpsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OpsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> listId = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String> json = const Value.absent(),
              }) => OpsCompanion(
                seq: seq,
                id: id,
                listId: listId,
                serverSeq: serverSeq,
                json: json,
              ),
          createCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                required String id,
                required String listId,
                Value<int?> serverSeq = const Value.absent(),
                required String json,
              }) => OpsCompanion.insert(
                seq: seq,
                id: id,
                listId: listId,
                serverSeq: serverSeq,
                json: json,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OpsTable, OpRow>(table),
                  BaseReferences<_$AppDb, $OpsTable, OpRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OpsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $OpsTable,
      OpRow,
      $$OpsTableFilterComposer,
      $$OpsTableOrderingComposer,
      $$OpsTableAnnotationComposer,
      $$OpsTableCreateCompanionBuilder,
      $$OpsTableUpdateCompanionBuilder,
      (OpRow, BaseReferences<_$AppDb, $OpsTable, OpRow>),
      OpRow,
      PrefetchHooks Function()
    >;

class $AppDbManager {
  final _$AppDb _db;
  $AppDbManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$ListsTableTableManager get lists =>
      $$ListsTableTableManager(_db, _db.lists);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
  $$OpsTableTableManager get ops => $$OpsTableTableManager(_db, _db.ops);
}
