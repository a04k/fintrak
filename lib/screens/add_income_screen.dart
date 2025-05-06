import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/income.dart';
import '../services/expense_provider.dart';

class AddIncomeScreen extends StatefulWidget {
  final Income? income;
  final bool isEditing;

  const AddIncomeScreen({
    super.key,
    this.income,
    this.isEditing = false,
  });

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sourceController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;
  
  DateTime _selectedDate = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    if (widget.income != null) {
      _sourceController.text = widget.income!.source;
      _amountController.text = widget.income!.amount.toString();
      _notesController.text = widget.income!.notes ?? '';
      _selectedDate = widget.income!.date;
    }
  }
  
  @override
  void dispose() {
    _sourceController.dispose();
    _amountController.dispose();
    _notesController.dispose();
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
  
  // Submit the form
  void _submitForm() async {
    if (_isSubmitting) return; // Prevent double submission
    
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      
      try {
        final income = Income(
          id: widget.income?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          source: _sourceController.text.trim(),
          amount: double.parse(_amountController.text.trim()),
          date: _selectedDate,
          notes: _notesController.text.trim(),
        );
        
        final provider = Provider.of<ExpenseProvider>(context, listen: false);
        bool success;
        
        if (widget.isEditing) {
          success = await provider.updateIncome(income);
        } else {
          success = await provider.addIncome(income);
        }
        
        if (success && mounted) {
          Navigator.pop(context);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error ?? 'Failed to save income'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
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
    final backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];
    
    // Get currency code from provider without listening to changes
    final currencyCode = Provider.of<ExpenseProvider>(context, listen: false).currencyCode;
    final currencySymbol = '£';
    
    return WillPopScope(
      onWillPop: () async => !_isSubmitting,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: Text(
            widget.isEditing ? 'Edit Income' : 'Add Income',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
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
                  enabled: !_isSubmitting,
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
                  enabled: !_isSubmitting,
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
      ),
    );
  }
} 