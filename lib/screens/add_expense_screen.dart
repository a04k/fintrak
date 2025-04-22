import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/category.dart';
import '../models/expense.dart';
import '../services/expense_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  
  ExpenseCategory _selectedCategory = ExpenseCategory.other;
  DateTime _selectedDate = DateTime.now();
  
  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }
  
  // Format date for display
  String get formattedDate => DateFormat('MMMM d, yyyy').format(_selectedDate);

  // Show date picker
  Future<void> _selectDate(BuildContext context) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDarkMode 
              ? const ColorScheme.dark(
                  primary: Colors.white,
                  onPrimary: Colors.black,
                  surface: Color(0xFF2A2A2A),
                  onSurface: Colors.white,
                )
              : const ColorScheme.light(
                  primary: Colors.black,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }
  
  // Submit the form
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Get amount from text field
      final amountText = _amountController.text.trim();
      final amount = double.tryParse(amountText) ?? 0.0;
      
      // Create expense object
      final expense = Expense.create(
        description: _descriptionController.text.trim(),
        amount: amount,
        category: _selectedCategory,
        date: _selectedDate,
      );
      
      // Add expense using provider
      final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
      final success = await expenseProvider.addExpense(expense);
      
      if (success) {
        if (mounted) {
          // Show success message and pop the screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense added successfully')),
          );
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(expenseProvider.error ?? 'Failed to add expense'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    
    // Get currency code from provider
    final currencyCode = Provider.of<ExpenseProvider>(context).currencyCode;
    
    // Helper method to get currency symbol
    String getCurrencySymbol(String code) {
      return '£';
    }
    
    final currencySymbol = getCurrencySymbol(currencyCode);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Add Expense',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 28, // Increased size
          ),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        toolbarHeight: 100, // Increased for more spacing from top
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description field
              Text(
                'Description', 
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'What did you spend on?',
                  prefixIcon: Icon(Icons.description_outlined, color: isDarkMode ? Colors.grey[400] : Colors.grey[700]),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Amount field
              Text(
                'Amount', 
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.attach_money_outlined, color: isDarkMode ? Colors.grey[400] : Colors.grey[700]),
                  prefixText: '$currencySymbol ', // Changed from currencyCode to currencySymbol
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null) {
                    return 'Please enter a valid number';
                  }
                  if (amount <= 0) {
                    return 'Amount must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              // Category selection
              Text(
                'Category',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: ExpenseCategory.values.map((category) {
                  final isSelected = _selectedCategory == category;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? (isDarkMode ? Colors.white : Colors.black)
                            : (isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0)),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            category.icon,
                            size: 18,
                            color: isSelected
                                ? (isDarkMode ? Colors.black : Colors.white)
                                : textColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            category.displayName,
                            style: TextStyle(
                              color: isSelected
                                  ? (isDarkMode ? Colors.black : Colors.white)
                                  : textColor,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              
              // Date selection
              Text(
                'Date',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // Submit button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(
                    'Add Expense',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}