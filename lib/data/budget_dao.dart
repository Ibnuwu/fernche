import 'package:sqflite/sqflite.dart';
import '../core/constants.dart';
import '../models/budget_model.dart';
import 'app_database.dart';

class BudgetDao {
  final AppDatabase _appDb = AppDatabase.instance;

  Future<Database> get _db => _appDb.database;

  /// Get all budgets
  Future<List<BudgetModel>> getAll() async {
    final db = await _db;
    final result = await db.query(
      AppConstants.tableBudgets,
      orderBy: 'category ASC',
    );
    return result.map((m) => BudgetModel.fromMap(m)).toList();
  }

  /// Get budget for a specific category
  Future<BudgetModel?> getByCategory(String category) async {
    final db = await _db;
    final result = await db.query(
      AppConstants.tableBudgets,
      where: 'category = ?',
      whereArgs: [category],
    );
    if (result.isEmpty) return null;
    return BudgetModel.fromMap(result.first);
  }

  /// Insert or update a budget (upsert by category)
  Future<void> upsert(BudgetModel budget) async {
    final db = await _db;
    await db.insert(
      AppConstants.tableBudgets,
      budget.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Delete a budget by category
  Future<int> deleteByCategory(String category) async {
    final db = await _db;
    return db.delete(
      AppConstants.tableBudgets,
      where: 'category = ?',
      whereArgs: [category],
    );
  }

  /// Get all budgets as a map (category → BudgetModel)
  Future<Map<String, BudgetModel>> getAllAsMap() async {
    final budgets = await getAll();
    return {for (final b in budgets) b.category: b};
  }
}
