import 'package:beatwave/screens/add_budget_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../budget_model.dart';
import '../transaction_service.dart';
import '../transaction_model.dart';
import 'package:intl/intl.dart';

class BudgetsScreen extends StatelessWidget {
  BudgetsScreen({super.key});

  final TransactionService _transactionService = TransactionService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Get.to(() => const AddBudgetScreen());
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Budget>>(
        stream: _transactionService.getBudget(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No budgets found. Add one to start budgeting!'),
            );
          }

          final budgets = snapshot.data!;
          return ListView.builder(
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];
              return BudgetCard(
                budget: budget,
                transactionService: _transactionService,
              );
            },
          );
        },
      ),
    );
  }
}

class BudgetCard extends StatelessWidget {
  final Budget budget;
  final TransactionService transactionService;

  const BudgetCard({
    super.key,
    required this.budget,
    required this.transactionService,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: StreamBuilder<List<Transaction>>(
        stream: transactionService.getTransactions(),
        builder: (context, snapshot) {
          double totalSpent = 0.0;
          if (snapshot.hasData) {
            totalSpent = snapshot.data!
                .where(
                  (t) =>
                      t.type == 'expense' &&
                      t.category == budget.category &&
                      t.date.isAfter(
                        budget.startDate.subtract(const Duration(days: 1)),
                      ) &&
                      t.date.isBefore(
                        budget.endDate.add(const Duration(days: 1)),
                      ),
                )
                .fold(0.0, (sum, t) => sum + t.amount);
          }

          final progress = budget.amount > 0
              ? (totalSpent / budget.amount).clamp(0.0, 1.0)
              : 0.0;
          final remainingAmount = budget.amount - totalSpent;
          final isOverBudget = remainingAmount < 0;

          return ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              'Budget for ${budget.category}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Period: ${DateFormat.yMMMd().format(budget.startDate)} - ${DateFormat.yMMMd().format(budget.endDate)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Theme.of(context).cardColor,
                  color: isOverBudget
                      ? Colors.red
                      : Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Spent: ₹${totalSpent.toStringAsFixed(2)} / Budget: ₹${budget.amount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  isOverBudget
                      ? 'Over budget by: ₹${remainingAmount.abs().toStringAsFixed(2)}'
                      : 'Remaining: ₹${remainingAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: isOverBudget ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            onTap: () {
              Get.to(() => AddBudgetScreen(budget: budget));
            },
            onLongPress: () {
              Get.defaultDialog(
                title: 'Delete Budget',
                content: const Text(
                  'Are you sure you want to delete this budget?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await transactionService.deleteBudget(budget.id);
                      Get.back();
                      Get.snackbar('Success', 'Budget deleted successfully!');
                    },
                    child: const Text('Delete'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
