import 'package:flutter/material.dart';

enum BottomNavItem {
  home,
  chat,
  settings,
}

class FinTrakBottomNavBar extends StatelessWidget {
  final BottomNavItem currentIndex;
  final Function(BottomNavItem) onTabSelected;

  const FinTrakBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDarkMode ? Colors.grey.withOpacity(0.3) : Colors.grey.withOpacity(0.2);
    
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, -5),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: borderColor,
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context: context,
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Home',
              item: BottomNavItem.home,
              isDarkMode: isDarkMode,
            ),
            _buildNavItem(
              context: context,
              icon: Icons.chat_bubble_outline,
              activeIcon: Icons.chat_bubble,
              label: 'Chat',
              item: BottomNavItem.chat,
              isDarkMode: isDarkMode,
            ),
            _buildNavItem(
              context: context,
              icon: Icons.settings_outlined,
              activeIcon: Icons.settings,
              label: 'Settings',
              item: BottomNavItem.settings,
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required BottomNavItem item,
    required bool isDarkMode,
  }) {
    final isSelected = currentIndex == item;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final color = isSelected 
        ? primaryColor 
        : (isDarkMode ? Colors.grey[400] : Colors.grey[700]);

    return InkWell(
      onTap: () => onTabSelected(item),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: SizedBox(
        height: 55,
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: color,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 