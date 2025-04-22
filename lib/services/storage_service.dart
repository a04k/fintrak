import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/income.dart';

/// StorageService handles all local data persistence for the FinTrak app.
/// All data is stored locally on the device using SharedPreferences.
/// No data is transmitted to any external servers.
class StorageService {
  // Keys for SharedPreferences
  static const String _userProfileKey = 'user_profile';
  static const String _expensesKey = 'expenses';
  static const String _incomesKey = 'incomes'; // New key for incomes

  // Save user profile
  Future<bool> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_userProfileKey, jsonEncode(profile.toJson()));
  }

  // Load user profile
  Future<UserProfile?> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileString = prefs.getString(_userProfileKey);
    
    if (profileString == null) {
      return null;
    }
    
    try {
      final Map<String, dynamic> profileData = jsonDecode(profileString);
      return UserProfile.fromJson(profileData);
    } catch (e) {
      print('Error loading user profile: $e');
      return null;
    }
  }

  // Save expenses
  Future<bool> saveExpenses(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Convert Expense list to JSON
    final List<Map<String, dynamic>> expensesData = expenses.map((expense) => {
      'id': expense.id,
      'description': expense.description,
      'amount': expense.amount,
      'category': expense.category.index, // Store enum index
      'date': expense.date.toIso8601String(),
    }).toList();
    
    return await prefs.setString(_expensesKey, jsonEncode(expensesData));
  }

  // Load expenses
  Future<List<Expense>> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final expensesString = prefs.getString(_expensesKey);
    
    if (expensesString == null || expensesString.isEmpty) {
      return [];
    }
    
    try {
      final List<dynamic> expensesData = jsonDecode(expensesString);
      return expensesData.map((data) {
        return Expense(
          id: data['id'],
          description: data['description'],
          amount: data['amount'],
          category: ExpenseCategory.values[data['category']], // Convert index back to enum
          date: DateTime.parse(data['date']),
        );
      }).toList();
    } catch (e) {
      print('Error loading expenses: $e');
      return [];
    }
  }

  // Save incomes
  Future<bool> saveIncomes(List<Income> incomes) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Convert Income list to JSON
    final List<Map<String, dynamic>> incomesData = 
        incomes.map((income) => income.toJson()).toList();
    
    return await prefs.setString(_incomesKey, jsonEncode(incomesData));
  }

  // Load incomes
  Future<List<Income>> loadIncomes() async {
    final prefs = await SharedPreferences.getInstance();
    final incomesString = prefs.getString(_incomesKey);
    
    if (incomesString == null || incomesString.isEmpty) {
      return [];
    }
    
    try {
      final List<dynamic> incomesData = jsonDecode(incomesString);
      return incomesData.map((data) => Income.fromJson(data as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error loading incomes: $e');
      return [];
    }
  }

  // Add a new expense and save
  Future<bool> addExpense(Expense expense) async {
    final expenses = await loadExpenses();
    expenses.add(expense);
    return saveExpenses(expenses);
  }
  
  // Delete an expense by ID
  Future<bool> deleteExpense(String id) async {
    final expenses = await loadExpenses();
    expenses.removeWhere((expense) => expense.id == id);
    return saveExpenses(expenses);
  }

  // Add a new income and save
  Future<bool> addIncome(Income income) async {
    final incomes = await loadIncomes();
    incomes.add(income);
    return saveIncomes(incomes);
  }
  
  // Delete an income by ID
  Future<bool> deleteIncome(String id) async {
    final incomes = await loadIncomes();
    incomes.removeWhere((income) => income.id == id);
    return saveIncomes(incomes);
  }

  // Clear all data (for reset)
  Future<bool> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userProfileKey);
    await prefs.remove(_expensesKey);
    await prefs.remove(_incomesKey);
    return true;
  }
} 