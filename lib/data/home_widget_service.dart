import 'package:home_widget/home_widget.dart';
import '../core/formatters.dart';
import '../data/transaction_dao.dart';

/// Service to update Android/iOS home screen widget data
class HomeWidgetService {
  static const String _androidWidgetProvider =
      'com.fernche.fernche.MonthlySummaryWidget';
  static const String _iOSWidgetName = 'FerncheWidget';

  /// Initialize home widget
  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId('group.com.fernche.fernche');
  }

  /// Update the monthly summary widget data
  static Future<void> updateMonthlySummary() async {
    try {
      final dao = TransactionDao();
      final income = await dao.monthlyIncome();
      final expense = await dao.monthlyExpense();
      final balance = income - expense;

      await HomeWidget.saveWidgetData<String>(
        'monthly_income',
        'Rp ${FerncheFormatters.formatAmount(income)}',
      );
      await HomeWidget.saveWidgetData<String>(
        'monthly_expense',
        'Rp ${FerncheFormatters.formatAmount(expense)}',
      );
      await HomeWidget.saveWidgetData<String>(
        'monthly_balance',
        'Rp ${FerncheFormatters.formatAmount(balance.abs())}',
      );
      await HomeWidget.saveWidgetData<String>(
        'balance_sign',
        balance >= 0 ? '+' : '-',
      );

      // Update both widgets
      await HomeWidget.updateWidget(
        androidName: _androidWidgetProvider,
        iOSName: _iOSWidgetName,
      );
    } catch (_) {
      // Silently fail if widget is not available
    }
  }

  /// Register a callback for widget interaction (e.g. Quick Add tap)
  static Future<void> registerInteractivityCallback(
    Future<void> Function(Uri?) callback,
  ) async {
    await HomeWidget.registerInteractivityCallback(callback);
  }
}
