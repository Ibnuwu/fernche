import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/date_utils.dart';
import 'providers/backup_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/ledger_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/ledger_screen.dart';
import 'screens/repository_screen.dart';
import 'widgets/fernche_app_bar.dart';
import 'data/report_service.dart';
import 'package:home_widget/home_widget.dart';

class FerncheApp extends StatefulWidget {
  const FerncheApp({super.key});

  @override
  State<FerncheApp> createState() => _FerncheAppState();
}

class _FerncheAppState extends State<FerncheApp> {
  int _currentIndex = 0;

  final _screens = const [
    DashboardScreen(),
    LedgerScreen(),
    RepositoryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Auto backup on app open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BackupProvider>().autoBackupIfConnected();
      _handleInitialWidgetLaunch();
    });
    HomeWidget.widgetClicked.listen(_handleWidgetUri);
  }

  void _handleInitialWidgetLaunch() async {
    final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    if (uri != null) {
      _handleWidgetUri(uri);
    }
  }

  void _handleWidgetUri(Uri? uri) {
    if (uri == null) return;
    if (uri.scheme == 'fernche' && uri.host == 'quick_add') {
      setState(() => _currentIndex = 1);
      context.read<LedgerProvider>().triggerAddSheet();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0
          ? FerncheAppBar(
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded),
                  color: FerncheColors.softGray,
                  onSelected: _handleMenu,
                  itemBuilder: (context) => [
                    _menuItem('export', Icons.upload_file_rounded, 'Export Database'),
                    _menuItem('report', Icons.analytics_rounded, 'Laporan Bulanan'),
                    _menuItem('backup_info', Icons.info_outline_rounded, 'Backup Info'),
                  ],
                ),
              ],
            )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) {
          setState(() => _currentIndex = i);
          if (i == 0) {
            context.read<DashboardProvider>().refresh();
          }
        },
        backgroundColor: FerncheColors.softGray,
        indicatorColor: FerncheColors.terminalGreen.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(
              Icons.dashboard_rounded,
              color: FerncheColors.terminalGreen,
            ),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(
              Icons.receipt_long_rounded,
              color: FerncheColors.terminalGreen,
            ),
            label: 'Ledger',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(
              Icons.folder_rounded,
              color: FerncheColors.terminalGreen,
            ),
            label: 'Repository',
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: FerncheColors.white),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: FerncheColors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenu(String value) async {
    final backup = context.read<BackupProvider>();

    switch (value) {
      case 'export':
        await backup.exportDatabase();
        if (mounted && backup.statusMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(backup.statusMessage!)),
          );
        }
        break;
      case 'report':
        _showMonthYearReportDialog();
        break;
      case 'backup_info':
        _showBackupInfo();
        break;
    }
  }

  void _showMonthYearReportDialog() {
    final now = DateTime.now();
    int selectedYear = now.year;
    int selectedMonth = now.month;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: FerncheColors.softGray,
              title: Text(
                'Ekspor Laporan Bulanan',
                style: GoogleFonts.inter(
                  color: FerncheColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Pilih bulan dan tahun untuk laporan Excel (.xlsx).',
                    style: GoogleFonts.inter(color: FerncheColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          dropdownColor: FerncheColors.softGray,
                          initialValue: selectedMonth,
                          items: List.generate(12, (index) {
                            final month = index + 1;
                            final label = FerncheDateUtils.formatMonthYearShort(2026, month).split(' ').first;
                            return DropdownMenuItem(
                              value: month,
                              child: Text(label, style: const TextStyle(color: FerncheColors.white)),
                            );
                          }),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => selectedMonth = val);
                            }
                          },
                          decoration: const InputDecoration(labelText: 'Bulan'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          dropdownColor: FerncheColors.softGray,
                          initialValue: selectedYear,
                          items: List.generate(5, (index) {
                            final year = now.year - 2 + index;
                            return DropdownMenuItem(
                              value: year,
                              child: Text(year.toString(), style: const TextStyle(color: FerncheColors.white)),
                            );
                          }),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => selectedYear = val);
                            }
                          },
                          decoration: const InputDecoration(labelText: 'Tahun'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal', style: TextStyle(color: FerncheColors.textSecondary)),
                ),
                FilledButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final reportService = ReportService();
                    final path = await reportService.generateMonthlyReport(selectedYear, selectedMonth);
                    if (path != null) {
                      await reportService.shareReport(path);
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gagal membuat laporan bulanan.')),
                      );
                    }
                  },
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('Ekspor'),
                  style: FilledButton.styleFrom(
                    backgroundColor: FerncheColors.terminalGreen,
                    foregroundColor: FerncheColors.matteBlack,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showBackupInfo() {
    final backup = context.read<BackupProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.backup_rounded,
              color: FerncheColors.terminalGreen,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Backup',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow(
              'Last Backup',
              backup.lastBackup != null
                  ? FerncheDateUtils.formatFull(backup.lastBackup!)
                  : 'Belum ada',
            ),
            const SizedBox(height: 8),
            _infoRow(
              'Status',
              backup.isBackingUp ? 'Backing up...' : 'Ready',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              await backup.exportDatabase();
              if (mounted && backup.statusMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(backup.statusMessage!)),
                );
              }
            },
            icon: const Icon(Icons.upload_file_rounded, size: 18),
            label: const Text('Export'),
            style: FilledButton.styleFrom(
              backgroundColor: FerncheColors.terminalGreen,
              foregroundColor: FerncheColors.matteBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: FerncheColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: FerncheColors.white,
            ),
          ),
        ),
      ],
    );
  }
}
