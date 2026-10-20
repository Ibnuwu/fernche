import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../core/date_utils.dart';
import 'transaction_dao.dart';

class ReportService {
  final TransactionDao _txnDao = TransactionDao();

  /// Generate a monthly report as .xlsx and return the file path
  Future<String?> generateMonthlyReport(int year, int month) async {
    try {
      final transactions = await _txnDao.getByMonth(year, month);
      final summary = await _txnDao.monthlySummaryByCategory(year, month);
      final monthLabel = FerncheDateUtils.formatMonthYearShort(year, month);

      final excel = Excel.createExcel();

      // ----- Sheet 1: Summary -----
      final summarySheet = excel['Summary'];

      // Title row
      summarySheet.appendRow([
        TextCellValue('Fernche Monthly Report'),
      ]);
      summarySheet.appendRow([
        TextCellValue(monthLabel),
      ]);
      summarySheet.appendRow([]); // blank row

      // Calculate totals
      int totalIncome = 0;
      int totalExpense = 0;
      for (final txn in transactions) {
        if (txn.isIncome) {
          totalIncome += txn.amount;
        } else {
          totalExpense += txn.amount;
        }
      }

      summarySheet.appendRow([
        TextCellValue('Total Income'),
        IntCellValue(totalIncome),
      ]);
      summarySheet.appendRow([
        TextCellValue('Total Expense'),
        IntCellValue(totalExpense),
      ]);
      summarySheet.appendRow([
        TextCellValue('Net Balance'),
        IntCellValue(totalIncome - totalExpense),
      ]);
      summarySheet.appendRow([]); // blank row

      // Category breakdown header
      summarySheet.appendRow([
        TextCellValue('Type'),
        TextCellValue('Category'),
        TextCellValue('Total'),
        TextCellValue('Count'),
      ]);

      // Category breakdown data
      for (final row in summary) {
        summarySheet.appendRow([
          TextCellValue(row['type'] as String),
          TextCellValue(row['category'] as String),
          IntCellValue((row['total'] as int?) ?? 0),
          IntCellValue((row['count'] as int?) ?? 0),
        ]);
      }

      // ----- Sheet 2: Transactions -----
      final txnSheet = excel['Transactions'];

      // Header row
      txnSheet.appendRow([
        TextCellValue('Date'),
        TextCellValue('Type'),
        TextCellValue('Category'),
        TextCellValue('Amount'),
        TextCellValue('Note'),
        TextCellValue('Source'),
      ]);

      // Transaction data
      for (final txn in transactions) {
        txnSheet.appendRow([
          TextCellValue(FerncheDateUtils.formatFull(txn.createdAt)),
          TextCellValue(txn.type),
          TextCellValue(txn.category),
          IntCellValue(txn.amount),
          TextCellValue(txn.note ?? ''),
          TextCellValue(txn.source),
        ]);
      }

      // Remove the default 'Sheet1' if it exists
      if (excel.sheets.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }

      // Save to temp directory
      final tempDir = await getTemporaryDirectory();
      final fileName = 'fernche_report_${year}_${month.toString().padLeft(2, '0')}.xlsx';
      final filePath = '${tempDir.path}/$fileName';
      final fileBytes = excel.save();
      if (fileBytes == null) return null;

      final file = File(filePath);
      await file.writeAsBytes(fileBytes);

      return filePath;
    } catch (e) {
      return null;
    }
  }

  /// Share the generated report via share_plus
  Future<void> shareReport(String filePath) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      text: 'Fernche Monthly Report',
    );
  }
}
