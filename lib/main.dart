import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/theme.dart';
import 'providers/backup_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/ledger_provider.dart';
import 'providers/notes_provider.dart';
import 'providers/budget_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LedgerProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => BackupProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
      ],
      child: MaterialApp(
        title: 'Fernche',
        debugShowCheckedModeBanner: false,
        theme: FerncheTheme.darkTheme,
        home: const FerncheApp(),
      ),
    ),
  );
}
