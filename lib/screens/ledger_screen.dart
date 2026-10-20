import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../core/formatters.dart';
import '../core/theme.dart';
import '../core/date_utils.dart';
import '../providers/ledger_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/budget_provider.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/amount_input.dart';
import '../widgets/tag_chip.dart';
import '../widgets/fernche_app_bar.dart';
import '../models/transaction_model.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<LedgerProvider>().loadMore();
    }
  }

  void _showTransactionDetails(BuildContext context, TransactionModel txn) {
    final isIncome = txn.isIncome;
    final color = isIncome ? FerncheColors.terminalGreen : FerncheColors.dangerRed;

    showModalBottomSheet(
      context: context,
      backgroundColor: FerncheColors.softGray,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: FerncheColors.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        txn.isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                        color: color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            txn.category,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: FerncheColors.white,
                            ),
                          ),
                          Text(
                            txn.type == 'income' ? 'Pemasukan' : 'Pengeluaran',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: FerncheColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Nominal',
                  style: GoogleFonts.inter(fontSize: 12, color: FerncheColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${FerncheFormatters.formatAmount(txn.amount)}',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Tanggal & Waktu',
                  style: GoogleFonts.inter(fontSize: 12, color: FerncheColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  FerncheDateUtils.formatFull(txn.createdAt),
                  style: GoogleFonts.inter(fontSize: 14, color: FerncheColors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  'Catatan',
                  style: GoogleFonts.inter(fontSize: 12, color: FerncheColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  txn.note?.isNotEmpty == true ? txn.note! : '-',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: FerncheColors.white,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                if (txn.source != 'manual') ...[
                  Text(
                    'Sumber Otomatis',
                    style: GoogleFonts.inter(fontSize: 12, color: FerncheColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dibuat otomatis dari Project/Note (ID: ${txn.sourceId})',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: FerncheColors.terminalGreen,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: FilledButton.styleFrom(
                    backgroundColor: FerncheColors.surfaceLight,
                    foregroundColor: FerncheColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Tutup'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showManageBudgetsSheet(BuildContext context) {
    final budgetProvider = context.read<BudgetProvider>();
    final controllers = <String, TextEditingController>{};

    for (final category in AppConstants.transactionCategories) {
      final currentLimit = budgetProvider.budgets[category]?.limitAmount ?? 0;
      controllers[category] = TextEditingController(
        text: currentLimit > 0 ? FerncheFormatters.formatAmount(currentLimit) : '',
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: FerncheColors.softGray,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: FerncheColors.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Atur Batas Budget Bulanan',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: FerncheColors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Atur batas maksimum pengeluaran bulanan per kategori. Kosongkan untuk tanpa batas.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: FerncheColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                ...AppConstants.transactionCategories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            category,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: FerncheColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 4,
                          child: TextField(
                            controller: controllers[category],
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: FerncheColors.terminalGreen),
                            decoration: InputDecoration(
                              hintText: 'Tanpa batas',
                              prefixText: 'Rp ',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () async {
                    for (final category in AppConstants.transactionCategories) {
                      final text = controllers[category]?.text ?? '';
                      final amount = FerncheFormatters.parseAmount(text);
                      if (amount > 0) {
                        await budgetProvider.setBudget(category, amount);
                      } else {
                        await budgetProvider.removeBudget(category);
                      }
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: FerncheColors.terminalGreen,
                    foregroundColor: FerncheColors.matteBlack,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      for (final controller in controllers.values) {
        controller.dispose();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LedgerProvider>(
      builder: (context, ledger, _) {
        if (ledger.showAddSheetOnLoad) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _showAddTransaction(context, quickAdd: true);
              ledger.consumeAddSheet();
            }
          });
        }

        return Scaffold(
          backgroundColor: FerncheColors.matteBlack,
          appBar: FerncheAppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.track_changes_rounded, color: FerncheColors.terminalGreen),
                tooltip: 'Atur Budget',
                onPressed: () => _showManageBudgetsSheet(context),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                _buildFilterBar(ledger),
                Expanded(
                  child: ledger.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: FerncheColors.terminalGreen,
                          ),
                        )
                      : ledger.transactions.isEmpty
                          ? _buildEmpty()
                          : RefreshIndicator(
                              color: FerncheColors.terminalGreen,
                              onRefresh: ledger.loadTransactions,
                              child: ListView.separated(
                                controller: _scrollController,
                                padding: const EdgeInsets.only(bottom: 80),
                                itemCount: ledger.transactions.length + (ledger.hasMore ? 1 : 0),
                                separatorBuilder: (_, _) => const Divider(
                                  height: 1,
                                  indent: 68,
                                ),
                                itemBuilder: (context, index) {
                                  if (index == ledger.transactions.length) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 16),
                                        child: CircularProgressIndicator(
                                          color: FerncheColors.terminalGreen,
                                        ),
                                      ),
                                    );
                                  }

                                  final txn = ledger.transactions[index];
                                  final budgetProvider = context.watch<BudgetProvider>();
                                  final isWarning = budgetProvider.isCategoryWarning(txn.category);
                                  final isOver = budgetProvider.isCategoryOverBudget(txn.category);

                                  return TransactionTile(
                                    transaction: txn,
                                    budgetWarning: isWarning,
                                    budgetOver: isOver,
                                    onDismissed: () => _onDelete(txn.id!),
                                    onTap: () => _showTransactionDetails(context, txn),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddTransaction(context),
            child: const Icon(Icons.add_rounded),
          ),
        );
      },
    );
  }

  Widget _buildFilterBar(LedgerProvider ledger) {
    final filters = [
      ('All', LedgerFilter.all),
      ('Income', LedgerFilter.income),
      ('Expense', LedgerFilter.expense),
      ('This Month', LedgerFilter.thisMonth),
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (label, filter) = filters[index];
          return TagChip(
            label: label,
            isSelected: ledger.filter == filter,
            onTap: () => ledger.setFilter(filter),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 48,
            color: FerncheColors.textSecondary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada transaksi',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: FerncheColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _onDelete(int id) async {
    final ledger = context.read<LedgerProvider>();
    final dashboard = context.read<DashboardProvider>();
    final txn = await ledger.deleteTransaction(id);
    await dashboard.refresh();
    if (!context.mounted) return;

    if (txn != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Transaksi dihapus'),
          action: SnackBarAction(
            label: 'Undo',
            textColor: FerncheColors.terminalGreen,
            onPressed: () async {
              await ledger.undoDelete(txn);
              await dashboard.refresh();
            },
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showAddTransaction(BuildContext context, {bool quickAdd = false}) {
    final ledger = context.read<LedgerProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: FerncheColors.softGray,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AddTransactionSheet(
        defaultCategory: ledger.lastCategory,
        defaultType: quickAdd ? 'expense' : 'income',
      ),
    );
  }
}

class _AddTransactionSheet extends StatefulWidget {
  final String defaultCategory;
  final String defaultType;

  const _AddTransactionSheet({
    required this.defaultCategory,
    required this.defaultType,
  });

  @override
  State<_AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<_AddTransactionSheet> {
  late String _type;
  late String _category;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _type = widget.defaultType;
    _category = widget.defaultCategory;
    _amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: FerncheColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _buildTypeSelector(),
              const SizedBox(height: 20),

              AmountInput(controller: _amountController),
              _buildBudgetSummary(),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _category,
                dropdownColor: FerncheColors.surfaceLight,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: AppConstants.transactionCategories
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _category = val);
                },
              ),
              const SizedBox(height: 16),

              // Date Picker Field
              InkWell(
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: now,
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: FerncheColors.terminalGreen,
                            onPrimary: FerncheColors.matteBlack,
                            surface: FerncheColors.softGray,
                            onSurface: FerncheColors.white,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: FerncheColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: FerncheColors.cardBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tanggal Transaksi',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: FerncheColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd MMM yyyy').format(_selectedDate),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: FerncheColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.calendar_month_rounded,
                        color: FerncheColors.terminalGreen,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Catatan (opsional)',
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Simpan'),
                style: FilledButton.styleFrom(
                  backgroundColor: FerncheColors.terminalGreen,
                  foregroundColor: FerncheColors.matteBlack,
                  minimumSize: const Size.fromHeight(50),
                  textStyle: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: FerncheColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _typeButton('Income', 'income', FerncheColors.terminalGreen),
          _typeButton('Expense', 'expense', FerncheColors.dangerRed),
        ],
      ),
    );
  }

  Widget _typeButton(String label, String value, Color color) {
    final selected = _type == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: selected ? Border.all(color: color, width: 1.5) : null,
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? color : FerncheColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetSummary() {
    if (_type != 'expense') return const SizedBox.shrink();
    final budgetProvider = context.watch<BudgetProvider>();
    final status = budgetProvider.getBudgetStatus(_category);
    if (status == null) return const SizedBox.shrink();

    final amount = FerncheFormatters.parseAmount(_amountController.text);
    final projectedSpent = status.spent + amount;
    final percentage = status.limitAmount > 0 ? (projectedSpent / status.limitAmount) : 0.0;
    final isOver = projectedSpent > status.limitAmount;
    final isNear = percentage >= 0.8 && !isOver;

    final Color color = isOver
        ? FerncheColors.dangerRed
        : isNear
            ? const Color(0xFFFFA726)
            : FerncheColors.terminalGreen;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isOver
                    ? '⚠️ Melebihi Budget!'
                    : isNear
                        ? '⚠️ Mendekati Batas!'
                        : 'Status Budget',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                'Rp ${FerncheFormatters.formatAmount(projectedSpent)} / Rp ${FerncheFormatters.formatAmount(status.limitAmount)}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: percentage.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: FerncheColors.cardBorder,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  void _save() async {
    final amount = FerncheFormatters.parseAmount(_amountController.text);
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nominal yang valid')),
      );
      return;
    }

    final ledger = context.read<LedgerProvider>();
    final dashboard = context.read<DashboardProvider>();

    await ledger.addTransaction(
      type: _type,
      amount: amount,
      category: _category,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      date: _selectedDate,
    );
    await dashboard.refresh();

    if (mounted) {
      context.read<BudgetProvider>().loadBudgets();
    }

    if (!context.mounted) return;

    if (mounted) Navigator.pop(context);
  }
}
