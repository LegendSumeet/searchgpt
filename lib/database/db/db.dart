import 'dart:async';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/isolate.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:searchgpt/database/dao/index.dart';
import 'package:synchronized/synchronized.dart';

part 'db.g.dart';

// =============================
// Drift Table Definition
// =============================
@DataClassName('SearchDatas')
class SearchData extends Table {
  TextColumn get id => text()();
  TextColumn get query => text().withLength(min: 1, max: 100)();
  IntColumn get token => integer().named('token')();
  TextColumn get search => text().named('search').nullable()();
  TextColumn get gemini => text().named('gemini').nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// =============================
// AppDatabase Definition
// =============================
@DriftDatabase(tables: [SearchData], daos: [SearchDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase._(QueryExecutor e) : super(e);

  static const _dbName = 'app_database.db';
  static final _lock = Lock();
  static DriftIsolate? _isolate;
  static AppDatabase? _instance;

  /// Singleton instance getter
  static Future<AppDatabase> get instance async {
    return await _lock.synchronized(() async {
      if (_instance == null) {
        final dir = await getApplicationDocumentsDirectory();
        final path = p.join(dir.path, _dbName);
        _isolate ??= await DriftIsolate.spawn(() => _openConnection(path));
        _instance = AppDatabase._(await _isolate!.connect());
      }
      return _instance!;
    });
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA journal_mode = WAL');
      await customStatement('PRAGMA synchronous = NORMAL');
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Properly close the database and cleanup resources
  Future<void> closeDb() async {
    await _lock.synchronized(() async {
      await close();
      await _isolate?.shutdownAll();
      _isolate = null;
      _instance = null;
    });
  }
}

// =============================
// Top-Level Function for DriftIsolate
// =============================
LazyDatabase _openConnection(String path) {
  return LazyDatabase(() async {
    final file = File(path);
    return NativeDatabase(file, logStatements: false);
  });
}
