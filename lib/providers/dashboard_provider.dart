import 'package:flutter/foundation.dart';
import '../data/home_widget_service.dart';
import '../data/note_dao.dart';
import '../data/transaction_dao.dart';

class DashboardProvider extends ChangeNotifier {
  final TransactionDao _txnDao = TransactionDao();
  final NoteDao _noteDao = NoteDao();

  int _netBalance = 0;
  int _totalIncome = 0;
  int _totalExpense = 0;
  int _monthlyIncome = 0;
  int _monthlyExpense = 0;
  int _doneProjectCount = 0;
  bool _isLoading = false;

  int get netBalance => _netBalance;
  int get totalIncome => _totalIncome;
  int get totalExpense => _totalExpense;
  int get monthlyIncome => _monthlyIncome;
  int get monthlyExpense => _monthlyExpense;
  int get monthlyBalance => _monthlyIncome - _monthlyExpense;
  int get doneProjectCount => _doneProjectCount;
  bool get isLoading => _isLoading;

  DashboardProvider() {
    refresh();
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    final results = await Future.wait([
      _txnDao.totalIncome(),
      _txnDao.totalExpense(),
      _txnDao.monthlyIncome(),
      _txnDao.monthlyExpense(),
      _noteDao.doneProjectCount(),
    ]);

    _totalIncome = results[0];
    _totalExpense = results[1];
    _monthlyIncome = results[2];
    _monthlyExpense = results[3];
    _doneProjectCount = results[4];
    _netBalance = _totalIncome - _totalExpense;

    _isLoading = false;
    notifyListeners();

    // Update home screen widget
    HomeWidgetService.updateMonthlySummary();
  }
}
