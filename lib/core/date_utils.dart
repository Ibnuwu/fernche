import 'package:intl/intl.dart';

class FerncheDateUtils {
  static final _fullFormat = DateFormat('dd MMM yyyy, HH:mm');
  static final _timeFormat = DateFormat('HH:mm');
  static final _monthYearFormat = DateFormat('MMMM yyyy');
  static final _isoFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
  static final _backupFormat = DateFormat('yyyyMMdd_HHmm');

  static String nowIso() => _isoFormat.format(DateTime.now());

  /// Format a DateTime to ISO string
  static String formatIso(DateTime dt) => _isoFormat.format(dt);

  static String formatFull(String isoString) {
    final dt = DateTime.tryParse(isoString);
    if (dt == null) return isoString;
    return _fullFormat.format(dt);
  }

  static String formatShort(String isoString) {
    final dt = DateTime.tryParse(isoString);
    if (dt == null) return isoString;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(dt.year, dt.month, dt.day);

    if (dateOnly == today) return 'Hari ini ${_timeFormat.format(dt)}';
    if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Kemarin ${_timeFormat.format(dt)}';
    }
    return _fullFormat.format(dt);
  }

  static String formatMonthYear(DateTime dt) => _monthYearFormat.format(dt);

  static String backupTimestamp() => _backupFormat.format(DateTime.now());

  static DateTime get startOfMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  static DateTime get endOfMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  }

  static String get startOfMonthIso => _isoFormat.format(startOfMonth);
  static String get endOfMonthIso => _isoFormat.format(endOfMonth);

  /// Get start of a specific month as ISO string
  static String startOfMonthIsoFor(int year, int month) {
    return _isoFormat.format(DateTime(year, month, 1));
  }

  /// Get end of a specific month as ISO string
  static String endOfMonthIsoFor(int year, int month) {
    return _isoFormat.format(DateTime(year, month + 1, 0, 23, 59, 59));
  }

  /// Format a DateTime as "MMM yyyy" (e.g. "Jul 2026")
  static final _monthYearShortFormat = DateFormat('MMM yyyy');
  static String formatMonthYearShort(int year, int month) {
    return _monthYearShortFormat.format(DateTime(year, month));
  }
}
