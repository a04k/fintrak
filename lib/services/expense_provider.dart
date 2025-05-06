import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/income.dart';
import 'storage_service.dart';
import 'package:intl/intl.dart';

class ExpenseProvider with ChangeNotifier {
  // Internal state
  UserProfile? _userProfile;
  List<Expense> _expenses = [];
  List<Income> _incomes = [];
  final StorageService _storageService;
  bool _isLoading = true;
  String? _error;
  String _userName = '';
  int _loadingOperations = 0;
  bool _isInitialized = false;

  ExpenseProvider(this._storageService);

  // Getters for accessing state
  UserProfile? get userProfile => _userProfile;
  List<Expense> get expenses => [..._expenses];
  List<Income> get incomes => [..._incomes];
  bool get isLoading => _loadingOperations > 0;
  String? get error => _error;
  bool get isProfileSet => _userName.isNotEmpty;
  bool get isInitialized => _isInitialized;
  
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

  // Get spending by category for a specific time period
  Map<ExpenseCategory, double> getSpendingByCategory({DateTime? startDate, DateTime? endDate}) {
    final Map<ExpenseCategory, double> categorySpending = {};
    
    for (var expense in _expenses) {
      if ((startDate == null || expense.date.isAfter(startDate)) &&
          (endDate == null || expense.date.isBefore(endDate.add(const Duration(days: 1))))) {
        categorySpending[expense.category] = (categorySpending[expense.category] ?? 0) + expense.amount;
      }
    }
    
    return categorySpending;
  }

  // Get total spending for a specific time period
  double getTotalSpending({DateTime? startDate, DateTime? endDate}) {
    return _expenses
        .where((expense) =>
            (startDate == null || expense.date.isAfter(startDate)) &&
            (endDate == null || expense.date.isBefore(endDate.add(const Duration(days: 1)))))
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  // Get total income for a specific time period
  double getTotalIncome({DateTime? startDate, DateTime? endDate}) {
    return _incomes
        .where((income) =>
            (startDate == null || income.date.isAfter(startDate)) &&
            (endDate == null || income.date.isBefore(endDate.add(const Duration(days: 1)))))
        .fold(0, (sum, income) => sum + income.amount);
  }

  // Get daily average spending for a specific time period
  double getDailyAverageSpending({DateTime? startDate, DateTime? endDate}) {
    if (_expenses.isEmpty) return 0;

    startDate ??= _expenses.map((e) => e.date).reduce((a, b) => a.isBefore(b) ? a : b);
    endDate ??= DateTime.now();

    final totalSpending = getTotalSpending(startDate: startDate, endDate: endDate);
    final days = endDate.difference(startDate).inDays + 1;
    
    return totalSpending / days;
  }

  // Get monthly spending history
  List<Map<String, dynamic>> getMonthlySpendingHistory({int numberOfMonths = 12}) {
    final List<Map<String, dynamic>> history = [];
    final now = DateTime.now();
    
    for (int i = 0; i < numberOfMonths; i++) {
      final startDate = DateTime(now.year, now.month - i, 1);
      final endDate = DateTime(now.year, now.month - i + 1, 0);
      
      history.add({
        'month': DateFormat('MMMM yyyy').format(startDate),
        'spending': getTotalSpending(startDate: startDate, endDate: endDate),
        'income': getTotalIncome(startDate: startDate, endDate: endDate),
        'categories': getSpendingByCategory(startDate: startDate, endDate: endDate),
      });
    }
    
    return history;
  }

  // --- Methods to modify state ---

  // Initialize - load data from storage
  Future<void> initialize() async {
    if (_isInitialized) return;
    await _loadData();
    _isInitialized = true;
    notifyListeners();
  }
  
  Future<void> _loadData() async {
    _setLoading(true);
    try {
      // Load user profile
      _userProfile = await _storageService.loadUserProfile();
      _userName = _userProfile?.name ?? '';
      
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
        _userName = profile.name;
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
        _incomes = [..._incomes, income];
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
  
  // Update an expense
  Future<bool> updateExpense(Expense updatedExpense) async {
    _setLoading(true);
    try {
      final index = _expenses.indexWhere((e) => e.id == updatedExpense.id);
      if (index != -1) {
        // Save all expenses with the updated one
        _expenses[index] = updatedExpense;
        final success = await _storageService.saveExpenses(_expenses);
        if (success) {
          _error = null;
          notifyListeners();
        }
        return success;
      }
      return false;
    } catch (e) {
      _error = 'Failed to update expense: $e';
      print(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Update an income
  Future<bool> updateIncome(Income updatedIncome) async {
    _setLoading(true);
    try {
      final index = _incomes.indexWhere((i) => i.id == updatedIncome.id);
      if (index != -1) {
        // Save all incomes with the updated one
        _incomes[index] = updatedIncome;
        final success = await _storageService.saveIncomes(_incomes);
        if (success) {
          _error = null;
          notifyListeners();
        }
        return success;
      }
      return false;
    } catch (e) {
      _error = 'Failed to update income: $e';
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
  
  void _setLoading(bool loading) {
    if (loading) {
      _loadingOperations++;
    } else {
      _loadingOperations--;
    }
    if (_loadingOperations < 0) _loadingOperations = 0;
    notifyListeners();
  }

  void setUserName(String name) {
    print("ExpenseProvider: Setting user name to: $name");
    _userName = name;
    print("ExpenseProvider: User name set, notifying listeners");
    notifyListeners();
  }
} 