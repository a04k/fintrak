import 'package:flutter/material.dart'; // For potential Color/Icon association
import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 4)
enum ExpenseCategory {
  @HiveField(0)
  food,
  
  @HiveField(1)
  transportation,
  
  @HiveField(2)
  utilities,
  
  @HiveField(3)
  entertainment,
  
  @HiveField(4)
  shopping,
  
  @HiveField(5)
  health,
  
  @HiveField(6)
  education,
  
  @HiveField(7)
  other
}

// Helper extension to get display names, colors, or icons
extension ExpenseCategoryDetails on ExpenseCategory {
  String get displayName {
    switch (this) {
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
      default:
        return 'Other';
    }
  }

  // Define colors for the progress bar segments and list items
  Color get color {
    switch (this) {
      case ExpenseCategory.entertainment:
        return Colors.orange.shade600; // Example color
      case ExpenseCategory.food:
        return Colors.purple.shade400; // Example color
      case ExpenseCategory.transportation:
        return Colors.red.shade400; // Example color
      case ExpenseCategory.utilities:
        return Colors.green.shade500; // Example color
      case ExpenseCategory.shopping:
        return Colors.blue.shade500; // Example color
      case ExpenseCategory.health:
        return Colors.pink.shade500; // Example color
      case ExpenseCategory.education:
        return Colors.teal.shade500; // Example color
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
      case ExpenseCategory.food:
        return Icons.fastfood_outlined;
      case ExpenseCategory.transportation:
        return Icons.directions_car_outlined;
      case ExpenseCategory.utilities:
        return Icons.electric_bolt_outlined;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag_outlined;
      case ExpenseCategory.health:
        return Icons.healing_outlined;
      case ExpenseCategory.education:
        return Icons.school_outlined;
      case ExpenseCategory.other:
      default:
        return Icons.attach_money_outlined;
    }
  }
} 