import 'package:firebase_auth/firebase_auth.dart';
import 'package:beatwave/add_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:intl/intl.dart';
import '../transaction_model.dart';
import '../transaction_service.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final TransactionService _transactionService = TransactionService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: StreamBuilder<List<Transaction>>(
        stream: _transactionService.getTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No transactions found. Add some to see your dashboard!',
              ),
            );
          }

          final transactions = snapshot.data!;
          final now = DateTime.now();

          // Calculate summary for the current month
          final monthlyTransactions = transactions
              .where(
                (t) => t.date.month == now.month && t.date.year == now.year,
              )
              .toList();

          final totalIncome = monthlyTransactions
              .where((t) => t.type == 'income')
              .fold(0.0, (sum, t) => sum + t.amount);
          final totalExpenses = monthlyTransactions
              .where((t) => t.type == 'expense')
              .fold(0.0, (sum, t) => sum + t.amount);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Month: ${DateFormat.yMMMM().format(now)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildSummaryCard(
                        context,
                        'Total Income',
                        totalIncome,
                        Colors.green,
                      ),
                      const SizedBox(width: 16),
                      _buildSummaryCard(
                        context,
                        'Total Expenses',
                        totalExpenses,
                        Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Income vs. Expenses',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPieChart(context, totalIncome, totalExpenses),
                  const SizedBox(height: 24),
                  Text(
                    'Monthly Expenses (Last 6 Months)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMonthlyBarChart(context, transactions),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper method to build a summary card with better styling
  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    double amount,
    Color color,
  ) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                '₹${amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build the pie chart
  Widget _buildPieChart(
    BuildContext context,
    double totalIncome,
    double totalExpenses,
  ) {
    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              color: Colors.green,
              value: totalIncome,
              title: 'Income',
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: Colors.red,
              value: totalExpenses,
              title: 'Expenses',
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
          sectionsSpace: 4,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildMonthlyBarChart(
    BuildContext context,
    List<Transaction> transactions,
  ) {
    final now = DateTime.now();
    final Map<String, double> monthlyExpense = {};

    // Build data for last 6 months
    for (int i = 0; i < 6; i++) {
      final date = DateTime(now.year, now.month - i);
      final monthName = DateFormat.MMM().format(date);
      final monthExpenses = transactions
          .where(
            (t) =>
                t.type == 'expense' &&
                t.date.year == date.year &&
                t.date.month == date.month,
          )
          .fold(0.0, (sum, t) => sum + t.amount);
      monthlyExpense[monthName] = monthExpenses;
    }

    // Reverse to show oldest to newest
    final monthNames = monthlyExpense.keys.toList().reversed.toList();
    final barGroups = monthNames.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: monthlyExpense[entry.value]!,
            color: Colors.red,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              barGroups: barGroups,
              alignment: BarChartAlignment.spaceAround,
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 &&
                          value.toInt() < monthNames.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            monthNames[value.toInt()],
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }
                      return const Text('');
                    },
                    reservedSize: 32,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '₹${value.toInt()}',
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: null,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                  left: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              minY: 0,
            ),
          ),
        ),
      ),
    );
  }
}
