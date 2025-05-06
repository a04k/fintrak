import 'package:flutter/material.dart';
import '../models/category.dart';

enum TransactionFilterType {
  all,
  income,
  expense,
}

enum TimePeriodFilter {
  all,
  last3Days,
  lastWeek,
  last10Days,
  last20Days,
}

class TransactionFilterButtons extends StatelessWidget {
  final TransactionFilterType selectedFilter;
  final ExpenseCategory? selectedCategory;
  final TimePeriodFilter selectedTimePeriod;
  final Function(TransactionFilterType) onFilterChanged;
  final Function(ExpenseCategory?) onCategoryChanged;
  final Function(TimePeriodFilter) onTimePeriodChanged;

  const TransactionFilterButtons({
    super.key,
    required this.selectedFilter,
    this.selectedCategory,
    required this.selectedTimePeriod,
    required this.onFilterChanged,
    required this.onCategoryChanged,
    required this.onTimePeriodChanged,
  });

  String _getTimePeriodLabel(TimePeriodFilter period) {
    switch (period) {
      case TimePeriodFilter.all:
        return 'All Time';
      case TimePeriodFilter.last3Days:
        return 'Last 3 Days';
      case TimePeriodFilter.lastWeek:
        return 'Last Week';
      case TimePeriodFilter.last10Days:
        return 'Last 10 Days';
      case TimePeriodFilter.last20Days:
        return 'Last 20 Days';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        Container(
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
        ),
        if (selectedFilter == TransactionFilterType.expense) ...[
          const SizedBox(height: 16),
          // Category Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ExpenseCategory?>(
                value: selectedCategory,
                isExpanded: true,
                hint: Text(
                  'All Categories',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                dropdownColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                items: [
                  DropdownMenuItem<ExpenseCategory?>(
                    value: null,
                    child: Text(
                      'All Categories',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  ...ExpenseCategory.values.map((category) {
                    return DropdownMenuItem<ExpenseCategory>(
                      value: category,
                      child: Row(
                        children: [
                          Icon(
                            category.icon,
                            size: 18,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category.displayName,
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
                onChanged: onCategoryChanged,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Time Period Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<TimePeriodFilter>(
                value: selectedTimePeriod,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                dropdownColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                items: TimePeriodFilter.values.map((period) {
                  return DropdownMenuItem<TimePeriodFilter>(
                    value: period,
                    child: Text(
                      _getTimePeriodLabel(period),
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    onTimePeriodChanged(value);
                  }
                },
              ),
            ),
          ),
        ],
      ],
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