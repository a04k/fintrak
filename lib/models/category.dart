import 'package:flutter/material.dart'; // For potential Color/Icon association

// Define the expense categories
enum ExpenseCategory {
  entertainment,
  clothing,
  bills,
  groceries,
  health,
  other // A default/fallback category
}

// Helper extension to get display names, colors, or icons
extension ExpenseCategoryDetails on ExpenseCategory {
  String get displayName {
    switch (this) {
      case ExpenseCategory.entertainment:
        return 'Entertainment';
      case ExpenseCategory.clothing:
        return 'Clothing';
      case ExpenseCategory.bills:
        return 'Bills';
      case ExpenseCategory.groceries:
        return 'Groceries';
      case ExpenseCategory.health:
        return 'Health/Emergency';
      case ExpenseCategory.other:
      default:
        return 'Other';
    }
  }

  // Define colors for the progress bar segments and list items
  Color get color {
    switch (this) {
      case ExpenseCategory.entertainment:
        return Colors.orange.shade600; // Example color
      case ExpenseCategory.clothing:
        return Colors.purple.shade400; // Example color
      case ExpenseCategory.bills:
        return Colors.red.shade400; // Example color
      case ExpenseCategory.groceries:
        return Colors.green.shade500; // Example color
      case ExpenseCategory.health:
        return Colors.blue.shade500; // Example color
      case ExpenseCategory.other:
      default:
        return Colors.grey.shade600; // Default color
    }
  }

  // Define icons for list view items
  IconData get icon {
     switch (this) {
      case ExpenseCategory.entertainment:
        return Icons.movie_filter_outlined; // Using outlined icons for consistency
      case ExpenseCategory.clothing:
        return Icons.checkroom_outlined;
      case ExpenseCategory.bills:
        return Icons.receipt_long_outlined;
      case ExpenseCategory.groceries:
        return Icons.local_grocery_store_outlined;
      case ExpenseCategory.health:
        return Icons.healing_outlined;
      case ExpenseCategory.other:
      default:
        return Icons.attach_money_outlined;
    }
  }
} 