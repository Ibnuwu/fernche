import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../data/backup_service.dart';

class BackupProvider extends ChangeNotifier {
  final BackupService _service = BackupService();

  String? _lastBackup;
  bool _isExporting = false;
  bool _isBackingUp = false;
  String? _statusMessage;

  String? get lastBackup => _lastBackup;
  bool get isExporting => _isExporting;
  bool get isBackingUp => _isBackingUp;
  String? get statusMessage => _statusMessage;

  BackupProvider() {
    _loadLastBackup();
  }

  Future<void> _loadLastBackup() async {
    _lastBackup = await _service.getLastBackupTime();
    notifyListeners();
  }

  /// Auto backup when app opens and network is available
  Future<void> autoBackupIfConnected() async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      final hasConnection = connectivity.any(
        (c) => c != ConnectivityResult.none,
      );

      if (hasConnection) {
        _isBackingUp = true;
        notifyListeners();

        final path = await _service.createBackup();
        if (path != null) {
          _lastBackup = await _service.getLastBackupTime();
          _statusMessage = 'Backup berhasil';
        }

        _isBackingUp = false;
        notifyListeners();
      }
    } catch (e) {
      _isBackingUp = false;
      notifyListeners();
    }
  }

  /// Manual export database
  Future<void> exportDatabase() async {
    _isExporting = true;
    _statusMessage = null;
    notifyListeners();

    final path = await _service.exportDatabase();
    _isExporting = false;
    _statusMessage = path != null ? 'Export berhasil' : 'Export gagal';
    notifyListeners();
  }

  /// Restore from backup path
  Future<bool> restoreBackup(String path) async {
    final result = await _service.restoreBackup(path);
    if (result) {
      _statusMessage = 'Restore berhasil';
      await _loadLastBackup();
    } else {
      _statusMessage = 'Restore gagal';
    }
    notifyListeners();
    return result;
  }
}
