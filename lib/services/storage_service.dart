import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_profile.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/income.dart';

/// StorageService handles all local data persistence for the FinTrak app.
/// All data is stored locally on the device using Hive.
/// No data is transmitted to any external servers.
class StorageService {
  static const String userProfileBoxName = 'user_profile';
  static const String expensesBoxName = 'expenses';
  static const String incomesBoxName = 'incomes';
  
  late Box<UserProfile> _userProfileBox;
  late Box<Expense> _expensesBox;
  late Box<Income> _incomesBox;
  
  // Initialize Hive and open boxes
  Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(UserProfileAdapter());
    Hive.registerAdapter(ExpenseAdapter());
    Hive.registerAdapter(IncomeAdapter());
    Hive.registerAdapter(ExpenseCategoryAdapter());
    Hive.registerAdapter(IncomeSourceAdapter());
    
    // Open boxes
    _userProfileBox = await Hive.openBox<UserProfile>(userProfileBoxName);
    _expensesBox = await Hive.openBox<Expense>(expensesBoxName);
    _incomesBox = await Hive.openBox<Income>(incomesBoxName);
  }

  // Save user profile
  Future<bool> saveUserProfile(UserProfile profile) async {
    try {
      await _userProfileBox.put('profile', profile);
      return true;
    } catch (e) {
      print('Error saving user profile: $e');
      return false;
    }
  }

  // Load user profile
  Future<UserProfile?> loadUserProfile() async {
    try {
      return _userProfileBox.get('profile');
    } catch (e) {
      print('Error loading user profile: $e');
      return null;
    }
  }

  // Save expenses
  Future<bool> saveExpenses(List<Expense> expenses) async {
    try {
      await _expensesBox.clear();
      await _expensesBox.addAll(expenses);
      return true;
    } catch (e) {
      print('Error saving expenses: $e');
      return false;
    }
  }

  // Load expenses
  Future<List<Expense>> loadExpenses() async {
    try {
      return _expensesBox.values.toList();
    } catch (e) {
      print('Error loading expenses: $e');
      return [];
    }
  }

  // Save incomes
  Future<bool> saveIncomes(List<Income> incomes) async {
    try {
      await _incomesBox.clear();
      await _incomesBox.addAll(incomes);
      return true;
    } catch (e) {
      print('Error saving incomes: $e');
      return false;
    }
  }

  // Load incomes
  Future<List<Income>> loadIncomes() async {
    try {
      return _incomesBox.values.toList();
    } catch (e) {
      print('Error loading incomes: $e');
      return [];
    }
  }

  // Add a new expense
  Future<bool> addExpense(Expense expense) async {
    try {
      await _expensesBox.add(expense);
      return true;
    } catch (e) {
      print('Error adding expense: $e');
      return false;
    }
  }
  
  // Delete an expense by ID
  Future<bool> deleteExpense(String id) async {
    try {
      final index = _expensesBox.values.toList().indexWhere((expense) => expense.id == id);
      if (index != -1) {
        await _expensesBox.deleteAt(index);
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting expense: $e');
      return false;
    }
  }

  // Add a new income
  Future<bool> addIncome(Income income) async {
    try {
      await _incomesBox.add(income);
      return true;
    } catch (e) {
      print('Error adding income: $e');
      return false;
    }
  }
  
  // Delete an income by ID
  Future<bool> deleteIncome(String id) async {
    try {
      final index = _incomesBox.values.toList().indexWhere((income) => income.id == id);
      if (index != -1) {
        await _incomesBox.deleteAt(index);
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting income: $e');
      return false;
    }
  }

  // Clear all data (for reset)
  Future<bool> clearAllData() async {
    try {
      await _userProfileBox.clear();
      await _expensesBox.clear();
      await _incomesBox.clear();
      return true;
    } catch (e) {
      print('Error clearing data: $e');
      return false;
    }
  }
} 