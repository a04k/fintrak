import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart'; // Contains UserInfoScreen
import 'screens/home_screen.dart'; 
import 'services/expense_provider.dart';
import 'screens/loading_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/main_app_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ExpenseProvider(prefs),
      child: MaterialApp(
        title: 'FinTrak',
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xFF2962FF),
            onPrimary: Color(0xFFFFFFFF),
            secondary: Color(0xFF767680),
            onSecondary: Color(0xFFFFFFFF),
            error: Color(0xFFBA1A1A),
            onError: Color(0xFFFFFFFF),
            background: Color(0xFFFAFAFA),
            onBackground: Color(0xFF000000),
            surface: Color(0xFFFFFFFF),
            onSurface: Color(0xFF000000),
            surfaceTint: Color(0xFFFFFFFF),
          ),
          cardTheme: CardTheme(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            displayMedium: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            headlineMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
            titleLarge: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2962FF),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black, width: 1),
            ),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme(
            brightness: Brightness.dark,
            primary: Color(0xFFFFFFFF),
            onPrimary: Color(0xFF000000),
            secondary: Color(0xFF767680), 
            onSecondary: Color(0xFF000000),
            error: Color(0xFFFF8A80),
            onError: Color(0xFF000000),
            background: Color(0xFF121212),
            onBackground: Color(0xFFFFFFFF),
            surface: Color(0xFF1E1E1E),
            onSurface: Color(0xFFFFFFFF),
            surfaceTint: Color(0xFF1E1E1E),
          ),
          cardTheme: CardTheme(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: const Color(0xFF1E1E1E),
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            displayMedium: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            headlineMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            titleLarge: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
            backgroundColor: Color(0xFF121212),
            foregroundColor: Colors.white,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white, width: 1),
            ),
          ),
        ),
        themeMode: ThemeMode.light,
        home: const AppStartupDecider(),
      ),
    );
  }
}

class AppStartupDecider extends StatelessWidget {
  const AppStartupDecider({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    
    print("AppStartupDecider - isLoading: ${expenseProvider.isLoading}, isProfileSet: ${expenseProvider.isProfileSet}");
    
    if (expenseProvider.isLoading) {
      return const LoadingScreen();
    }
    
    if (!expenseProvider.isProfileSet) {
      return const ProfileSetupScreen();
    }
    
    print("Navigating to MainAppScaffold");
    return const MainAppScaffold();
  }
}

// Loading screen that checks for existing user profile
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Load data with the provider
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    await provider.initialize();
    
    if (mounted) {
      // Navigate to the appropriate screen based on profile existence
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => provider.isProfileSet 
            ? const MainAppScaffold()
            : const UserInfoScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or icon
            Icon(
              Icons.account_balance_wallet,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            const Text(
              'FinTrak',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
