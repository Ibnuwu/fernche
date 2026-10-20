import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme.dart';
import '../core/formatters.dart';
import '../core/constants.dart';
import '../data/transaction_dao.dart';
import '../models/transaction_model.dart';
import '../providers/dashboard_provider.dart';
import '../providers/budget_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TransactionDao _txnDao = TransactionDao();

  @override
  Widget build(BuildContext context) {
    return Consumer2<DashboardProvider, BudgetProvider>(
      builder: (context, dash, budgetProvider, _) {
        if (dash.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: FerncheColors.terminalGreen,
            ),
          );
        }

        return RefreshIndicator(
          color: FerncheColors.terminalGreen,
          onRefresh: () async {
            await dash.refresh();
            await budgetProvider.loadBudgets();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              BalanceCard(
                netBalance: dash.netBalance,
                totalIncome: dash.totalIncome,
                totalExpense: dash.totalExpense,
                doneProjects: dash.doneProjectCount,
                monthlyIncome: dash.monthlyIncome,
                monthlyExpense: dash.monthlyExpense,
              ),
              _buildBudgetSection(context, budgetProvider),
              _buildChartSection(dash),
              _buildRecentActivity(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBudgetSection(BuildContext context, BudgetProvider budgetProvider) {
    final activeBudgets = budgetProvider.budgets.values.where((b) => b.limitAmount > 0).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: FerncheColors.softGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FerncheColors.cardBorder, width: 0.5),
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(
          'Budget Tracker',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: FerncheColors.white,
          ),
        ),
        leading: const Icon(
          Icons.track_changes_rounded,
          size: 20,
          color: FerncheColors.terminalGreen,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.settings_rounded, size: 20, color: FerncheColors.textSecondary),
          onPressed: () => _showManageBudgetsDialog(context, budgetProvider),
        ),
        children: [
          if (activeBudgets.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Belum ada limit budget yang diatur.',
                    style: GoogleFonts.inter(color: FerncheColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _showManageBudgetsDialog(context, budgetProvider),
                    icon: const Icon(Icons.add_rounded, color: FerncheColors.terminalGreen),
                    label: const Text('Atur Budget', style: TextStyle(color: FerncheColors.terminalGreen)),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: activeBudgets.map((budget) {
                  final category = budget.category;
                  final limit = budget.limitAmount;
                  final spent = budgetProvider.categoryExpenses[category] ?? 0;
                  final percentage = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
                  final isExceeded = spent >= limit;
                  final isApproaching = !isExceeded && percentage >= 0.8;

                  final progressColor = isExceeded
                      ? FerncheColors.dangerRed
                      : isApproaching
                          ? const Color(0xFFFFA726)
                          : FerncheColors.terminalGreen;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              category,
                              style: GoogleFonts.inter(
                                color: FerncheColors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'Rp ${FerncheFormatters.formatAmount(spent)} / Rp ${FerncheFormatters.formatAmount(limit)}',
                              style: GoogleFonts.inter(
                                color: isExceeded
                                    ? FerncheColors.dangerRed
                                    : isApproaching
                                        ? const Color(0xFFFFA726)
                                        : FerncheColors.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage,
                            backgroundColor: FerncheColors.surfaceLight,
                            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  void _showManageBudgetsDialog(BuildContext context, BudgetProvider budgetProvider) {
    final controllers = <String, TextEditingController>{};
    for (final cat in AppConstants.transactionCategories) {
      final currentLimit = budgetProvider.budgets[cat]?.limitAmount ?? 0;
      controllers[cat] = TextEditingController(
        text: currentLimit > 0 ? FerncheFormatters.formatAmount(currentLimit) : '',
      );
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: FerncheColors.softGray,
          title: Text(
            'Atur Budget Bulanan',
            style: GoogleFonts.inter(color: FerncheColors.white, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: AppConstants.transactionCategories.map((cat) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(cat, style: const TextStyle(color: FerncheColors.white, fontSize: 14)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: controllers[cat],
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: FerncheColors.terminalGreen, fontSize: 14, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              hintText: 'Tanpa batas',
                              prefixText: 'Rp ',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: FerncheColors.textSecondary)),
            ),
            FilledButton(
              onPressed: () async {
                for (final cat in AppConstants.transactionCategories) {
                  final text = controllers[cat]?.text ?? '';
                  final amount = FerncheFormatters.parseAmount(text);
                  if (amount > 0) {
                    await budgetProvider.setBudget(cat, amount);
                  } else {
                    await budgetProvider.removeBudget(cat);
                  }
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              style: FilledButton.styleFrom(
                backgroundColor: FerncheColors.terminalGreen,
                foregroundColor: FerncheColors.matteBlack,
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    ).then((_) {
      for (final controller in controllers.values) {
        controller.dispose();
      }
    });
  }

  Widget _buildChartSection(DashboardProvider dash) {
    if (dash.totalIncome == 0 && dash.totalExpense == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: FerncheColors.softGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FerncheColors.cardBorder, width: 0.5),
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(
          'Income vs Expense',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: FerncheColors.white,
          ),
        ),
        leading: const Icon(
          Icons.pie_chart_rounded,
          size: 20,
          color: FerncheColors.terminalGreen,
        ),
        children: [
          SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: dash.totalIncome.toDouble(),
                            color: FerncheColors.terminalGreen,
                            radius: 50,
                            title:
                                '${_percentage(dash.totalIncome, dash.totalIncome + dash.totalExpense)}%',
                            titleStyle: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: FerncheColors.matteBlack,
                            ),
                          ),
                          PieChartSectionData(
                            value: dash.totalExpense.toDouble(),
                            color: FerncheColors.dangerRed,
                            radius: 50,
                            title:
                                '${_percentage(dash.totalExpense, dash.totalIncome + dash.totalExpense)}%',
                            titleStyle: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: FerncheColors.white,
                            ),
                          ),
                        ],
                        sectionsSpace: 2,
                        centerSpaceRadius: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _legendItem(
                        'Income',
                        FerncheColors.terminalGreen,
                        FerncheFormatters.formatCompact(dash.totalIncome),
                      ),
                      const SizedBox(height: 8),
                      _legendItem(
                        'Expense',
                        FerncheColors.dangerRed,
                        FerncheFormatters.formatCompact(dash.totalExpense),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _percentage(int part, int total) {
    if (total == 0) return '0';
    return ((part / total) * 100).toStringAsFixed(0);
  }

  Widget _legendItem(String label, Color color, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: FerncheColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: FerncheColors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: FerncheColors.softGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FerncheColors.cardBorder, width: 0.5),
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(
          'Recent Activity',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: FerncheColors.white,
          ),
        ),
        leading: const Icon(
          Icons.history_rounded,
          size: 20,
          color: FerncheColors.terminalGreen,
        ),
        children: [
          FutureBuilder<List<TransactionModel>>(
            future: _txnDao.getRecent(limit: 5),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_rounded,
                        size: 32,
                        color: FerncheColors.textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Belum ada transaksi',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: FerncheColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: snapshot.data!
                    .map((t) => TransactionTile(transaction: t))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
