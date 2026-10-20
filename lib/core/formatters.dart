import 'package:intl/intl.dart';

class FerncheFormatters {
  static final _currencyFormat = NumberFormat('#,###', 'id_ID');

  /// Format integer amount to Rupiah string without "Rp" prefix
  static String formatAmount(int amount) {
    return _currencyFormat.format(amount);
  }

  /// Format integer amount with sign prefix (+/-)
  static String formatAmountSigned(int amount, String type) {
    final formatted = _currencyFormat.format(amount);
    if (type == 'income') return '+ $formatted';
    return '- $formatted';
  }

  /// Parse formatted string back to integer
  static int parseAmount(String text) {
    final cleaned = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return 0;
    return int.tryParse(cleaned) ?? 0;
  }

  /// Format compact number (e.g., 1.5M, 500K)
  static String formatCompact(int amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    }
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toString();
  }
}
