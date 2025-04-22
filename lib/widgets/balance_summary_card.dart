import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BalanceSummaryCard extends StatelessWidget {
  final double totalBalance;
  final double income;
  final double expense;
  final String currencyCode;

  const BalanceSummaryCard({
    super.key,
    required this.totalBalance, 
    required this.income, 
    required this.expense,
    required this.currencyCode,
  });

  // Helper method to get currency symbol
  String getCurrencySymbol(String code) {
    return '£';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currencySymbol = getCurrencySymbol(currencyCode);
    final backgroundColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];
    final positiveColor = Colors.green;
    final negativeColor = Colors.red;
    final dividerColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: backgroundColor,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title - Total Balance
            Text(
              'Total Balance',
              style: TextStyle(
                fontSize: 14,
                color: subtitleColor,
              ),
            ),
            const SizedBox(height: 10),
            
            // Total Balance Amount (larger, more prominent)
            Row(
              children: [
                Text(
                  '$currencySymbol${NumberFormat.decimalPattern().format(totalBalance)}',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                // Currency button
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      currencySymbol,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            
            // Income and Expense Row - centered with vertical divider
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    // Income
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Income',
                              style: TextStyle(
                                fontSize: 14,
                                color: subtitleColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$currencySymbol${NumberFormat.decimalPattern().format(income)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: positiveColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Vertical Divider
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: dividerColor,
                      indent: 8,
                      endIndent: 8,
                    ),
                    
                    // Expense
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Expense',
                              style: TextStyle(
                                fontSize: 14,
                                color: subtitleColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$currencySymbol${NumberFormat.decimalPattern().format(expense)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: negativeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 