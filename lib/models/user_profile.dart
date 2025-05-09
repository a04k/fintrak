import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 0)
class UserProfile {
  @HiveField(0)
  final String name;
  
  @HiveField(1)
  final double monthlyIncome;
  
  @HiveField(2)
  final String currency; // e.g., "EGP", "USD", "EUR"
  
  @HiveField(3)
  final DateTime recurringIncomeDate;  // New field for monthly income date
  
  @HiveField(4)
  final double monthlyBudget;  // New field for budget
  
  @HiveField(5)
  final String? savingGoal;  // New field for saving goal

  UserProfile({
    required this.name,
    required this.monthlyIncome,
    required this.currency,
    required this.recurringIncomeDate,
    required this.monthlyBudget,
    this.savingGoal,
  });

  // Creating a default constructor with default values
  factory UserProfile.defaultProfile({
    required String name,
    required double monthlyIncome,
    String currency = "EGP",
    DateTime? recurringIncomeDate,
    double? monthlyBudget,
    String? savingGoal,
  }) {
    return UserProfile(
      name: name,
      monthlyIncome: monthlyIncome,
      currency: currency,
      recurringIncomeDate: recurringIncomeDate ?? DateTime.now(),
      monthlyBudget: monthlyBudget ?? (monthlyIncome * 0.8), // Default budget is 80% of income
      savingGoal: savingGoal,
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'name': name,
    'monthlyIncome': monthlyIncome,
    'currency': currency,
    'recurringIncomeDate': recurringIncomeDate.toIso8601String(),
    'monthlyBudget': monthlyBudget,
    'savingGoal': savingGoal,
  };

  // Create from JSON for retrieval
  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] as String,
    monthlyIncome: (json['monthlyIncome'] as num).toDouble(),
    currency: json['currency'] as String,
    recurringIncomeDate: json['recurringIncomeDate'] != null 
      ? DateTime.parse(json['recurringIncomeDate']) 
      : DateTime.now(),
    monthlyBudget: json['monthlyBudget'] != null 
      ? (json['monthlyBudget'] as num).toDouble() 
      : ((json['monthlyIncome'] as num).toDouble() * 0.8),
    savingGoal: json['savingGoal'] as String?,
  );
} 