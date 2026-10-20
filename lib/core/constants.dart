class AppConstants {
  // Database
  static const String dbName = 'fernche.db';
  static const int dbVersion = 2;

  // Tables
  static const String tableTransactions = 'transactions';
  static const String tableNotes = 'notes';
  static const String tableAppMeta = 'app_meta';
  static const String tableBudgets = 'budgets';

  // Transaction types
  static const String typeIncome = 'income';
  static const String typeExpense = 'expense';

  // Transaction sources
  static const String sourceManual = 'manual';
  static const String sourceProjectAuto = 'project_auto';

  // Note tags
  static const List<String> noteTags = [
    'General',
    'Idea',
    'Project',
    'Code Snippet',
    'Organization',
  ];

  // Note statuses
  static const List<String> noteStatuses = [
    'OPEN',
    'PROGRESS',
    'DONE',
    'ARCHIVED',
  ];

  // Transaction categories
  static const List<String> transactionCategories = [
    'General',
    'Transportasi',
    'Makan',
    'Main',
    'Beli Barang',
    'Entertainment',
    'Project',
  ];

  // App meta keys
  static const String metaLastCategory = 'last_category';
  static const String metaLastBackup = 'last_backup';

  // Pagination
  static const int pageSize = 20;

  // Backup
  static const int maxBackupCount = 5;
  static const String backupPrefix = 'fernche_backup_';
}
