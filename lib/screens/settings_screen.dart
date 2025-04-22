import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/expense_provider.dart';
import '../models/user_profile.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final userName = expenseProvider.userProfile?.name ?? "User";
    final monthlyIncome = expenseProvider.monthlyIncome;
    final currencyCode = expenseProvider.currencyCode;
    
    // Get currency symbol
    String getCurrencySymbol(String code) {
      return '£';
    }
    
    final currencySymbol = getCurrencySymbol(currencyCode);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        toolbarHeight: 100, // Increased for more spacing from top
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // User profile section
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : "U",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  if (expenseProvider.userProfile != null)
                    Text(
                      currencySymbol, // Display symbol instead of code
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Settings options
          const SettingsSectionHeader(title: 'Account'),
          SettingsListTile(
            title: 'Current Income',
            icon: Icons.payments_outlined,
            subtitle: '$currencySymbol ${NumberFormat.decimalPattern().format(monthlyIncome)}/month',
            onTap: () {
              _showIncomeUpdateDialog(context, expenseProvider);
            },
          ),
          SettingsListTile(
            title: 'Income Date',
            icon: Icons.calendar_today_outlined,
            subtitle: expenseProvider.recurringIncomeDateFormatted,
            onTap: () {
              _showDatePickerDialog(context, expenseProvider);
            },
          ),
          
          const SettingsSectionHeader(title: 'Preferences'),
          SettingsListTile(
            title: 'Theme',
            icon: Icons.brightness_6_outlined,
            subtitle: 'Light',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Theme Settings - Feature coming soon!')),
              );
            },
          ),
          
          const SettingsSectionHeader(title: 'Data'),
          SettingsListTile(
            title: 'Reset App Data',
            icon: Icons.delete_outline,
            textColor: Colors.red,
            onTap: () {
              _showResetConfirmationDialog(context, expenseProvider);
            },
          ),
          
          const SettingsSectionHeader(title: 'About'),
          SettingsListTile(
            title: 'Version',
            icon: Icons.info_outline,
            subtitle: '1.0.0',
            onTap: null,
          ),
        ],
      ),
    );
  }
  
  void _showIncomeUpdateDialog(BuildContext context, ExpenseProvider expenseProvider) {
    final TextEditingController incomeController = TextEditingController();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currencyCode = expenseProvider.currencyCode;
    
    // Get currency symbol
    String getCurrencySymbol(String code) {
      return '£';
    }
    
    final currencySymbol = getCurrencySymbol(currencyCode);
    
    // Get the current recurring income date
    final currentIncomeDate = expenseProvider.recurringIncomeDate;
    
    if (expenseProvider.monthlyIncome > 0) {
      incomeController.text = expenseProvider.monthlyIncome.toString();
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
          children: [
            Text(
              'Enter your updated monthly income',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: incomeController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Monthly Income',
                prefixText: '$currencySymbol ',
                prefixIcon: const Icon(Icons.payments_outlined),
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
              final newIncome = double.tryParse(incomeController.text) ?? 0;
              if (newIncome > 0) {
                final success = await expenseProvider.updateMonthlyIncome(
                  newIncome, 
                  currentIncomeDate, // Keep the same date
                );
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Monthly income updated successfully')),
                  );
                }
              }
              if (context.mounted) {
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
      ),
    );
  }
  
  void _showDatePickerDialog(BuildContext context, ExpenseProvider expenseProvider) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Get the current recurring income date
    final currentIncomeDate = expenseProvider.recurringIncomeDate;
    
    // Show date picker
    showDatePicker(
      context: context,
      initialDate: currentIncomeDate,
      firstDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
      lastDate: DateTime(DateTime.now().year, DateTime.now().month, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDarkMode 
              ? const ColorScheme.dark(
                  primary: Colors.white,
                  onPrimary: Colors.black,
                  surface: Color(0xFF2A2A2A),
                  onSurface: Colors.white,
                )
              : const ColorScheme.light(
                  primary: Colors.black,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
          ),
          child: child!,
        );
      },
    ).then((pickedDate) async {
      if (pickedDate != null && pickedDate != currentIncomeDate) {
        // Update the income date
        final success = await expenseProvider.updateMonthlyIncome(
          expenseProvider.monthlyIncome, 
          pickedDate,
        );
        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Income date updated successfully')),
          );
        }
      }
    });
  }
  
  Future<void> _updateIncome(
    BuildContext context, 
    ExpenseProvider expenseProvider, 
    double newIncome
  ) async {
    if (expenseProvider.userProfile != null) {
      // Update using the new method
      final success = await expenseProvider.updateMonthlyIncome(
        newIncome,
        expenseProvider.recurringIncomeDate,
      );
      
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Monthly income updated successfully')),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update income'), backgroundColor: Colors.red),
        );
      }
    }
  }
  
  void _showResetConfirmationDialog(BuildContext context, ExpenseProvider expenseProvider) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        title: Text(
          'Reset App Data?',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This will delete all your expenses and profile information. This action cannot be undone.',
          style: TextStyle(
            color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
          ),
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
              // Use the new resetAppData method
              final success = await expenseProvider.resetAppData();
              Navigator.pop(context);
              
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data has been reset')),
                );
                
                // Navigate back to profile setup
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                }
              }
            },
            child: const Text(
              'RESET',
              style: TextStyle(color: Colors.red),
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