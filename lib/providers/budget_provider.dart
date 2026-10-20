import 'package:flutter/foundation.dart';
import '../core/date_utils.dart';
import '../data/budget_dao.dart';
import '../data/transaction_dao.dart';
import '../models/budget_model.dart';

/// Status of a budget category
class BudgetStatus {
  final String category;
  final int limitAmount;
  final int spent;

  const BudgetStatus({
    required this.category,
    required this.limitAmount,
    required this.spent,
  });

  double get percentage => limitAmount > 0 ? (spent / limitAmount) : 0.0;
  bool get isOverBudget => spent >= limitAmount;
  bool get isNearBudget => percentage >= 0.8 && !isOverBudget;
  bool get isSafe => percentage < 0.8;
  int get remaining => (limitAmount - spent).clamp(0, limitAmount);
}

class BudgetProvider extends ChangeNotifier {
  final BudgetDao _budgetDao = BudgetDao();
  final TransactionDao _txnDao = TransactionDao();

  Map<String, BudgetModel> _budgets = {};
  Map<String, int> _categoryExpenses = {};
  bool _isLoading = false;

  Map<String, BudgetModel> get budgets => _budgets;
  Map<String, int> get categoryExpenses => _categoryExpenses;
  bool get isLoading => _isLoading;

  BudgetProvider() {
    loadBudgets();
  }

  Future<void> loadBudgets() async {
    _isLoading = true;
    notifyListeners();

    _budgets = await _budgetDao.getAllAsMap();
    _categoryExpenses = await _txnDao.monthlyExpenseByCategory();

    _isLoading = false;
    notifyListeners();
  }

  /// Set or update a budget for a category
  Future<void> setBudget(String category, int limitAmount) async {
    final now = FerncheDateUtils.nowIso();
    final existing = _budgets[category];

    final budget = BudgetModel(
      id: existing?.id,
      category: category,
      limitAmount: limitAmount,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    await _budgetDao.upsert(budget);
    await loadBudgets();
  }

  /// Remove a budget for a category
  Future<void> removeBudget(String category) async {
    await _budgetDao.deleteByCategory(category);
    await loadBudgets();
  }

  /// Get budget status for a specific category
  BudgetStatus? getBudgetStatus(String category) {
    final budget = _budgets[category];
    if (budget == null) return null;

    return BudgetStatus(
      category: category,
      limitAmount: budget.limitAmount,
      spent: _categoryExpenses[category] ?? 0,
    );
  }

  /// Check if a category has a budget and is near/over limit
  bool isCategoryWarning(String category) {
    final status = getBudgetStatus(category);
    if (status == null) return false;
    return status.isNearBudget || status.isOverBudget;
  }

  /// Check if a category is over budget
  bool isCategoryOverBudget(String category) {
    final status = getBudgetStatus(category);
    if (status == null) return false;
    return status.isOverBudget;
  }

  /// Get all categories with warnings (near or over budget)
  List<BudgetStatus> get budgetWarnings {
    final warnings = <BudgetStatus>[];
    for (final category in _budgets.keys) {
      final status = getBudgetStatus(category);
      if (status != null && (status.isNearBudget || status.isOverBudget)) {
        warnings.add(status);
      }
    }
    return warnings;
  }
}
