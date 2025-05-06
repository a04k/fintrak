import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../models/category.dart';
import '../services/expense_provider.dart';
import 'add_expense_screen.dart';
import 'add_income_screen.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final dynamic transaction; // Can be either Expense or Income
  final Function() onEdit;

  const TransactionDetailsScreen({
    super.key,
    required this.transaction,
    required this.onEdit,
  });

  String _getCategoryName(dynamic transaction) {
    if (transaction is Expense) {
      final category = transaction.category;
      if (category is ExpenseCategory) {
        switch (category) {
          case ExpenseCategory.entertainment:
            return 'Entertainment';
          case ExpenseCategory.food:
            return 'Food';
          case ExpenseCategory.transportation:
            return 'Transportation';
          case ExpenseCategory.utilities:
            return 'Utilities';
          case ExpenseCategory.shopping:
            return 'Shopping';
          case ExpenseCategory.health:
            return 'Health/Emergency';
          case ExpenseCategory.education:
            return 'Education';
          case ExpenseCategory.other:
            return 'Other';
        }
      }
    }
    return 'Income';
  }

  void _handleEdit(BuildContext context) {
    if (transaction is Expense) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddExpenseScreen(
            expense: transaction as Expense,
            isEditing: true,
          ),
        ),
      );
    } else if (transaction is Income) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddIncomeScreen(
            income: transaction as Income,
            isEditing: true,
          ),
        ),
      );
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isExpense = transaction is Expense;
    final amount = isExpense ? transaction.amount : transaction.amount;
    final description = isExpense ? transaction.description : transaction.source;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        title: Text(
          'Delete ${isExpense ? 'Expense' : 'Income'}?',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this ${isExpense ? 'expense' : 'income'}?\n\n$description\n£${NumberFormat.decimalPattern().format(amount)}',
          style: TextStyle(
            color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'CANCEL',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'DELETE',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      bool success;
      
      if (isExpense) {
        success = await provider.deleteExpense(transaction.id);
      } else {
        success = await provider.deleteIncome(transaction.id);
      }

      if (success && context.mounted) {
        Navigator.pop(context); // Close the details screen
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to delete ${isExpense ? 'expense' : 'income'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    final isExpense = transaction is Expense;
    final amount = isExpense ? transaction.amount : transaction.amount;
    final date = isExpense ? transaction.date : transaction.date;
    final description = isExpense ? transaction.description : transaction.source;
    final category = _getCategoryName(transaction);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          isExpense ? 'Expense Details' : 'Income Details',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _handleEdit(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Amount',
                                style: TextStyle(
                                  color: subtitleColor,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${isExpense ? '-' : '+'}£${NumberFormat.decimalPattern().format(amount)}',
                                style: TextStyle(
                                  color: isExpense ? Colors.red : Colors.green,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'Description',
                              style: TextStyle(color: subtitleColor),
                            ),
                            subtitle: Text(
                              description,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'Category',
                              style: TextStyle(color: subtitleColor),
                            ),
                            subtitle: Text(
                              category,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'Date',
                              style: TextStyle(color: subtitleColor),
                            ),
                            subtitle: Text(
                              DateFormat('MMMM d, y').format(date),
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleDelete(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Delete Transaction',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}