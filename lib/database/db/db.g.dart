// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// ignore_for_file: type=lint
class $SearchDataTable extends SearchData
    with TableInfo<$SearchDataTable, SearchDatas> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SearchDataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _queryMeta = const VerificationMeta('query');
  @override
  late final GeneratedColumn<String> query = GeneratedColumn<String>(
    'query',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tokenMeta = const VerificationMeta('token');
  @override
  late final GeneratedColumn<int> token = GeneratedColumn<int>(
    'token',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _searchMeta = const VerificationMeta('search');
  @override
  late final GeneratedColumn<String> search = GeneratedColumn<String>(
    'search',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _geminiMeta = const VerificationMeta('gemini');
  @override
  late final GeneratedColumn<String> gemini = GeneratedColumn<String>(
    'gemini',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    query,
    token,
    search,
    gemini,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'search_data';
  @override
  VerificationContext validateIntegrity(
    Insertable<SearchDatas> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('query')) {
      context.handle(
        _queryMeta,
        query.isAcceptableOrUnknown(data['query']!, _queryMeta),
      );
    } else if (isInserting) {
      context.missing(_queryMeta);
    }
    if (data.containsKey('token')) {
      context.handle(
        _tokenMeta,
        token.isAcceptableOrUnknown(data['token']!, _tokenMeta),
      );
    } else if (isInserting) {
      context.missing(_tokenMeta);
    }
    if (data.containsKey('search')) {
      context.handle(
        _searchMeta,
        search.isAcceptableOrUnknown(data['search']!, _searchMeta),
      );
    }
    if (data.containsKey('gemini')) {
      context.handle(
        _geminiMeta,
        gemini.isAcceptableOrUnknown(data['gemini']!, _geminiMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SearchDatas map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SearchDatas(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      query:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}query'],
          )!,
      token:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}token'],
          )!,
      search: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search'],
      ),
      gemini: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gemini'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $SearchDataTable createAlias(String alias) {
    return $SearchDataTable(attachedDatabase, alias);
  }
}

class SearchDatas extends DataClass implements Insertable<SearchDatas> {
  final String id;
  final String query;
  final int token;
  final String? search;
  final String? gemini;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const SearchDatas({
    required this.id,
    required this.query,
    required this.token,
    this.search,
    this.gemini,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['query'] = Variable<String>(query);
    map['token'] = Variable<int>(token);
    if (!nullToAbsent || search != null) {
      map['search'] = Variable<String>(search);
    }
    if (!nullToAbsent || gemini != null) {
      map['gemini'] = Variable<String>(gemini);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  SearchDataCompanion toCompanion(bool nullToAbsent) {
    return SearchDataCompanion(
      id: Value(id),
      query: Value(query),
      token: Value(token),
      search:
          search == null && nullToAbsent ? const Value.absent() : Value(search),
      gemini:
          gemini == null && nullToAbsent ? const Value.absent() : Value(gemini),
      createdAt:
          createdAt == null && nullToAbsent
              ? const Value.absent()
              : Value(createdAt),
      updatedAt:
          updatedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(updatedAt),
    );
  }

  factory SearchDatas.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SearchDatas(
      id: serializer.fromJson<String>(json['id']),
      query: serializer.fromJson<String>(json['query']),
      token: serializer.fromJson<int>(json['token']),
      search: serializer.fromJson<String?>(json['search']),
      gemini: serializer.fromJson<String?>(json['gemini']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'query': serializer.toJson<String>(query),
      'token': serializer.toJson<int>(token),
      'search': serializer.toJson<String?>(search),
      'gemini': serializer.toJson<String?>(gemini),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  SearchDatas copyWith({
    String? id,
    String? query,
    int? token,
    Value<String?> search = const Value.absent(),
    Value<String?> gemini = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => SearchDatas(
    id: id ?? this.id,
    query: query ?? this.query,
    token: token ?? this.token,
    search: search.present ? search.value : this.search,
    gemini: gemini.present ? gemini.value : this.gemini,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  SearchDatas copyWithCompanion(SearchDataCompanion data) {
    return SearchDatas(
      id: data.id.present ? data.id.value : this.id,
      query: data.query.present ? data.query.value : this.query,
      token: data.token.present ? data.token.value : this.token,
      search: data.search.present ? data.search.value : this.search,
      gemini: data.gemini.present ? data.gemini.value : this.gemini,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SearchDatas(')
          ..write('id: $id, ')
          ..write('query: $query, ')
          ..write('token: $token, ')
          ..write('search: $search, ')
          ..write('gemini: $gemini, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, query, token, search, gemini, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchDatas &&
          other.id == this.id &&
          other.query == this.query &&
          other.token == this.token &&
          other.search == this.search &&
          other.gemini == this.gemini &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SearchDataCompanion extends UpdateCompanion<SearchDatas> {
  final Value<String> id;
  final Value<String> query;
  final Value<int> token;
  final Value<String?> search;
  final Value<String?> gemini;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const SearchDataCompanion({
    this.id = const Value.absent(),
    this.query = const Value.absent(),
    this.token = const Value.absent(),
    this.search = const Value.absent(),
    this.gemini = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SearchDataCompanion.insert({
    required String id,
    required String query,
    required int token,
    this.search = const Value.absent(),
    this.gemini = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       query = Value(query),
       token = Value(token);
  static Insertable<SearchDatas> custom({
    Expression<String>? id,
    Expression<String>? query,
    Expression<int>? token,
    Expression<String>? search,
    Expression<String>? gemini,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (query != null) 'query': query,
      if (token != null) 'token': token,
      if (search != null) 'search': search,
      if (gemini != null) 'gemini': gemini,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SearchDataCompanion copyWith({
    Value<String>? id,
    Value<String>? query,
    Value<int>? token,
    Value<String?>? search,
    Value<String?>? gemini,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return SearchDataCompanion(
      id: id ?? this.id,
      query: query ?? this.query,
      token: token ?? this.token,
      search: search ?? this.search,
      gemini: gemini ?? this.gemini,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (query.present) {
      map['query'] = Variable<String>(query.value);
    }
    if (token.present) {
      map['token'] = Variable<int>(token.value);
    }
    if (search.present) {
      map['search'] = Variable<String>(search.value);
    }
    if (gemini.present) {
      map['gemini'] = Variable<String>(gemini.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SearchDataCompanion(')
          ..write('id: $id, ')
          ..write('query: $query, ')
          ..write('token: $token, ')
          ..write('search: $search, ')
          ..write('gemini: $gemini, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SearchDataTable searchData = $SearchDataTable(this);
  late final SearchDao searchDao = SearchDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [searchData];
}

typedef $$SearchDataTableCreateCompanionBuilder =
    SearchDataCompanion Function({
      required String id,
      required String query,
      required int token,
      Value<String?> search,
      Value<String?> gemini,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$SearchDataTableUpdateCompanionBuilder =
    SearchDataCompanion Function({
      Value<String> id,
      Value<String> query,
      Value<int> token,
      Value<String?> search,
      Value<String?> gemini,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$SearchDataTableFilterComposer
    extends Composer<_$AppDatabase, $SearchDataTable> {
  $$SearchDataTableFilterComposer({
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

  ColumnFilters<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get search => $composableBuilder(
    column: $table.search,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gemini => $composableBuilder(
    column: $table.gemini,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SearchDataTableOrderingComposer
    extends Composer<_$AppDatabase, $SearchDataTable> {
  $$SearchDataTableOrderingComposer({
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

  ColumnOrderings<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get search => $composableBuilder(
    column: $table.search,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gemini => $composableBuilder(
    column: $table.gemini,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SearchDataTableAnnotationComposer
    extends Composer<_$AppDatabase, $SearchDataTable> {
  $$SearchDataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get query =>
      $composableBuilder(column: $table.query, builder: (column) => column);

  GeneratedColumn<int> get token =>
      $composableBuilder(column: $table.token, builder: (column) => column);

  GeneratedColumn<String> get search =>
      $composableBuilder(column: $table.search, builder: (column) => column);

  GeneratedColumn<String> get gemini =>
      $composableBuilder(column: $table.gemini, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SearchDataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SearchDataTable,
          SearchDatas,
          $$SearchDataTableFilterComposer,
          $$SearchDataTableOrderingComposer,
          $$SearchDataTableAnnotationComposer,
          $$SearchDataTableCreateCompanionBuilder,
          $$SearchDataTableUpdateCompanionBuilder,
          (
            SearchDatas,
            BaseReferences<_$AppDatabase, $SearchDataTable, SearchDatas>,
          ),
          SearchDatas,
          PrefetchHooks Function()
        > {
  $$SearchDataTableTableManager(_$AppDatabase db, $SearchDataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SearchDataTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SearchDataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SearchDataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> query = const Value.absent(),
                Value<int> token = const Value.absent(),
                Value<String?> search = const Value.absent(),
                Value<String?> gemini = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SearchDataCompanion(
                id: id,
                query: query,
                token: token,
                search: search,
                gemini: gemini,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String query,
                required int token,
                Value<String?> search = const Value.absent(),
                Value<String?> gemini = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SearchDataCompanion.insert(
                id: id,
                query: query,
                token: token,
                search: search,
                gemini: gemini,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SearchDataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SearchDataTable,
      SearchDatas,
      $$SearchDataTableFilterComposer,
      $$SearchDataTableOrderingComposer,
      $$SearchDataTableAnnotationComposer,
      $$SearchDataTableCreateCompanionBuilder,
      $$SearchDataTableUpdateCompanionBuilder,
      (
        SearchDatas,
        BaseReferences<_$AppDatabase, $SearchDataTable, SearchDatas>,
      ),
      SearchDatas,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SearchDataTableTableManager get searchData =>
      $$SearchDataTableTableManager(_db, _db.searchData);
}
