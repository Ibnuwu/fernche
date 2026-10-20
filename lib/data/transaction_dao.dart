import 'package:sqflite/sqflite.dart';
import '../core/constants.dart';
import '../core/date_utils.dart';
import '../models/transaction_model.dart';
import 'app_database.dart';

class TransactionDao {
  final AppDatabase _appDb = AppDatabase.instance;

  Future<Database> get _db => _appDb.database;

  /// Insert a new transaction
  Future<int> insert(TransactionModel txn) async {
    final db = await _db;
    return db.insert(AppConstants.tableTransactions, txn.toMap());
  }

  /// Delete a transaction by ID
  Future<int> delete(int id) async {
    final db = await _db;
    return db.delete(
      AppConstants.tableTransactions,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get all transactions, newest first
  Future<List<TransactionModel>> getAll() async {
    final db = await _db;
    final result = await db.query(
      AppConstants.tableTransactions,
      orderBy: 'created_at DESC',
    );
    return result.map((m) => TransactionModel.fromMap(m)).toList();
  }

  /// Get transactions filtered by type
  Future<List<TransactionModel>> getByType(String type) async {
    final db = await _db;
    final result = await db.query(
      AppConstants.tableTransactions,
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'created_at DESC',
    );
    return result.map((m) => TransactionModel.fromMap(m)).toList();
  }

  /// Get transactions for current month
  Future<List<TransactionModel>> getThisMonth() async {
    final db = await _db;
    final start = FerncheDateUtils.startOfMonthIso;
    final end = FerncheDateUtils.endOfMonthIso;
    final result = await db.query(
      AppConstants.tableTransactions,
      where: 'created_at >= ? AND created_at <= ?',
      whereArgs: [start, end],
      orderBy: 'created_at DESC',
    );
    return result.map((m) => TransactionModel.fromMap(m)).toList();
  }

  /// Get recent transactions (limit N)
  Future<List<TransactionModel>> getRecent({int limit = 5}) async {
    final db = await _db;
    final result = await db.query(
      AppConstants.tableTransactions,
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return result.map((m) => TransactionModel.fromMap(m)).toList();
  }

  /// Search transactions by note or category
  Future<List<TransactionModel>> search(String query) async {
    final db = await _db;
    final result = await db.query(
      AppConstants.tableTransactions,
      where: 'note LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );
    return result.map((m) => TransactionModel.fromMap(m)).toList();
  }

  // ----- Aggregate Queries (computed in SQLite) -----

  /// Total income (all time)
  Future<int> totalIncome() async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM ${AppConstants.tableTransactions} WHERE type = ?',
      [AppConstants.typeIncome],
    );
    return (result.first['total'] as int?) ?? 0;
  }

  /// Total expense (all time)
  Future<int> totalExpense() async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM ${AppConstants.tableTransactions} WHERE type = ?',
      [AppConstants.typeExpense],
    );
    return (result.first['total'] as int?) ?? 0;
  }

  /// Net balance (all time)
  Future<int> netBalance() async {
    final income = await totalIncome();
    final expense = await totalExpense();
    return income - expense;
  }

  /// Monthly income for current month
  Future<int> monthlyIncome() async {
    final db = await _db;
    final start = FerncheDateUtils.startOfMonthIso;
    final end = FerncheDateUtils.endOfMonthIso;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM ${AppConstants.tableTransactions} WHERE type = ? AND created_at >= ? AND created_at <= ?',
      [AppConstants.typeIncome, start, end],
    );
    return (result.first['total'] as int?) ?? 0;
  }

  /// Monthly expense for current month
  Future<int> monthlyExpense() async {
    final db = await _db;
    final start = FerncheDateUtils.startOfMonthIso;
    final end = FerncheDateUtils.endOfMonthIso;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM ${AppConstants.tableTransactions} WHERE type = ? AND created_at >= ? AND created_at <= ?',
      [AppConstants.typeExpense, start, end],
    );
    return (result.first['total'] as int?) ?? 0;
  }

  /// Check if a project auto payout already exists (idempotent guard)
  Future<bool> hasProjectPayout(int noteId) async {
    final db = await _db;
    final result = await db.query(
      AppConstants.tableTransactions,
      where: 'source = ? AND source_id = ?',
      whereArgs: [AppConstants.sourceProjectAuto, noteId],
    );
    return result.isNotEmpty;
  }

  /// Create project auto payout transaction (idempotent)
  Future<bool> createProjectPayout({
    required int noteId,
    required int amount,
    required String projectTitle,
  }) async {
    // Guard: don't create duplicate payouts
    if (await hasProjectPayout(noteId)) return false;

    final txn = TransactionModel(
      type: AppConstants.typeIncome,
      amount: amount,
      category: 'Project',
      note: projectTitle,
      source: AppConstants.sourceProjectAuto,
      sourceId: noteId,
      createdAt: FerncheDateUtils.nowIso(),
    );

    await insert(txn);
    return true;
  }

  // ----- Paginated Queries -----

  /// Get all transactions with pagination, newest first
  Future<List<TransactionModel>> getAllPaginated({
    required int limit,
    required int offset,
  }) async {
    final db = await _db;
    final result = await db.query(
      AppConstants.tableTransactions,
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );
    return result.map((m) => TransactionModel.fromMap(m)).toList();
  }

  /// Get transactions by type with pagination
  Future<List<TransactionModel>> getByTypePaginated(
    String type, {
    required int limit,
    required int offset,
  }) async {
    final db = await _db;
    final result = await db.query(
      AppConstants.tableTransactions,
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );
    return result.map((m) => TransactionModel.fromMap(m)).toList();
  }

  /// Get this month's transactions with pagination
  Future<List<TransactionModel>> getThisMonthPaginated({
    required int limit,
    required int offset,
  }) async {
    final db = await _db;
    final start = FerncheDateUtils.startOfMonthIso;
    final end = FerncheDateUtils.endOfMonthIso;
    final result = await db.query(
      AppConstants.tableTransactions,
      where: 'created_at >= ? AND created_at <= ?',
      whereArgs: [start, end],
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );
    return result.map((m) => TransactionModel.fromMap(m)).toList();
  }

  // ----- Count Queries -----

  /// Count all transactions
  Future<int> countAll() async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.tableTransactions}',
    );
    return (result.first['count'] as int?) ?? 0;
  }

  /// Count transactions by type
  Future<int> countByType(String type) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.tableTransactions} WHERE type = ?',
      [type],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  /// Count this month's transactions
  Future<int> countThisMonth() async {
    final db = await _db;
    final start = FerncheDateUtils.startOfMonthIso;
    final end = FerncheDateUtils.endOfMonthIso;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.tableTransactions} WHERE created_at >= ? AND created_at <= ?',
      [start, end],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  // ----- Monthly Report Queries -----

  /// Get all transactions for a specific month/year
  Future<List<TransactionModel>> getByMonth(int year, int month) async {
    final db = await _db;
    final start = FerncheDateUtils.startOfMonthIsoFor(year, month);
    final end = FerncheDateUtils.endOfMonthIsoFor(year, month);
    final result = await db.query(
      AppConstants.tableTransactions,
      where: 'created_at >= ? AND created_at <= ?',
      whereArgs: [start, end],
      orderBy: 'created_at DESC',
    );
    return result.map((m) => TransactionModel.fromMap(m)).toList();
  }

  /// Get aggregated expense/income per category for a specific month
  Future<List<Map<String, dynamic>>> monthlySummaryByCategory(
    int year,
    int month,
  ) async {
    final db = await _db;
    final start = FerncheDateUtils.startOfMonthIsoFor(year, month);
    final end = FerncheDateUtils.endOfMonthIsoFor(year, month);
    return db.rawQuery(
      '''
      SELECT type, category, 
             SUM(amount) as total, 
             COUNT(*) as count
      FROM ${AppConstants.tableTransactions}
      WHERE created_at >= ? AND created_at <= ?
      GROUP BY type, category
      ORDER BY type, total DESC
      ''',
      [start, end],
    );
  }

  // ----- Budget Queries -----

  /// Get expense totals per category for the current month
  Future<Map<String, int>> monthlyExpenseByCategory() async {
    final db = await _db;
    final start = FerncheDateUtils.startOfMonthIso;
    final end = FerncheDateUtils.endOfMonthIso;
    final result = await db.rawQuery(
      '''
      SELECT category, SUM(amount) as total
      FROM ${AppConstants.tableTransactions}
      WHERE type = ? AND created_at >= ? AND created_at <= ?
      GROUP BY category
      ''',
      [AppConstants.typeExpense, start, end],
    );
    final map = <String, int>{};
    for (final row in result) {
      map[row['category'] as String] = (row['total'] as int?) ?? 0;
    }
    return map;
  }
}

