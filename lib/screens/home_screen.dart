import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter/services.dart';
// Import models and widgets we will create/use
import '../models/expense.dart';
import '../models/category.dart';
import '../models/income.dart'; // Add import for Income model
import '../widgets/budget_progress_bar.dart'; 
import '../widgets/expense_list_item.dart'; 
import '../services/expense_provider.dart';
import 'add_expense_screen.dart';
import 'chat_screen.dart';
import '../widgets/balance_summary_card.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/transaction_filter_buttons.dart';
import 'add_income_screen.dart'; // Import the new screen

class HomeScreen extends StatefulWidget {
  // Optional: Pass UserProfile if needed, or use state management later
  // final UserProfile userProfile;
  // const HomeScreen({super.key, required this.userProfile});
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TransactionFilterType _currentFilter = TransactionFilterType.all;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];
    
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        // Get user data from provider
        final userName = expenseProvider.userProfile?.name ?? "User";
        final expenses = expenseProvider.expenses;
        final monthlyIncome = expenseProvider.monthlyIncome;
        final totalSpending = expenseProvider.totalSpending;
        final spendingByCategory = expenseProvider.spendingByCategory;
        final currencyCode = expenseProvider.currencyCode;
        
        // Budget management
        final budgetGoal = expenseProvider.monthlyBudget; // Use monthly budget directly
        
        final budgetPercentage = budgetGoal > 0 ? totalSpending / budgetGoal : 0.0;
        final budgetRemaining = budgetGoal - totalSpending;
        
        // Calculate total balance
        final totalBalance = monthlyIncome - totalSpending;
        
        // Filter expenses based on current filter
        final List<Expense> filteredExpenses;
        final List<Income> filteredIncomes;
        
        switch (_currentFilter) {
          case TransactionFilterType.income:
            filteredExpenses = [];
            filteredIncomes = List.from(expenseProvider.incomes);
            // Sort by date (most recent first)
            filteredIncomes.sort((a, b) => b.date.compareTo(a.date));
            break;
          case TransactionFilterType.expense:
            filteredExpenses = List.from(expenses);
            filteredIncomes = [];
            break;
          case TransactionFilterType.all:
          default:
            filteredExpenses = List.from(expenses);
            filteredIncomes = List.from(expenseProvider.incomes);
            break;
        }
        
        // Sort expenses by date (most recent first)
        filteredExpenses.sort((a, b) => b.date.compareTo(a.date));
        
        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: Text(
              'Home',
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 32,
                color: textColor,
              ),
            ),
            backgroundColor: backgroundColor,
            elevation: 0,
            toolbarHeight: 100,
            centerTitle: false,
            titleSpacing: 24,
            actions: [
              // Set Budget Button
              IconButton(
                icon: Icon(
                  Icons.calculate_outlined,
                  color: textColor,
                  size: 26,
                ),
                onPressed: () {
                  _showBudgetDialog(context, expenseProvider);
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: expenseProvider.isLoading 
            ? Center(
                child: CircularProgressIndicator(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              )
            : RefreshIndicator(
                onRefresh: () => expenseProvider.initialize(),
                color: isDarkMode ? Colors.white : Colors.black,
                backgroundColor: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Balance Summary Card
                      SizedBox(
                        width: double.infinity,
                        child: BalanceSummaryCard(
                          totalBalance: expenseProvider.remainingBudget, // Change to remaining budget
                          income: monthlyIncome + expenseProvider.additionalIncome, // Include additional income
                          expense: totalSpending,
                          currencyCode: currencyCode,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Information about recurring income
                      if (expenseProvider.userProfile != null) 
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                          child: Center(
                            child: Text(
                              'Monthly income of ${getCurrencySymbol(currencyCode)}${NumberFormat.decimalPattern().format(monthlyIncome)} on ${expenseProvider.recurringIncomeDateFormatted}',
                              style: TextStyle(
                                color: subtitleColor,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 16),
                      
                      // Filter Buttons and See All in one row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TransactionFilterButtons(
                                selectedFilter: _currentFilter,
                                onFilterChanged: (filter) {
                                  setState(() {
                                    _currentFilter = filter;
                                  });
                                },
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // TODO: Navigate to all transactions
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: textColor,
                              ),
                              child: const Text('See All'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Recent Transactions Text
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Recent Transactions',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: textColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Show empty state for income filter
                      if (filteredExpenses.isEmpty && filteredIncomes.isEmpty && _currentFilter == TransactionFilterType.all)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.account_balance_wallet_outlined,
                                  size: 48,
                                  color: subtitleColor,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No transactions recorded yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: subtitleColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      // Show income list when income filter is selected
                      else if (_currentFilter == TransactionFilterType.income)
                        filteredIncomes.isEmpty 
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet_outlined,
                                    size: 48,
                                    color: subtitleColor,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No income recorded yet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: subtitleColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap + to add your first income',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: subtitleColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredIncomes.length,
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                            ),
                            itemBuilder: (context, index) {
                              final income = filteredIncomes[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.green.withOpacity(0.2),
                                  child: Icon(Icons.trending_up, color: Colors.green),
                                ),
                                title: Text(income.source),
                                subtitle: Text(DateFormat('MMM dd, yyyy').format(income.date)),
                                trailing: Text(
                                  '${getCurrencySymbol(currencyCode)}${NumberFormat.decimalPattern().format(income.amount)}',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onLongPress: () {
                                  _confirmDeleteIncome(context, expenseProvider, income);
                                },
                              );
                            },
                          )
                      // Show empty state for expense filter  
                      else if (filteredExpenses.isEmpty && _currentFilter == TransactionFilterType.expense)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 48,
                                  color: subtitleColor,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No expenses recorded yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: subtitleColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap + to add your first expense',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: subtitleColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      // Show transaction list  
                      else
                        Column(
                          children: [
                            // Display expenses
                            if (filteredExpenses.isNotEmpty)
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredExpenses.length,
                                separatorBuilder: (context, index) => Divider(
                                  height: 1,
                                  color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                                ),
                                itemBuilder: (context, index) {
                                  final expense = filteredExpenses[index];
                                  return Dismissible(
                                    key: Key(expense.id),
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      color: Colors.red.shade400,
                                      padding: const EdgeInsets.only(right: 20.0),
                                      child: const Icon(Icons.delete_outline, color: Colors.white),
                                    ),
                                    direction: DismissDirection.endToStart,
                                    confirmDismiss: (direction) => _confirmDelete(context),
                                    onDismissed: (direction) {
                                      expenseProvider.deleteExpense(expense.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${expense.description} deleted'),
                                          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[900],
                                        ),
                                      );
                                    },
                                    child: TransactionListItem(
                                      expense: expense,
                                      currencyCode: currencyCode,
                                      onTap: () {
                                        // TODO: Navigate to expense details
                                      },
                                    ),
                                  );
                                },
                              ),
                            
                            // Display incomes for All filter
                            if (_currentFilter == TransactionFilterType.all && filteredIncomes.isNotEmpty)
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredIncomes.length,
                                separatorBuilder: (context, index) => Divider(
                                  height: 1,
                                  color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                                ),
                                itemBuilder: (context, index) {
                                  final income = filteredIncomes[index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.green.withOpacity(0.2),
                                      child: Icon(Icons.trending_up, color: Colors.green),
                                    ),
                                    title: Text(income.source),
                                    subtitle: Text(DateFormat('MMM dd').format(income.date)),
                                    trailing: Text(
                                      '${getCurrencySymbol(currencyCode)}${NumberFormat.decimalPattern().format(income.amount)}',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onLongPress: () {
                                      _confirmDeleteIncome(context, expenseProvider, income);
                                    },
                                  );
                                },
                              ),
                          ],
                        ),
                      
                      // Add some bottom padding
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
          floatingActionButton: SpeedDial(
            icon: Icons.add,
            activeIcon: Icons.close,
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: const CircleBorder(),
            overlayOpacity: 0.4,
            spacing: 12,
            spaceBetweenChildren: 12,
            children: [
              SpeedDialChild(
                child: const Icon(Icons.trending_up),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                label: 'Add Income',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddIncomeScreen()),
                  );
                },
              ),
              SpeedDialChild(
                child: const Icon(Icons.trending_down),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                label: 'Report Expense',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildBudgetSection(
    BuildContext context, 
    double budgetGoal, 
    double totalSpending, 
    double budgetPercentage, 
    double budgetRemaining,
    String currencyCode,
    bool isDarkMode
  ) {
    final backgroundColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Budget header
            Text(
              'Monthly Budget',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            
            // Budget progress
            LinearProgressIndicator(
              value: budgetPercentage > 1.0 ? 1.0 : budgetPercentage,
              backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                budgetPercentage > 0.9 
                  ? Colors.red 
                  : (budgetPercentage > 0.7 
                      ? Colors.orange 
                      : (isDarkMode ? Colors.white : Colors.black)),
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 16),
            
            // Budget details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spent',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$currencyCode ${NumberFormat.decimalPattern().format(totalSpending)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Budget',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$currencyCode ${NumberFormat.decimalPattern().format(budgetGoal)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Future<bool?> _confirmDelete(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        title: Text(
          'Delete Transaction',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this transaction?',
          style: TextStyle(
            color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'CANCEL',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'DELETE',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _confirmDeleteIncome(BuildContext context, ExpenseProvider expenseProvider, Income income) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        title: Text(
          'Delete Income',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this income?',
          style: TextStyle(
            color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'CANCEL',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'DELETE',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    
    if (shouldDelete == true) {
      final success = await expenseProvider.deleteIncome(income.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${income.source} deleted'),
            backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[900],
          ),
        );
      }
    }
  }

  // Generate a simple AI tip based on spending patterns
  String _getAITip(double totalSpending, double monthlyIncome, Map<ExpenseCategory, double> spendingByCategory) {
    // Simple example logic for AI tips - in a real app, this would be from Gemini API
    if (totalSpending == 0) {
      return "Start tracking your expenses to get personalized insights!";
    }
    
    if (totalSpending > monthlyIncome * 0.9) {
      return "You've spent 90% of your monthly income. Consider reducing expenses for the rest of the month.";
    }
    
    // Find highest spending category
    ExpenseCategory? highestCategory;
    double highestAmount = 0;
    
    spendingByCategory.forEach((category, amount) {
      if (amount > highestAmount) {
        highestAmount = amount;
        highestCategory = category;
      }
    });
    
    if (highestCategory != null && highestAmount > monthlyIncome * 0.3) {
      return "Your spending on '${highestCategory!.displayName}' is higher than usual. This category accounts for ${(highestAmount / totalSpending * 100).toStringAsFixed(0)}% of your expenses.";
    }
    
    // Default tip
    return "You're on track with your budget this month. Keep it up!";
  }

  // Helper method to get currency symbol - always returns £ now
  String getCurrencySymbol(String code) {
    return '£';
  }
  
  // Dialog to set budget
  void _showBudgetDialog(BuildContext context, ExpenseProvider expenseProvider) {
    final TextEditingController budgetController = TextEditingController();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currencyCode = expenseProvider.currencyCode;
    final currencySymbol = getCurrencySymbol(currencyCode);
    final monthlyIncome = expenseProvider.monthlyIncome;
    
    // For displaying error message
    String? errorMessage;
    
    if (expenseProvider.monthlyBudget > 0) {
      budgetController.text = expenseProvider.monthlyBudget.toString();
    }
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
              title: Text(
                'Set Monthly Budget',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter your monthly budget amount',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Available monthly income: $currencySymbol${NumberFormat.decimalPattern().format(monthlyIncome)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: budgetController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'Monthly Budget',
                      prefixText: '$currencySymbol ',
                      prefixIcon: const Icon(Icons.calculate_outlined),
                      errorText: errorMessage,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'CANCEL',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final newBudget = double.tryParse(budgetController.text) ?? 0;
                    
                    // Validate budget against monthly income
                    if (newBudget > monthlyIncome) {
                      setState(() {
                        errorMessage = 'Budget cannot exceed monthly income';
                      });
                      return;
                    }
                    
                    if (newBudget > 0) {
                      final success = await expenseProvider.updateBudget(newBudget);
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Budget updated successfully')),
                        );
                        Navigator.pop(context);
                      } else if (context.mounted && expenseProvider.error != null) {
                        setState(() {
                          errorMessage = expenseProvider.error;
                        });
                      }
                    } else if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    'SAVE',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          }
        );
      },
    );
  }
} 