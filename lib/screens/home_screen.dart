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
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  // Optional: Pass UserProfile if needed, or use state management later
  // final UserProfile userProfile;
  // const HomeScreen({super.key, required this.userProfile});
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TransactionFilterType _selectedFilter = TransactionFilterType.all;
  ExpenseCategory? _selectedCategory;
  TimePeriodFilter _selectedTimePeriod = TimePeriodFilter.all;

  List<dynamic> _getFilteredTransactions(ExpenseProvider provider) {
    List<dynamic> transactions = [];
    DateTime? startDate;

    // Calculate start date based on selected time period
    switch (_selectedTimePeriod) {
      case TimePeriodFilter.last3Days:
        startDate = DateTime.now().subtract(const Duration(days: 3));
        break;
      case TimePeriodFilter.lastWeek:
        startDate = DateTime.now().subtract(const Duration(days: 7));
        break;
      case TimePeriodFilter.last10Days:
        startDate = DateTime.now().subtract(const Duration(days: 10));
        break;
      case TimePeriodFilter.last20Days:
        startDate = DateTime.now().subtract(const Duration(days: 20));
        break;
      case TimePeriodFilter.all:
        // For "all", we'll only show transactions from the current month
        startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
        break;
    }

    switch (_selectedFilter) {
      case TransactionFilterType.all:
        transactions = [...provider.expenses, ...provider.incomes];
        break;
      case TransactionFilterType.income:
        transactions = [...provider.incomes];
        break;
      case TransactionFilterType.expense:
        transactions = [...provider.expenses];
        if (_selectedCategory != null) {
          transactions = transactions.where((expense) => 
            expense.category == _selectedCategory
          ).toList();
        }
        break;
    }

    // Apply date filter if startDate is set
    if (startDate != null) {
      transactions = transactions.where((transaction) {
        final transactionDate = transaction is Expense ? transaction.date : transaction.date;
        return transactionDate.isAfter(startDate!);
      }).toList();
    }

    // Sort transactions by date (most recent first)
    transactions.sort((a, b) {
      final dateA = a is Expense ? a.date : a.date;
      final dateB = b is Expense ? b.date : b.date;
      return dateB.compareTo(dateA);
    });

    return transactions;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];
    
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
        actions: const [
          SizedBox(width: 8),
        ],
      ),
      body: Selector<ExpenseProvider, bool>(
        selector: (_, provider) => provider.isLoading,
        builder: (context, isLoading, child) {
          if (isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            );
          }
          
          return Consumer<ExpenseProvider>(
            builder: (context, expenseProvider, child) {
              // Get user data from provider
              final userName = expenseProvider.userProfile?.name ?? "User";
              final filteredTransactions = _getFilteredTransactions(expenseProvider);
              
              // Budget management
              final budgetGoal = expenseProvider.monthlyBudget;
              final budgetPercentage = budgetGoal > 0 ? expenseProvider.totalSpending / budgetGoal : 0.0;
              final budgetRemaining = budgetGoal - expenseProvider.totalSpending;
              
              // Calculate total balance
              final totalBalance = expenseProvider.monthlyIncome - expenseProvider.totalSpending;
              
              return RefreshIndicator(
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
                          totalBalance: expenseProvider.remainingBudget,
                          income: expenseProvider.monthlyIncome + expenseProvider.additionalIncome,
                          expense: expenseProvider.totalSpending,
                          currencyCode: expenseProvider.currencyCode,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Filter Buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TransactionFilterButtons(
                          selectedFilter: _selectedFilter,
                          selectedCategory: _selectedCategory,
                          selectedTimePeriod: _selectedTimePeriod,
                          onFilterChanged: (filter) {
                            setState(() {
                              _selectedFilter = filter;
                              if (filter != TransactionFilterType.expense) {
                                _selectedCategory = null;
                              }
                            });
                          },
                          onCategoryChanged: (category) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          onTimePeriodChanged: (period) {
                            setState(() {
                              _selectedTimePeriod = period;
                            });
                          },
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
                      
                      // Transactions List
                      if (filteredTransactions.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32.0),
                            child: Text(
                              'No transactions found',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white70 : Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(top: 8),
                          itemCount: filteredTransactions.length,
                          itemBuilder: (context, index) {
                            final transaction = filteredTransactions[index];
                            return TransactionListItem(
                              transaction: transaction,
                              isDarkMode: isDarkMode,
                              onDelete: () async {
                                if (transaction is Expense) {
                                  await expenseProvider.deleteExpense(transaction.id);
                                } else if (transaction is Income) {
                                  await expenseProvider.deleteIncome(transaction.id);
                                }
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: isDarkMode ? Colors.white : Colors.black,
        foregroundColor: isDarkMode ? Colors.black : Colors.white,
        activeBackgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[300],
        activeForegroundColor: isDarkMode ? Colors.white : Colors.black,
        spacing: 3,
        childPadding: const EdgeInsets.all(5),
        spaceBetweenChildren: 4,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.trending_up),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            label: 'Add Income',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddIncomeScreen()),
            ),
          ),
          SpeedDialChild(
            child: const Icon(Icons.trending_down),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            label: 'Add Expense',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
            ),
          ),
        ],
      ),
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
  
  Future<void> _confirmDeleteExpense(BuildContext context, ExpenseProvider provider, Expense expense) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        title: Text(
          'Delete Expense?',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this expense?\n\n${expense.description}\n£${NumberFormat.decimalPattern().format(expense.amount)}',
          style: TextStyle(
            color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'CANCEL',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
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

    if (confirmed == true && context.mounted) {
      final success = await provider.deleteExpense(expense.id);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${expense.description} deleted'),
            backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[900],
          ),
        );
      }
    }
  }

  Future<void> _confirmDeleteIncome(BuildContext context, ExpenseProvider provider, Income income) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        title: Text(
          'Delete Income?',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this income?\n\n${income.source}\n£${NumberFormat.decimalPattern().format(income.amount)}',
          style: TextStyle(
            color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'CANCEL',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
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

    if (confirmed == true && context.mounted) {
      final success = await provider.deleteIncome(income.id);
      if (success && context.mounted) {
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