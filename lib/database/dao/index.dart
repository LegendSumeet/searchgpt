import 'package:drift/drift.dart';
import 'package:searchgpt/database/db/db.dart';

part 'index.g.dart';

/// Data Access Object for managing [SearchData] entities in the database.
/// Provides CRUD operations and reactive streams for search data.
@DriftAccessor(tables: [SearchData])
class SearchDao extends DatabaseAccessor<AppDatabase> with _$SearchDaoMixin {
  SearchDao(super.db);

  /// Inserts or updates a [SearchData] entry in the database.
  ///
  /// Throws [ArgumentError] if the data is invalid.
  /// Returns the inserted/updated row ID.
  Future<String> insertSearchData(SearchDatas data) async {
    if (data.id.isEmpty) {
      throw ArgumentError('SearchData ID cannot be empty');
    }
    if (data.query.isEmpty) {
      throw ArgumentError('Search query cannot be empty');
    }

    await into(searchData).insertOnConflictUpdate(data);
    return data.id;
  }

  /// Retrieves a [SearchData] entry by its ID.
  ///
  /// Returns null if no entry with the given ID exists.
  Future<SearchDatas?> getSearchDataById(String id) async {
    if (id.isEmpty) {
      throw ArgumentError('ID cannot be empty');
    }

    return await (select(searchData)
      ..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Retrieves all search data entries with optional pagination.
  ///
  /// [limit] - Maximum number of entries to return
  /// [offset] - Number of entries to skip
  /// Returns a list of [SearchData] ordered by creation date (newest first).
  Future<List<SearchDatas>> getAllSearchData({int? limit, int? offset}) async {
    final query = select(searchData)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);

    if (limit != null) {
      if (limit <= 0) {
        throw ArgumentError('Limit must be positive');
      }
      query.limit(limit, offset: offset ?? 0);
    }

    return await query.get();
  }

  /// Watches a single [SearchData] entry for changes.
  ///
  /// Returns a [Stream] that emits the current value and any changes.
  /// Emits null if the entry doesn't exist.
  Stream<SearchDatas?> watchSearchData(String id) {
    if (id.isEmpty) {
      throw ArgumentError('ID cannot be empty');
    }

    return (select(searchData)
      ..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  /// Watches all search data entries for changes.
  ///
  /// Returns a [Stream] of lists ordered by creation date (newest first).
  Stream<List<SearchDatas>> watchAllSearchData() {
    return (select(searchData)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  }

  /// Updates an existing [SearchData] entry.
  ///
  /// Returns true if the update was successful, false if no matching entry was found.
  Future<bool> updateSearchData(SearchDatas data) async {
    if (data.id.isEmpty) {
      throw ArgumentError('SearchData ID cannot be empty');
    }

    final updated = await update(searchData).replace(data);
    return updated;
  }

  /// Deletes a [SearchData] entry by its ID.
  ///
  /// Returns the number of rows affected (0 or 1).
  Future<int> deleteSearchDataById(String id) async {
    if (id.isEmpty) {
      throw ArgumentError('ID cannot be empty');
    }

    return await (delete(searchData)..where((t) => t.id.equals(id))).go();
  }

  /// Deletes all search data entries from the database.
  ///
  /// Returns the number of rows deleted.
  /// Use with caution as this operation cannot be undone.
  Future<int> clearAllSearchData() async {
    return await delete(searchData).go();
  }

  /// Counts the total number of search data entries in the database.
  Future<int> countAllSearchData() async {
    final count = searchData.id.count();
    final query = selectOnly(searchData)..addColumns([count]);
    final result = await query.map((row) => row.read(count)).getSingle();
    return result ?? 0;
  }

  // ❗️Update a single column by ID
  Future<void> updateFieldById<T extends Object>({
    required String id,
    required String columnName,
    required T value,
  }) async {
    final updateQuery = customUpdate(
      'UPDATE search_data SET $columnName = ? WHERE id = ?',
      variables: [Variable<Object>(value), Variable<String>(id)],
      updates: {searchData}, // helps Drift know schema has changed
    );
    await updateQuery;
  }

  Future<String> getSearchDataTitleById(String id) async {
    final query = select(searchData)..where((t) => t.id.equals(id));
    return query.map((row) => row.query).getSingle();
  }

  /// Retrieves search data entries created within a specific date range.
  ///
  /// [start] - Start of date range (inclusive)
  /// [end] - End of date range (inclusive)
  Future<List<SearchDatas>> getSearchDataByDateRange({
    required DateTime start,
    required DateTime end,
  }) async {
    if (start.isAfter(end)) {
      throw ArgumentError('Start date must be before end date');
    }

    return await (select(searchData)
          ..where((t) => t.createdAt.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }
}
