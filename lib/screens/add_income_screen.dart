import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/income.dart';
import '../services/expense_provider.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sourceController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  
  @override
  void dispose() {
    _sourceController.dispose();
    _amountController.dispose();
    _notesController.dispose();
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
      
      // Create income object
      final income = Income.create(
        source: _sourceController.text.trim(),
        amount: amount,
        date: _selectedDate,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );
      
      // Add income using provider
      final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
      final success = await expenseProvider.addIncome(income);
      
      if (success) {
        if (mounted) {
          // Show success message and pop the screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Income added successfully')),
          );
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(expenseProvider.error ?? 'Failed to add income'),
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
    
    // Get currency symbol - always returns £ now
    String getCurrencySymbol(String code) {
      return '£';
    }
    
    final currencySymbol = getCurrencySymbol(currencyCode);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Add Income',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        toolbarHeight: 100,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Source field
              Text(
                'Income Source', 
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _sourceController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'What is the source of this income?',
                  prefixIcon: Icon(Icons.work_outline, color: isDarkMode ? Colors.grey[400] : Colors.grey[700]),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a source';
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
                  prefixText: '$currencySymbol ',
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
              const SizedBox(height: 24),
              
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
              const SizedBox(height: 24),
              
              // Notes field
              Text(
                'Notes (Optional)', 
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Add notes about this income',
                  prefixIcon: Icon(Icons.note_outlined, color: isDarkMode ? Colors.grey[400] : Colors.grey[700]),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 40),
              
              // Submit button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text(
                    'Add Income',
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