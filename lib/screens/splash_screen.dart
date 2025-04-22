import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For input formatters
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../services/expense_provider.dart';
import '../screens/main_app_scaffold.dart';

// Note: This file acts as the initial user info screen for onboarding
class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _incomeController = TextEditingController();

  // --- State Variables ---
  String? _selectedGoal;
  bool _isSubmitting = false;
  
  // Only using goal options now
  final List<String> _goalOptions = [
    'Save for a down payment',
    'Build an emergency fund',
    'Pay off debt',
    'Save for travel',
    'Invest for retirement',
    'General savings'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Set loading state
      setState(() {
        _isSubmitting = true;
      });
      
      try {
        // Form is valid, create the UserProfile
        final userProfile = UserProfile(
          name: _nameController.text.trim(),
          monthlyIncome: double.tryParse(_incomeController.text) ?? 0.0,
          currency: 'EGP', // Always EGP now
          recurringIncomeDate: DateTime.now(), // Using current date
          monthlyBudget: (double.tryParse(_incomeController.text) ?? 0.0) * 0.8, // Default to 80% of income
          savingGoal: _selectedGoal!,   // Validation ensures this is not null
        );

        print("Splash screen: Saving user profile");
        // Save the profile using provider
        final provider = Provider.of<ExpenseProvider>(context, listen: false);
        final success = await provider.saveUserProfile(userProfile);
        
        if (success) {
          if (mounted) {
            print("Splash screen: Profile saved successfully, navigating to MainAppScaffold");
            // Navigate to MainAppScaffold instead of HomeScreen
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MainAppScaffold()),
            );
          }
        } else {
          if (mounted) {
            print("Splash screen: Failed to save profile: ${provider.error}");
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(provider.error ?? 'Failed to save profile'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          print("Splash screen: Error: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        // Reset loading state if still mounted
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to FinTrak!'),
        automaticallyImplyLeading: false, // No back button on initial screen
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Let\'s get started!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text(
                'Please tell us a bit about yourself to personalize your experience.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // --- Name Field ---
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Your Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                 textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- Monthly Income Field ---
              TextFormField(
                controller: _incomeController,
                decoration: const InputDecoration(
                  labelText: 'Monthly Income',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your monthly income';
                  }
                  final income = double.tryParse(value);
                  if (income == null) {
                    return 'Please enter a valid number';
                  }
                  if (income <= 0) {
                     return 'Income must be positive';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- Saving Goal Dropdown ---
              DropdownButtonFormField<String>(
                value: _selectedGoal,
                isExpanded: true, // Allow long goal text to wrap if needed
                hint: const Text('Primary Saving Goal'),
                 decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.flag_outlined),
                  contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                ),
                items: _goalOptions.map((String goal) {
                  return DropdownMenuItem<String>(
                    value: goal,
                    child: Text(goal, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGoal = newValue!;
                  });
                },
                 validator: (value) => value == null ? 'Please select a goal' : null,
              ),
              const SizedBox(height: 40),

              // --- Submit Button ---
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Get Started',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 