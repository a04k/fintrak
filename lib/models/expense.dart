import 'package:hive/hive.dart';
import 'category.dart'; // Import the category enum

part 'expense.g.dart';

@HiveType(typeId: 1)
class Expense {
  @HiveField(0)
  final String id; // Unique ID for each expense
  
  @HiveField(1)
  final String description;
  
  @HiveField(2)
  final double amount;
  
  @HiveField(3)
  final ExpenseCategory category;
  
  @HiveField(4)
  final DateTime date;
  // You might add optional fields like notes, receipt image path etc.

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
  });

  // Helper factory for creating expense with auto-generated ID and current date
  factory Expense.create({
    required String description,
    required double amount,
    required ExpenseCategory category,
    DateTime? date, // Allow overriding date if needed
  }) {
    return Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Simple unique ID
      description: description.trim(), // Trim whitespace
      amount: amount,
      category: category,
      date: date ?? DateTime.now(),
    );
  }

  // You might add methods here later, e.g., toJson, fromJson for persistence
  // Map<String, dynamic> toJson() => {
  //   'id': id,
  //   'description': description,
  //   'amount': amount,
  //   'category': category.name, // Store enum name as string
  //   'date': date.toIso8601String(), // Store date as ISO string
  // };

  // factory Expense.fromJson(Map<String, dynamic> json) => Expense(
  //   id: json['id'] as String,
  //   description: json['description'] as String,
  //   amount: (json['amount'] as num).toDouble(),
  //   category: ExpenseCategory.values.byName(json['category'] as String),
  //   date: DateTime.parse(json['date'] as String),
  // );
} 