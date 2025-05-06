import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/expense_provider.dart';
import '../services/theme_provider.dart';
import '../models/user_profile.dart';
import '../screens/profile_setup_screen.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userName = expenseProvider.userProfile?.name ?? "User";
    final monthlyIncome = expenseProvider.monthlyIncome;
    final currencyCode = expenseProvider.currencyCode;
    final currencySymbol = '£';
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 32,
            color: textColor,
          ),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        toolbarHeight: 100,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          Card(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  userName[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(userName),
              subtitle: Text('Monthly Income: $currencySymbol${NumberFormat.decimalPattern().format(monthlyIncome)}'),
            ),
          ),
          const SizedBox(height: 16),
          
          // Theme Settings
          Card(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.light_mode_outlined, color: textColor),
                  title: Text('Light Theme', style: TextStyle(color: textColor)),
                  onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                  trailing: themeProvider.isLightMode
                      ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                      : null,
                ),
                ListTile(
                  leading: Icon(Icons.dark_mode_outlined, color: textColor),
                  title: Text('Dark Theme', style: TextStyle(color: textColor)),
                  onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                  trailing: themeProvider.isDarkMode
                      ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                      : null,
                ),
                ListTile(
                  leading: Icon(Icons.settings_system_daydream_outlined, color: textColor),
                  title: Text('System Theme', style: TextStyle(color: textColor)),
                  onTap: () => themeProvider.setThemeMode(ThemeMode.system),
                  trailing: themeProvider.isSystemMode
                      ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Budget Settings
          Card(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            child: ListTile(
              leading: Icon(Icons.calculate_outlined, color: textColor),
              title: Text('Monthly Budget', style: TextStyle(color: textColor)),
              subtitle: Text(
                'Set your monthly spending limit',
                style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
              ),
              onTap: () => _showBudgetDialog(context, expenseProvider),
            ),
          ),
          const SizedBox(height: 16),

          // Income Settings
          Card(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            child: ListTile(
              leading: Icon(Icons.account_balance_wallet_outlined, color: textColor),
              title: Text('Monthly Income', style: TextStyle(color: textColor)),
              subtitle: Text(
                'Update your recurring income',
                style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
              ),
              onTap: () => _showIncomeDialog(context, expenseProvider),
            ),
          ),
          const SizedBox(height: 16),

          // Reset App Data
          Card(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            child: ListTile(
              leading: Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Reset App Data', style: TextStyle(color: Colors.red)),
              subtitle: Text(
                'Delete all data and start fresh',
                style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
              ),
              onTap: () => _showResetConfirmation(context, expenseProvider),
            ),
          ),
        ],
      ),
    );
  }

  // Budget Dialog
  void _showBudgetDialog(BuildContext context, ExpenseProvider expenseProvider) {
    final TextEditingController budgetController = TextEditingController();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currencySymbol = '£';
    final monthlyIncome = expenseProvider.monthlyIncome;
    
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

  // Income Dialog
  void _showIncomeDialog(BuildContext context, ExpenseProvider expenseProvider) {
    final TextEditingController incomeController = TextEditingController();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currencySymbol = '£';
    DateTime selectedDate = expenseProvider.recurringIncomeDate;
    
    incomeController.text = expenseProvider.monthlyIncome.toString();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
          title: Text(
            'Update Monthly Income',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: incomeController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Monthly Income',
                  prefixText: '$currencySymbol ',
                  prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Income Date: ${DateFormat('MMMM d').format(selectedDate)}',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                ),
              ),
              TextButton(
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null && context.mounted) {
                    selectedDate = DateTime(2000, picked.month, picked.day);
                  }
                },
                child: const Text('Change Date'),
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
                final newIncome = double.tryParse(incomeController.text) ?? 0;
                if (newIncome > 0) {
                  final success = await expenseProvider.updateMonthlyIncome(newIncome, selectedDate);
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Monthly income updated successfully')),
                    );
                    Navigator.pop(context);
                  }
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
      },
    );
  }

  // Reset Confirmation Dialog
  void _showResetConfirmation(BuildContext context, ExpenseProvider expenseProvider) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        title: const Text('Reset App Data?', style: TextStyle(color: Colors.red)),
        content: const Text(
          'This will permanently delete all your data including expenses, income, and settings. This action cannot be undone.',
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
              final success = await expenseProvider.resetAppData();
              if (success && context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              'RESET',
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
}

class SettingsSectionHeader extends StatelessWidget {
  final String title;
  
  const SettingsSectionHeader({super.key, required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class SettingsListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? textColor;
  
  const SettingsListTile({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
    this.onTap,
    this.textColor,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return ListTile(
      leading: Icon(icon, color: textColor ?? (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700)),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? (isDarkMode ? Colors.white : Colors.black),
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null ? Text(
        subtitle!,
        style: TextStyle(
          color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
        ),
      ) : null,
      trailing: onTap != null 
          ? Icon(Icons.chevron_right, size: 20, color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700) 
          : null,
      onTap: onTap,
    );
  }
} 