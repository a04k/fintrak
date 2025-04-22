import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_screen.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';

class MainAppScaffold extends StatefulWidget {
  const MainAppScaffold({super.key});

  @override
  State<MainAppScaffold> createState() => _MainAppScaffoldState();
}

class _MainAppScaffoldState extends State<MainAppScaffold> {
  BottomNavItem _currentIndex = BottomNavItem.home;

  // Keep instances of screens to maintain their state
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const ChatScreen(),
      const SettingsScreen(), // We'll create this next
    ];
  }

  void _onTabSelected(BottomNavItem index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Building MainAppScaffold with bottom nav bar");
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex.index,
        children: _screens,
      ),
      bottomNavigationBar: FinTrakBottomNavBar(
        currentIndex: _currentIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
} 