import 'package:flutter/foundation.dart';
import '../core/constants.dart';
import '../core/date_utils.dart';
import '../data/app_database.dart';
import '../data/transaction_dao.dart';
import '../models/transaction_model.dart';

enum LedgerFilter { all, income, expense, thisMonth }

class LedgerProvider extends ChangeNotifier {
  final TransactionDao _dao = TransactionDao();
  final AppDatabase _appDb = AppDatabase.instance;

  List<TransactionModel> _transactions = [];
  LedgerFilter _filter = LedgerFilter.all;
  bool _isLoading = false;
  String _lastCategory = 'General';

  // Pagination state
  int _page = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool _showAddSheetOnLoad = false;

  List<TransactionModel> get transactions => _transactions;
  LedgerFilter get filter => _filter;
  bool get isLoading => _isLoading;
  String get lastCategory => _lastCategory;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  bool get showAddSheetOnLoad => _showAddSheetOnLoad;

  void triggerAddSheet() {
    _showAddSheetOnLoad = true;
    notifyListeners();
  }

  void consumeAddSheet() {
    _showAddSheetOnLoad = false;
  }

  LedgerProvider() {
    _init();
  }

  Future<void> _init() async {
    final saved = await _appDb.getMeta(AppConstants.metaLastCategory);
    if (saved != null && AppConstants.transactionCategories.contains(saved)) {
      _lastCategory = saved;
    }
    await loadTransactions();
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    _page = 0;
    _hasMore = true;
    notifyListeners();

    final pageSize = AppConstants.pageSize;
    final items = await _fetchPage(0, pageSize);

    _transactions = items;
    _hasMore = items.length >= pageSize;
    _page = 1;

    _isLoading = false;
    notifyListeners();
  }

  /// Load the next page of transactions (for infinite scroll)
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    final pageSize = AppConstants.pageSize;
    final offset = _page * pageSize;
    final items = await _fetchPage(offset, pageSize);

    _transactions.addAll(items);
    _hasMore = items.length >= pageSize;
    _page++;

    _isLoadingMore = false;
    notifyListeners();
  }

  /// Fetch a page of transactions based on current filter
  Future<List<TransactionModel>> _fetchPage(int offset, int limit) async {
    switch (_filter) {
      case LedgerFilter.all:
        return _dao.getAllPaginated(limit: limit, offset: offset);
      case LedgerFilter.income:
        return _dao.getByTypePaginated(
          AppConstants.typeIncome,
          limit: limit,
          offset: offset,
        );
      case LedgerFilter.expense:
        return _dao.getByTypePaginated(
          AppConstants.typeExpense,
          limit: limit,
          offset: offset,
        );
      case LedgerFilter.thisMonth:
        return _dao.getThisMonthPaginated(limit: limit, offset: offset);
    }
  }

  void setFilter(LedgerFilter f) {
    _filter = f;
    loadTransactions();
  }

  Future<void> addTransaction({
    required String type,
    required int amount,
    required String category,
    String? note,
    DateTime? date,
  }) async {
    final createdAt = date != null
        ? FerncheDateUtils.formatIso(date)
        : FerncheDateUtils.nowIso();

    final txn = TransactionModel(
      type: type,
      amount: amount,
      category: category,
      note: note,
      source: AppConstants.sourceManual,
      createdAt: createdAt,
    );

    await _dao.insert(txn);

    // Save last category
    _lastCategory = category;
    await _appDb.setMeta(AppConstants.metaLastCategory, category);

    await loadTransactions();
  }

  Future<TransactionModel?> deleteTransaction(int id) async {
    // Find the transaction before deleting (for undo)
    final txn = _transactions.where((t) => t.id == id).firstOrNull;
    await _dao.delete(id);
    await loadTransactions();
    return txn;
  }

  Future<void> undoDelete(TransactionModel txn) async {
    await _dao.insert(txn);
    await loadTransactions();
  }

  Future<List<TransactionModel>> searchTransactions(String query) async {
    if (query.isEmpty) return _transactions;
    return _dao.search(query);
  }
}
