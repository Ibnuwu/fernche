import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import '../core/constants.dart';
import '../core/date_utils.dart';
import 'app_database.dart';

/// Abstract backup service interface for future cloud implementations
abstract class BackupServiceInterface {
  Future<String?> createBackup();
  Future<bool> restoreBackup(String path);
  Future<String?> exportDatabase();
  Future<List<FileSystemEntity>> listBackups();
  Future<void> pruneBackups();
}

class BackupService implements BackupServiceInterface {
  final AppDatabase _appDb = AppDatabase.instance;

  /// Get the backup directory
  Future<Directory> get _backupDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(join(appDir.path, 'fernche_backups'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  /// Create a local backup of the database
  @override
  Future<String?> createBackup() async {
    try {
      final dbPath = await _appDb.databasePath;
      final dir = await _backupDir;
      final timestamp = FerncheDateUtils.backupTimestamp();
      final backupName = '${AppConstants.backupPrefix}$timestamp.db';
      final backupPath = join(dir.path, backupName);

      final sourceFile = File(dbPath);
      if (!await sourceFile.exists()) return null;

      await sourceFile.copy(backupPath);

      // Update last backup timestamp
      await _appDb.setMeta(
        AppConstants.metaLastBackup,
        FerncheDateUtils.nowIso(),
      );

      // Prune old backups
      await pruneBackups();

      return backupPath;
    } catch (e) {
      return null;
    }
  }

  /// Restore database from a backup file
  @override
  Future<bool> restoreBackup(String path) async {
    try {
      final backupFile = File(path);
      if (!await backupFile.exists()) return false;

      // Create safety backup before restore
      await createBackup();

      // Close current database
      await _appDb.close();

      // Copy backup to database path
      final dbPath = await getDatabasesPath();
      final targetPath = join(dbPath, AppConstants.dbName);
      await backupFile.copy(targetPath);

      // Reopen database
      await _appDb.database;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Export database via share_plus
  @override
  Future<String?> exportDatabase() async {
    try {
      final dbPath = await _appDb.databasePath;
      final file = File(dbPath);
      if (!await file.exists()) return null;

      // Copy to a shareable location with timestamp
      final tempDir = await getTemporaryDirectory();
      final timestamp = FerncheDateUtils.backupTimestamp();
      final exportName = 'fernche_export_$timestamp.db';
      final exportPath = join(tempDir.path, exportName);
      await file.copy(exportPath);

      await Share.shareXFiles(
        [XFile(exportPath)],
        text: 'Fernche_Database_Backup.db',
      );

      return exportPath;
    } catch (e) {
      return null;
    }
  }

  /// List all backups sorted by newest first
  @override
  Future<List<FileSystemEntity>> listBackups() async {
    try {
      final dir = await _backupDir;
      final files =
          dir
              .listSync()
              .where(
                (f) =>
                    f is File &&
                    basename(f.path).startsWith(AppConstants.backupPrefix),
              )
              .toList();
      files.sort((a, b) => b.path.compareTo(a.path));
      return files;
    } catch (e) {
      return [];
    }
  }

  /// Remove old backups, keeping only the most recent N
  @override
  Future<void> pruneBackups() async {
    try {
      final backups = await listBackups();
      if (backups.length > AppConstants.maxBackupCount) {
        for (var i = AppConstants.maxBackupCount; i < backups.length; i++) {
          await backups[i].delete();
        }
      }
    } catch (_) {}
  }

  /// Get last backup timestamp
  Future<String?> getLastBackupTime() async {
    return _appDb.getMeta(AppConstants.metaLastBackup);
  }
}
