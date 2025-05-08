import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/splash_screen.dart'; // Contains UserInfoScreen
import 'screens/home_screen.dart'; 
import 'services/expense_provider.dart';
import 'services/storage_service.dart';
import 'services/theme_provider.dart';
import 'screens/loading_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/main_app_scaffold.dart';
import 'services/ai_service.dart'; // NEW: Import AIService
import 'config/api_config.dart'; // NEW: Import API key from config

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage service
  final storageService = StorageService();
  await storageService.init();
  
  // Wrap MyApp within a Provider for AIService using the API key from config
  runApp( 
    Provider<AIService>(
      create: (_) => AIService(APIConfig.geminiApiKey), // using key from lib/config/api_config.dart
      child: MyApp(storageService: storageService),
    ),
  );
}

class MyApp extends StatelessWidget {
  final StorageService storageService;

  const MyApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ExpenseProvider(storageService)),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'WiseWallet',
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.light(
                primary: Colors.blue,
                secondary: Colors.blue.shade700,
                background: Colors.white,
                surface: Colors.white,
                onPrimary: Colors.white,
                onSecondary: Colors.white,
                onBackground: Colors.black,
                onSurface: Colors.black,
              ),
              scaffoldBackgroundColor: Colors.white,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.dark(
                primary: Colors.blue,
                secondary: Colors.blue.shade700,
                background: Colors.black,
                surface: const Color(0xFF121212),
                onPrimary: Colors.white,
                onSecondary: Colors.white,
                onBackground: Colors.white,
                onSurface: Colors.white,
              ),
              scaffoldBackgroundColor: Colors.black,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              useMaterial3: true,
            ),
            home: const AppStartupDecider(),
          );
        },
      ),
    );
  }
}

class AppStartupDecider extends StatefulWidget {
  const AppStartupDecider({super.key});

  @override
  State<AppStartupDecider> createState() => _AppStartupDeciderState();
}

class _AppStartupDeciderState extends State<AppStartupDecider> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      provider.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    
    if (!expenseProvider.isInitialized || expenseProvider.isLoading) {
      return const LoadingScreen();
    }
    
    if (!expenseProvider.isProfileSet) {
      return const ProfileSetupScreen();
    }
    
    return const MainAppScaffold();
  }
}

// Loading screen that checks for existing user profile
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

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
