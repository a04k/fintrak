import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/expense_provider.dart';
import '../models/user_profile.dart';
import 'package:intl/intl.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  DateTime _selectedIncomeDate = DateTime.now(); // For recurring income date

  // Helper method to get currency symbol - always returns £ now
  String get currencySymbol => '£';

  // Format date for display
  String get formattedIncomeDate => DateFormat('MMMM d').format(_selectedIncomeDate);

  // Show date picker for income date
  Future<void> _selectIncomeDate(BuildContext context) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedIncomeDate,
      firstDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
      lastDate: DateTime(DateTime.now().year, DateTime.now().month, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDarkMode 
              ? const ColorScheme.dark(
                  primary: Colors.white,
                  onPrimary: Colors.black,
                  surface: Color(0xFF2A2A2A),
                  onSurface: Colors.white,
                )
              : const ColorScheme.light(
                  primary: Colors.black,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null) {
      setState(() {
        _selectedIncomeDate = pickedDate;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _incomeController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _saveUserProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user profile with budget and recurring income date
      final userProfile = UserProfile(
        name: _nameController.text.trim(),
        monthlyIncome: double.parse(_incomeController.text.trim()),
        currency: 'EGP', // Always use EGP
        recurringIncomeDate: _selectedIncomeDate,
        monthlyBudget: _budgetController.text.isEmpty 
          ? (double.parse(_incomeController.text.trim()) * 0.8) // Default to 80% of income
          : double.parse(_budgetController.text.trim()),
        savingGoal: null, // Setting to null as it's optional and not provided in this screen
      );
      
      // Save user profile
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      final success = await provider.saveUserProfile(userProfile);
      
      if (success && mounted) {
        print("Profile saved successfully, setting user name: ${userProfile.name}");
        // Set user name so the app navigates to home screen
        provider.setUserName(userProfile.name);
        print("User name set, should navigate to MainAppScaffold now");
      }
    } catch (e) {
      // Show error
      if (mounted) {
        print("Error saving profile: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Set Up Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to FinTrak',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Let\'s set up your financial profile',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDarkMode 
                        ? Colors.grey[400]
                        : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Name Field
                  Text(
                    'Your Name',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    style: Theme.of(context).textTheme.bodyLarge,
                    decoration: const InputDecoration(
                      hintText: 'Enter your name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Monthly Income Field
                  Text(
                    'Monthly Income',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _incomeController,
                    style: Theme.of(context).textTheme.bodyLarge,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    decoration: InputDecoration(
                      hintText: 'Enter monthly income',
                      prefixIcon: const Icon(Icons.payments_outlined),
                      prefixText: '£ ', // Adding pound sign directly
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your monthly income';
                      }
                      try {
                        double.parse(value);
                      } catch (e) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Recurring Income Date
                  Text(
                    'Recurring Income Date',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _selectIncomeDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            formattedIncomeDate,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Monthly Budget Field
                  Text(
                    'Monthly Budget',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _budgetController,
                    style: Theme.of(context).textTheme.bodyLarge,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    decoration: InputDecoration(
                      hintText: 'Enter monthly budget (defaults to 80% of income)',
                      prefixIcon: const Icon(Icons.calculate_outlined),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveUserProfile,
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                color: isDarkMode ? Colors.black : Colors.white,
                              ),
                            )
                          : const Text('Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 