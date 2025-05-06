import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'income.g.dart';

@HiveType(typeId: 2)
class Income {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String source;
  
  @HiveField(2)
  final double amount;
  
  @HiveField(3)
  final DateTime date;
  
  @HiveField(4)
  final String? notes;

  const Income({
    required this.id,
    required this.source,
    required this.amount,
    required this.date,
    this.notes,
  });

  // Helper factory for creating income with auto-generated ID and current date
  factory Income.create({
    required String source,
    required double amount,
    DateTime? date,
    String? notes,
  }) {
    return Income(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Simple unique ID
      source: source.trim(),
      amount: amount,
      date: date ?? DateTime.now(),
      notes: notes,
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'source': source,
    'amount': amount,
    'date': date.toIso8601String(),
    'notes': notes,
  };

  // Create from JSON for retrieval
  factory Income.fromJson(Map<String, dynamic> json) => Income(
    id: json['id'] as String,
    source: json['source'] as String,
    amount: (json['amount'] as num).toDouble(),
    date: DateTime.parse(json['date'] as String),
    notes: json['notes'] as String?,
  );
}

@HiveType(typeId: 3)
enum IncomeSource {
  @HiveField(0)
  salary,
  
  @HiveField(1)
  freelance,
  
  @HiveField(2)
  investment,
  
  @HiveField(3)
  gift,
  
  @HiveField(4)
  other,
}

// Helper extension to get display names and icons
extension IncomeSourceDetails on IncomeSource {
  String get displayName {
    switch (this) {
      case IncomeSource.salary:
        return 'Salary';
      case IncomeSource.freelance:
        return 'Freelance';
      case IncomeSource.investment:
        return 'Investment';
      case IncomeSource.gift:
        return 'Gift';
      case IncomeSource.other:
      default:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case IncomeSource.salary:
        return Icons.work_outline;
      case IncomeSource.freelance:
        return Icons.computer_outlined;
      case IncomeSource.investment:
        return Icons.show_chart;
      case IncomeSource.gift:
        return Icons.card_giftcard_outlined;
      case IncomeSource.other:
      default:
        return Icons.payments_outlined;
    }
  }

  Color get color {
    switch (this) {
      case IncomeSource.salary:
        return Colors.blue;
      case IncomeSource.freelance:
        return Colors.purple;
      case IncomeSource.investment:
        return Colors.amber;
      case IncomeSource.gift:
        return Colors.pink;
      case IncomeSource.other:
      default:
        return Colors.teal;
    }
  }
} 