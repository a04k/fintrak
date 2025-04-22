import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/category.dart';

class TransactionListItem extends StatelessWidget {
  final Expense expense;
  final String currencyCode;
  final VoidCallback? onTap;
  
  const TransactionListItem({
    super.key, 
    required this.expense,
    required this.currencyCode,
    this.onTap,
  });
  
  // Helper method to get currency symbol
  String getCurrencySymbol(String code) {
    return '£';
  }
  
  @override
  Widget build(BuildContext context) {
    // Format date
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('yyyy-MM-dd');
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtitleColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];
    final currencySymbol = getCurrencySymbol(currencyCode);
    
    // Color based on transaction type
    final isIncome = expense.description.toLowerCase().contains('salary') || 
                     expense.description.toLowerCase().contains('freelance');
    final amountColor = isIncome ? Colors.green : Colors.red;
    final amountPrefix = isIncome ? '' : '-';
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 4.0),
        child: Row(
          children: [
            // Category Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isIncome ? Colors.green.withOpacity(0.2) : expense.category.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isIncome 
                  ? Icons.account_balance_wallet_outlined 
                  : expense.category.icon,
                color: isIncome ? Colors.green : expense.category.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            
            // Description and Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.description,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormat.format(expense.date),
                    style: TextStyle(
                      fontSize: 13,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            
            // Amount
            Text(
              '$amountPrefix$currencySymbol${NumberFormat.decimalPattern().format(expense.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 