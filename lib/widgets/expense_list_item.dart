import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date and currency formatting
import '../models/expense.dart';
import '../models/category.dart'; // For category details (icon, color)

class ExpenseListItem extends StatelessWidget {
  final Expense expense;

  const ExpenseListItem({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    // Formatters
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'en_US'); // Adapt locale later
    final dateFormat = DateFormat('yyyy-MM-dd'); // Format like the image

    return ListTile(
      // contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      leading: CircleAvatar(
        backgroundColor: expense.category.color.withOpacity(0.15), // Light background for icon
        child: Icon(
          expense.category.icon,
          color: expense.category.color, // Use category color for icon
        ),
      ),
      title: Text(
        expense.description,
        style: const TextStyle(fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(dateFormat.format(expense.date)),
      trailing: Text(
        currencyFormat.format(expense.amount),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.red.shade700, // Use a distinct color for expense amount
          fontSize: 15,
        ),
      ),
      onTap: () {
        // TODO: Implement navigation to an Expense Detail screen (optional)
        print('Tapped on expense: ${expense.description}');
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Detail view for ${expense.description} TBD')),
        );
      },
    );
  }
} 