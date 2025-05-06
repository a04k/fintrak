import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../models/category.dart';
import '../models/expense.dart';
import '../services/expense_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expense;
  final bool isEditing;

  const AddExpenseScreen({
    super.key,
    this.expense,
    this.isEditing = false,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isSubmitting = false;
  
  ExpenseCategory _selectedCategory = ExpenseCategory.other;
  DateTime _selectedDate = DateTime.now();
  File? _receiptImage;
  final _picker = ImagePicker();
  
  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _descriptionController.text = widget.expense!.description;
      _amountController.text = widget.expense!.amount.toString();
      _selectedDate = widget.expense!.date;
      _selectedCategory = widget.expense!.category;
    }
  }
  
  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }
  
  // Format date for display
  String get formattedDate => DateFormat('MMMM d, yyyy').format(_selectedDate);
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  Future<void> _getImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          _receiptImage = File(pickedFile.path);
        });
        // TODO: Process the receipt image for text extraction
      }
    } catch (e) {
      // Handle any errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick image')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  // Submit the form
  void _submitForm() async {
    if (_isSubmitting) return; // Prevent double submission
    
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      
      try {
        // Get amount from text field
        final amountText = _amountController.text.trim();
        final amount = double.parse(amountText) ?? 0.0;
        
        // Create expense object
        final expense = Expense(
          id: widget.expense?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          description: _descriptionController.text.trim(),
          amount: amount,
          date: _selectedDate,
          category: _selectedCategory,
        );
        
        // Add expense using provider
        final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
        bool success;
        if (widget.isEditing) {
          success = await expenseProvider.updateExpense(expense);
        } else {
          success = await expenseProvider.addExpense(expense);
        }
        
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
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    
    // Get currency code from provider without listening to changes
    final currencyCode = Provider.of<ExpenseProvider>(context, listen: false).currencyCode;
    final currencySymbol = '£';
    
    return WillPopScope(
      onWillPop: () async => !_isSubmitting,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: Text(
            widget.isEditing ? 'Edit Expense' : 'Add Expense',
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
          actions: [
            IconButton(
              icon: const Icon(Icons.receipt_long),
              onPressed: _showImageSourceDialog,
              tooltip: 'Scan Receipt',
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_receiptImage != null) ...[
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _receiptImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => setState(() => _receiptImage = null),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black54,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
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
                  enabled: !_isSubmitting,
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
                  enabled: !_isSubmitting,
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
                AbsorbPointer(
                  absorbing: _isSubmitting,
                  child: Wrap(
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
                AbsorbPointer(
                  absorbing: _isSubmitting,
                  child: InkWell(
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
                ),
                const SizedBox(height: 40),
                
                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
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
      ),
    );
  }
}