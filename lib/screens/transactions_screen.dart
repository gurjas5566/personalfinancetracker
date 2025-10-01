import 'dart:ffi';

import 'package:flutter/material.dart';
import '../add_transaction_screen.dart';
import '../transaction_model.dart';
import '../transaction_service.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends StatelessWidget {
  TransactionsScreen({super.key});

  final TransactionService _transactionService = TransactionService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
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
            return const Center(child: Text('No transactions yet.'));
          }

          final transactions = snapshot.data!;
          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final isIncome = transaction.type == 'income';

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isIncome
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    child: Icon(
                      isIncome ? Icons.attach_money : Icons.money_off,
                      color: isIncome ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(
                    transaction.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${DateFormat.yMMMd().format(transaction.date)} | ${transaction.category}',
                  ),
                  trailing: Text(
                    '${isIncome ? '+' : '-'} ₹${transaction.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: isIncome ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    Get.to(
                      () => AddTransactionScreen(transaction: transaction),
                    );
                  },
                  onLongPress: () {
                    Get.defaultDialog(
                      title: 'Delete Transaction',
                      content: const Text(
                        'Are you sure you want to delete this transaction?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await _transactionService.deleteTransaction(
                              transaction.id,
                            );
                            Get.back();
                            Get.snackbar(
                              'Success',
                              'Transaction deleted successfully!',
                            );
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const AddTransactionScreen());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
