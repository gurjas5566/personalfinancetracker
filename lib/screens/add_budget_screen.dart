import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../budget_model.dart';
import '../transaction_service.dart';

class AddBudgetScreen extends StatefulWidget {
  final Budget? budget;

  const AddBudgetScreen({super.key, this.budget});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final TransactionService _transactionService = TransactionService();

  late TextEditingController _amountController;
  late String _selectedCategory;
  late DateTime _startDate;
  late DateTime _endDate;

  final List<String> categories = [
    'General',
    'Food',
    'Shopping',
    'Bills',
    'Salary',
  ];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.budget?.amount.toString() ?? '',
    );
    _selectedCategory = widget.budget?.category ?? categories.first;
    _startDate = widget.budget?.startDate ?? DateTime.now();
    _endDate =
        widget.budget?.endDate ?? DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final budget = Budget(
        id: widget.budget?.id ?? '',
        category: _selectedCategory,
        amount: double.parse(_amountController.text),
        startDate: _startDate,
        endDate: _endDate,
        userId: _transactionService.currentUserId,
      );

      try {
        if (widget.budget == null) {
          await _transactionService.addBudget(budget);
          Get.back();
          Get.snackbar('Success', 'Budget added successfully!');
        } else {
          await _transactionService.updateBudget(budget);
          Get.back();
          Get.snackbar('Success', 'Budget updated successfully!');
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to save budget: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.budget == null ? 'Add Budget' : 'Edit Budget'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories
                    .map(
                      (category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Budget Amount (₹)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Start Date'),
                trailing: Text(DateFormat.yMMMd().format(_startDate)),
                onTap: () => _selectDate(context, true),
              ),
              ListTile(
                title: const Text('End Date'),
                trailing: Text(DateFormat.yMMMd().format(_endDate)),
                onTap: () => _selectDate(context, false),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(
                  widget.budget == null ? 'Add Budget' : 'Update Budget',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
