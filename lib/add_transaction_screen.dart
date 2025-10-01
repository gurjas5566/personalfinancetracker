import 'package:flutter/material.dart';
import 'transaction_model.dart';
import 'transaction_service.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TransactionService _transactionService = TransactionService();

  // Controllers for text fields
  late TextEditingController _titleController;
  late TextEditingController _amountController;

  // Selected values for dropdowns and date
  late String _selectedType;
  late String _selectedCategory;
  late DateTime _selectedDate;

  // Loading state
  bool _isLoading = false;

  // A list of categories for a start
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
    _titleController = TextEditingController(
      text: widget.transaction?.title ?? '',
    );
    _amountController = TextEditingController(
      text: widget.transaction?.amount.toString() ?? '',
    );
    _selectedType = widget.transaction?.type ?? 'expense';
    _selectedCategory = widget.transaction?.category ?? 'General';
    _selectedDate = widget.transaction?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // Method to show the date picker dialog
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Method to handle form submission
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      final transaction = Transaction(
        id: widget.transaction?.id ?? '', // Use existing ID for updates
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        type: _selectedType,
        category: _selectedCategory,
        userId: _transactionService.currentUserId,
      );

      try {
        if (widget.transaction == null) {
          // Add new transaction
          await _transactionService.addTransaction(transaction);

          // Clear form after successful add
          _titleController.clear();
          _amountController.clear();

          if (!mounted) return;

          setState(() {
            _isLoading = false;
            _selectedType = 'expense';
            _selectedCategory = 'General';
            _selectedDate = DateTime.now();
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction added successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // Update existing transaction
          await _transactionService.updateTransaction(transaction);

          if (!mounted) return;

          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction updated successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save transaction: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction == null ? 'Add Transaction' : 'Edit Transaction',
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Type Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: ['expense', 'income']
                        .map(
                          (type) => DropdownMenuItem<String>(
                            value: type,
                            child: Text(type.capitalizeFirst!),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Category Dropdown
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
                  // Date Picker Button
                  ListTile(
                    title: const Text('Date'),
                    trailing: Text(DateFormat('yMMMd').format(_selectedDate)),
                    onTap: () => _selectDate(context),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            widget.transaction == null
                                ? 'Add Transaction'
                                : 'Update Transaction',
                          ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
