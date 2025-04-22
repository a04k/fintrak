import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/income.dart';
import 'storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ExpenseProvider with ChangeNotifier {
  // Internal state
  UserProfile? _userProfile;
  List<Expense> _expenses = [];
  List<Income> _incomes = [];
  final StorageService _storageService = StorageService();
  bool _isLoading = true;
  String? _error;
  String _userName = '';
  final SharedPreferences _prefs;
  // Add flag to prevent notifications during initialization
  bool _initializing = false;

  ExpenseProvider(this._prefs) {
    _loadData();
  }

  // Getters for accessing state
  UserProfile? get userProfile => _userProfile;
  List<Expense> get expenses => [..._expenses]; // Return a copy to avoid direct modification
  List<Income> get incomes => [..._incomes]; // Return a copy to avoid direct modification
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isProfileSet => _userName.isNotEmpty;
  
  // Derived data
  double get monthlyIncome => _userProfile?.monthlyIncome ?? 0.0;
  String get currencyCode => _userProfile?.currency ?? 'USD';
  DateTime get recurringIncomeDate => _userProfile?.recurringIncomeDate ?? DateTime.now();
  String get recurringIncomeDateFormatted => 
      DateFormat('MMMM d').format(_userProfile?.recurringIncomeDate ?? DateTime.now());
  double get monthlyBudget => _userProfile?.monthlyBudget ?? 0.0;
  
  // Calculate total additional income (non-monthly income)
  double get additionalIncome => 
      _incomes.fold(0.0, (sum, income) => sum + income.amount);
  
  // Calculate total spending
  double get totalSpending => 
      _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  
  // Calculate spending by category
  Map<ExpenseCategory, double> get spendingByCategory {
    Map<ExpenseCategory, double> result = {};
    
    for (var expense in _expenses) {
      result.update(
        expense.category, 
        (existingAmount) => existingAmount + expense.amount,
        ifAbsent: () => expense.amount
      );
    }
    
    // Ensure all categories exist in the map
    for (var category in ExpenseCategory.values) {
      result.putIfAbsent(category, () => 0.0);
    }
    
    return result;
  }
  
  // Calculate remaining budget (including additional income)
  double get remainingBudget => 
      monthlyBudget - totalSpending + additionalIncome;

  // --- Methods to modify state ---

  // Initialize - load data from storage
  Future<void> initialize() async {
    _initializing = true; // Set flag before loading data
    await _loadData();
    _initializing = false; // Reset flag after loading
    notifyListeners(); // Notify once after initialization complete
  }
  
  Future<void> _loadData() async {
    _setLoading(true);
    try {
      _userName = _prefs.getString('user_name') ?? '';
      
      // Load user profile
      _userProfile = await _storageService.loadUserProfile();
      
      // Load expenses
      _expenses = await _storageService.loadExpenses();
      
      // Load incomes
      _incomes = await _storageService.loadIncomes();
      
      _error = null;
    } catch (e) {
      _error = 'Error loading data: $e';
      print(_error);
    } finally {
      _setLoading(false);
    }
  }

  // Save user profile
  Future<bool> saveUserProfile(UserProfile profile) async {
    _setLoading(true);
    try {
      final success = await _storageService.saveUserProfile(profile);
      if (success) {
        _userProfile = profile;
        _error = null;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Failed to save user profile: $e';
      print(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Add a new expense
  Future<bool> addExpense(Expense expense) async {
    _setLoading(true);
    try {
      final success = await _storageService.addExpense(expense);
      if (success) {
        _expenses.add(expense);
        _error = null;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Failed to add expense: $e';
      print(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Add a new income
  Future<bool> addIncome(Income income) async {
    _setLoading(true);
    try {
      final success = await _storageService.addIncome(income);
      if (success) {
        _incomes.add(income);
        _error = null;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Failed to add income: $e';
      print(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Delete an expense
  Future<bool> deleteExpense(String id) async {
    _setLoading(true);
    try {
      final success = await _storageService.deleteExpense(id);
      if (success) {
        _expenses.removeWhere((expense) => expense.id == id);
        _error = null;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Failed to delete expense: $e';
      print(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Delete an income
  Future<bool> deleteIncome(String id) async {
    _setLoading(true);
    try {
      final success = await _storageService.deleteIncome(id);
      if (success) {
        _incomes.removeWhere((income) => income.id == id);
        _error = null;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Failed to delete income: $e';
      print(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Update budget with income validation
  Future<bool> updateBudget(double newBudget) async {
    if (_userProfile == null) return false;
    
    // Add validation to prevent budget from exceeding income
    if (newBudget > _userProfile!.monthlyIncome) {
      _error = 'Budget cannot exceed monthly income';
      notifyListeners();
      return false;
    }
    
    final updatedProfile = UserProfile(
      name: _userProfile!.name,
      monthlyIncome: _userProfile!.monthlyIncome,
      currency: _userProfile!.currency,
      recurringIncomeDate: _userProfile!.recurringIncomeDate,
      monthlyBudget: newBudget,
      savingGoal: _userProfile!.savingGoal,
    );
    
    return saveUserProfile(updatedProfile);
  }
  
  // Update monthly income and date
  Future<bool> updateMonthlyIncome(double amount, DateTime date) async {
    if (_userProfile == null) return false;
    
    final updatedProfile = UserProfile(
      name: _userProfile!.name,
      monthlyIncome: amount,
      currency: _userProfile!.currency,
      recurringIncomeDate: date,
      monthlyBudget: _userProfile!.monthlyBudget,
      savingGoal: _userProfile!.savingGoal,
    );
    
    return saveUserProfile(updatedProfile);
  }
  
  // Update currency
  Future<bool> updateCurrency(String currencyCode) async {
    if (_userProfile == null) return false;
    
    final updatedProfile = UserProfile(
      name: _userProfile!.name,
      monthlyIncome: _userProfile!.monthlyIncome,
      currency: currencyCode,
      recurringIncomeDate: _userProfile!.recurringIncomeDate,
      monthlyBudget: _userProfile!.monthlyBudget,
      savingGoal: _userProfile!.savingGoal,
    );
    
    return saveUserProfile(updatedProfile);
  }
  
  // Reset all app data
  Future<bool> resetAppData() async {
    _setLoading(true);
    try {
      final success = await _storageService.clearAllData();
      if (success) {
        _userProfile = null;
        _expenses = [];
        _incomes = [];
        _userName = '';
        _prefs.remove('user_name');
        _error = null;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Failed to reset app data: $e';
      print(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Helper method to update loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    // Only notify if not initializing
    if (!_initializing) {
      notifyListeners();
    }
  }

  void setUserName(String name) {
    print("ExpenseProvider: Setting user name to: $name");
    _userName = name;
    _prefs.setString('user_name', name);
    print("ExpenseProvider: User name set, notifying listeners");
    notifyListeners();
  }
} 