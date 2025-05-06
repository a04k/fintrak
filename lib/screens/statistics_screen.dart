import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/expense_provider.dart';
import '../models/category.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../widgets/budget_progress_bar.dart';
import '../widgets/transaction_list_item.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Monthly Statistics',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            // Month selector
            TextButton(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedMonth,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDatePickerMode: DatePickerMode.year,
                );
                if (picked != null) {
                  setState(() {
                    _selectedMonth = DateTime(picked.year, picked.month);
                  });
                }
              },
              child: Text(
                DateFormat('MMMM yyyy').format(_selectedMonth),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          final startDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
          final endDate = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

          final monthlySpending = provider.getTotalSpending(
            startDate: startDate,
            endDate: endDate,
          );

          // If there's no spending for the month, show empty state
          if (monthlySpending == 0) {
            return Center(
              child: Text(
                'No data for ${DateFormat('MMMM yyyy').format(_selectedMonth)}',
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 16,
                ),
              ),
            );
          }

          final monthlyBudget = provider.monthlyBudget;
          final categorySpending = provider.getSpendingByCategory(
            startDate: startDate,
            endDate: endDate,
          );

          // Get all transactions for the month
          final List<dynamic> transactions = [
            ...provider.expenses.where((e) => 
              e.date.isAfter(startDate.subtract(const Duration(days: 1))) && 
              e.date.isBefore(endDate.add(const Duration(days: 1)))
            ),
            ...provider.incomes.where((i) => 
              i.date.isAfter(startDate.subtract(const Duration(days: 1))) && 
              i.date.isBefore(endDate.add(const Duration(days: 1)))
            ),
          ];

          // Sort transactions by date (most recent first)
          transactions.sort((a, b) {
            final dateA = a is Expense ? a.date : a.date;
            final dateB = b is Expense ? b.date : b.date;
            return dateB.compareTo(dateA);
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Monthly Overview Card
                Card(
                  color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Budget',
                                  style: TextStyle(
                                    color: subtitleColor,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '£${NumberFormat.decimalPattern().format(monthlyBudget)}',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Spent',
                                  style: TextStyle(
                                    color: subtitleColor,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '£${NumberFormat.decimalPattern().format(monthlySpending)}',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (categorySpending.isNotEmpty) ...[
                          // Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              height: 24,
                              child: Row(
                                children: [
                                  ...categorySpending.entries.map((entry) {
                                    final percentage = monthlyBudget > 0
                                        ? (entry.value / monthlyBudget)
                                        : 0.0;
                                    return Expanded(
                                      flex: (percentage * 100).round(),
                                      child: Container(
                                        color: entry.key.color,
                                      ),
                                    );
                                  }).toList(),
                                  if (monthlySpending < monthlyBudget)
                                    Expanded(
                                      flex: ((monthlyBudget - monthlySpending) / monthlyBudget * 100).round(),
                                      child: Container(
                                        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Category Summary
                          ...categorySpending.entries.map((entry) {
                            final percentage = monthlyBudget > 0
                                ? (entry.value / monthlyBudget * 100)
                                : 0.0;
                            if (entry.value == 0) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: entry.key.color,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    entry.key.icon,
                                    size: 20,
                                    color: textColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      entry.key.displayName,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '£${NumberFormat.decimalPattern().format(entry.value)}',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 45,
                                    child: Text(
                                      '${percentage.toStringAsFixed(1)}%',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        color: subtitleColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Transactions List
                Text(
                  'Transactions',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return TransactionListItem(
                      transaction: transaction,
                      isDarkMode: isDarkMode,
                      onDelete: () async {
                        if (transaction is Expense) {
                          await provider.deleteExpense(transaction.id);
                        } else if (transaction is Income) {
                          await provider.deleteIncome(transaction.id);
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 