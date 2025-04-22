import 'package:flutter/material.dart';

enum TransactionFilterType {
  all,
  income,
  expense,
}

class TransactionFilterButtons extends StatelessWidget {
  final TransactionFilterType selectedFilter;
  final Function(TransactionFilterType) onFilterChanged;

  const TransactionFilterButtons({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFilterButton(
            context,
            'All',
            TransactionFilterType.all,
            isDarkMode,
          ),
          const SizedBox(width: 12),
          _buildFilterButton(
            context,
            'Income',
            TransactionFilterType.income,
            isDarkMode,
          ),
          const SizedBox(width: 12),
          _buildFilterButton(
            context,
            'Expense',
            TransactionFilterType.expense,
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(
    BuildContext context,
    String label,
    TransactionFilterType type,
    bool isDarkMode,
  ) {
    final isSelected = selectedFilter == type;
    
    // Colors to match the design in the image
    final selectedBgColor = isDarkMode ? Colors.white : Colors.black;
    final unselectedBgColor = isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5);
    
    return Expanded(
      child: InkWell(
        onTap: () => onFilterChanged(type),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isSelected ? selectedBgColor : unselectedBgColor,
            borderRadius: BorderRadius.circular(24),
            border: isSelected
                ? null
                : Border.all(
                    color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                    width: 1,
                  ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected 
                    ? (isDarkMode ? Colors.black : Colors.white)
                    : (isDarkMode ? Colors.white : Colors.black87),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
} 