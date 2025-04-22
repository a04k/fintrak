import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For currency formatting
import '../models/category.dart'; // Import category details (colors)

class BudgetProgressBar extends StatelessWidget {
  final double monthlyIncome;
  final double totalSpending;
  final Map<ExpenseCategory, double> spendingByCategory;
  final double? budgetGoal; // Optional budget goal line

  const BudgetProgressBar({
    super.key,
    required this.monthlyIncome,
    required this.totalSpending,
    required this.spendingByCategory,
    this.budgetGoal,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure income is not zero to avoid division errors
    final double safeIncome = monthlyIncome <= 0 ? 1.0 : monthlyIncome;
    // Currency formatter (adapt based on UserProfile later)
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'en_US'); // Placeholder locale

    // Sort categories for consistent bar order (optional)
    final sortedCategories = spendingByCategory.keys.toList()
      ..sort((a, b) => a.index.compareTo(b.index));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Progress Bar Stack ---
        Container(
          height: 25, // Height of the progress bar
          decoration: BoxDecoration(
            color: Colors.grey.shade300, // Background of the bar
            borderRadius: BorderRadius.circular(12.5),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              double currentX = 0.0;
              List<Widget> barSegments = [];

              // Create colored segments for each category
              for (var category in sortedCategories) {
                final spending = spendingByCategory[category] ?? 0.0;
                if (spending <= 0) continue; // Skip empty categories

                final segmentWidth = (spending / safeIncome) * maxWidth;
                barSegments.add(
                  Positioned(
                    left: currentX,
                    top: 0,
                    bottom: 0,
                    child: Tooltip( // Show category spending on hover/long press
                      message: '${category.displayName}: ${currencyFormat.format(spending)}',
                      child: Container(
                        width: segmentWidth,
                        decoration: BoxDecoration(
                          color: category.color, // Use color from Category extension
                          // Apply rounded corners smartly
                          borderRadius: BorderRadius.horizontal(
                             left: currentX == 0 ? const Radius.circular(12.5) : Radius.zero,
                             // Right radius only if it's the last segment or fills the bar
                             right: (currentX + segmentWidth >= maxWidth - 0.1) ? const Radius.circular(12.5) : Radius.zero,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
                currentX += segmentWidth;
              }

              // Add the budget goal line if provided and within bounds
              if (budgetGoal != null && budgetGoal! > 0 && budgetGoal! < safeIncome) {
                 final budgetPosition = (budgetGoal! / safeIncome) * maxWidth;
                 barSegments.add(
                   Positioned(
                     left: budgetPosition - 1, // Center the line
                     top: -4, // Extend slightly above/below
                     bottom: -4,
                     child: Container(
                       width: 2, // Thickness of the line
                       color: Colors.black87,
                     ),
                   ),
                 );
              }

              return Stack(children: barSegments);
            },
          ),
        ),
        const SizedBox(height: 8),
        // --- Labels (Income vs Spending) ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Spending: ${currencyFormat.format(totalSpending)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'Income: ${currencyFormat.format(safeIncome)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        // Optional: Budget Goal Label
        if (budgetGoal != null && budgetGoal! > 0)
           Padding(
             padding: const EdgeInsets.only(top: 4.0),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                  Container(width: 10, height: 2, color: Colors.black87), // Line indicator
                  const SizedBox(width: 5),
                  Text(
                     'Budget Goal: ${currencyFormat.format(budgetGoal)}',
                     style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black87),
                   ),
               ],
             ),
           ),
      ],
    );
  }
} 