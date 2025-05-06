import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../models/category.dart';
import '../screens/transaction_details_screen.dart';

class TransactionListItem extends StatelessWidget {
  final dynamic transaction; // Can be either Expense or Income
  final bool isDarkMode;
  final Function() onDelete;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.isDarkMode,
    required this.onDelete,
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

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction is Expense;
    final amount = isExpense ? transaction.amount : transaction.amount;
    final date = isExpense ? transaction.date : transaction.date;
    final description = isExpense ? transaction.description : transaction.source;
    final category = _getCategoryName(transaction);

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
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
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'CANCEL',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'DELETE',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) => onDelete(),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: (isExpense ? Colors.red : Colors.green).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isExpense ? Icons.trending_down : Icons.trending_up,
              color: isExpense ? Colors.red : Colors.green,
              size: 16,
            ),
          ),
          title: Text(
            description,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('MMM dd').format(date),
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                category,
                style: TextStyle(
                  fontSize: 11,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          trailing: Text(
            '${isExpense ? '-' : '+'}£${NumberFormat.decimalPattern().format(amount)}',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: isExpense ? Colors.red : Colors.green,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransactionDetailsScreen(
                  transaction: transaction,
                  onEdit: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
} 