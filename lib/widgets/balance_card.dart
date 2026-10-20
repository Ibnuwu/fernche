import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/formatters.dart';
import '../core/theme.dart';

class BalanceCard extends StatelessWidget {
  final int netBalance;
  final int totalIncome;
  final int totalExpense;
  final int doneProjects;
  final int monthlyIncome;
  final int monthlyExpense;

  const BalanceCard({
    super.key,
    required this.netBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.doneProjects,
    required this.monthlyIncome,
    required this.monthlyExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FerncheColors.softGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: FerncheColors.cardBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Net Balance',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: FerncheColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          _buildBalance(),
          const SizedBox(height: 16),
          _buildSummaryRow(),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _buildMonthlyRow(context),
        ],
      ),
    );
  }

  Widget _buildBalance() {
    final isNegative = netBalance < 0;
    final color = isNegative ? FerncheColors.dangerRed : FerncheColors.white;
    final prefix = isNegative ? '- ' : '';
    final absBalance = netBalance.abs();

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${prefix}Rp ',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: color.withValues(alpha: 0.7),
            ),
          ),
          TextSpan(
            text: FerncheFormatters.formatAmount(absBalance),
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        _summaryItem(
          icon: Icons.arrow_downward_rounded,
          label: 'Income',
          value: FerncheFormatters.formatCompact(totalIncome),
          color: FerncheColors.terminalGreen,
        ),
        const SizedBox(width: 16),
        _summaryItem(
          icon: Icons.arrow_upward_rounded,
          label: 'Expense',
          value: FerncheFormatters.formatCompact(totalExpense),
          color: FerncheColors.dangerRed,
        ),
        const SizedBox(width: 16),
        _summaryItem(
          icon: Icons.check_circle_outline_rounded,
          label: 'Projects',
          value: '$doneProjects done',
          color: FerncheColors.terminalGreen,
        ),
      ],
    );
  }

  Widget _summaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: FerncheColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: FerncheColors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyRow(BuildContext context) {
    final monthBalance = monthlyIncome - monthlyExpense;
    return Row(
      children: [
        Expanded(
          child: _monthItem(
            'Bulan ini',
            Icons.trending_up_rounded,
            FerncheFormatters.formatAmount(monthlyIncome),
            FerncheColors.terminalGreen,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _monthItem(
            'Pengeluaran',
            Icons.trending_down_rounded,
            FerncheFormatters.formatAmount(monthlyExpense),
            FerncheColors.dangerRed,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _monthItem(
            'Balance',
            Icons.account_balance_wallet_outlined,
            FerncheFormatters.formatAmount(monthBalance.abs()),
            monthBalance >= 0
                ? FerncheColors.terminalGreen
                : FerncheColors.dangerRed,
          ),
        ),
      ],
    );
  }

  Widget _monthItem(String label, IconData icon, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: FerncheColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
