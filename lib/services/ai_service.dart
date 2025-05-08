import 'dart:convert';

import 'package:fintrak/services/expense_provider.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../models/category.dart';  
import 'package:intl/intl.dart';

class AIService {
  static const String _basePrompt = '''
You are FinTrak's AI financial assistant. Your role is to provide personalized financial advice and insights based on the user's financial data. Keep responses concise, practical, and friendly. Use emojis where appropriate to make the conversation engaging.

Key guidelines:
- Focus on practical, actionable advice based on the user's actual spending data
- Be encouraging and positive while being realistic about financial situations
- Maintain a professional yet friendly tone
- Always reference their actual spending numbers when giving advice
- Provide specific, actionable steps based on their spending patterns
- Do not use markdown, bold, italics, or any other formatting, just plain text.
''';

  final String _apiKey;
  final GenerativeModel _model;

  AIService(this._apiKey)
      : _model = GenerativeModel(
          model: 'gemini-2.0-flash',
          apiKey: _apiKey,
        );

  Future<String> generateResponse(
    String userMessage,
    UserProfile profile, {
    double totalSpending = 0,
    double remainingBudget = 0,
    Map<ExpenseCategory, double> spendingByCategory = const {},
    DateTime? currentDate,
    DateTime? salaryDate,
  }) async {
    try {
      // Calculate days until next salary
      final now = currentDate ?? DateTime.now();
      final nextSalaryDate = _getNextSalaryDate(now, salaryDate ?? profile.recurringIncomeDate);
      final daysUntilSalary = nextSalaryDate.difference(now).inDays;
      
      // Calculate daily budget - TODO: Discuss removing this.
      final dailyBudget = remainingBudget / (daysUntilSalary > 0 ? daysUntilSalary : 30);
      
      // Format spending categories
      final formattedCategories = _formatSpendingCategories(spendingByCategory);
      
      // Create context for the AI
      final context = '''
        User Profile:
        - Monthly Income: £${profile.monthlyIncome}
        - Monthly Budget: £${profile.monthlyBudget}
        - Current Total Spending: £$totalSpending
        - Remaining Budget: £$remainingBudget
        - Days until next salary: $daysUntilSalary
        - Daily budget remaining: £${dailyBudget.toStringAsFixed(2)}
        
        Spending by Category:
        $formattedCategories
        
        Current Date: ${DateFormat('MMMM d, y').format(now)}
        Next Salary Date: ${DateFormat('MMMM d, y').format(nextSalaryDate)}
      ''';

      final prompt = '''
        You are a helpful financial assistant. Use the following context to provide personalized financial advice.
        Consider the time remaining until the next salary date when giving spending advice.
        If spending is too high for the remaining days, express concern and suggest immediate actions.
        
        Context:
        $context
        
        User Message: $userMessage
      ''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'I apologize, but I was unable to generate a response.';
    } catch (e) {
      print('Error generating AI response: $e');
      return 'I apologize, but I encountered an error while processing your request. Please try again later.';
    }
  }
  Future<List<Map<String, dynamic>>> getInsights() async {
  try {

    String prompt = '''
    You are a financial assistant integrated into a money tracking app. Your role is to analyze user financial data and provide personalized suggestions.

    Generate a structured JSON response with 3-5 suggestions. Each suggestion should include:
    - type: One of ["saving", "budget", "alert", "insight"]
    - title: A brief, catchy title (max 50 chars)
    - description: Detailed explanation (max 150 chars)
    - actionText: (Optional) Call-to-action text
    
    Format your entire response as a valid JSON array of suggestion objects. Do not include any explanatory text outside the JSON structure.
    
    Example response format:
    [
      {
        "type": "saving",
        "title": "Coffee savings opportunity",
        "description": "You spent £42 on coffee this month. Consider brewing at home to save up to £30.",
        "actionText": "View coffee expenses"
      },
      {
        "type": "budget",
        "title": "Grocery budget alert",
        "description": "You've used 85% of your grocery budget with 10 days remaining this month.",
        "actionText": "Adjust budget"
      }
    ]
    ''';
    
    final GenerateContentResponse response = await _model.generateContent([Content.text(prompt)]);
    GenerateContentResponse responseText = response;
    

    
    // Parse the JSON response into a List of Map objects
    List<dynamic> parsedJson = jsonDecode(responseText.toString());
    List<Map<String, dynamic>> insights = parsedJson.map((item) => 
      Map<String, dynamic>.from(item)
    ).toList();
    
    return insights;
  } catch (e) {
    print('Error generating AI response: $e');
    // Return fallback insights in case of error
    return [
      {
        "type": "budget",
        "title": "Stay on Budget",
        "description": "You're doing a great job managing your finances. Keep up the good work!",
        "actionText": "View Budget Details"
      },
      {
        "type": "insight",
        "title": "Spending Patterns",
        "description": "Consider reviewing your spending habits to identify areas where you can save money.",
        "actionText": "Analyze Categories"
      },
      {
        "type": "saving",
        "title": "Savings Opportunity",
        "description": "Consider setting aside a portion of your income for emergencies.",
        "actionText": "Set Saving Goals"
      }
    ];
  }
}

  DateTime _getNextSalaryDate(DateTime currentDate, DateTime salaryDate) {
    var nextSalaryDate = DateTime(
      currentDate.year,
      currentDate.month,
      salaryDate.day,
    );
    
    // If the salary date has already passed this month, get next month's date
    if (currentDate.isAfter(nextSalaryDate)) {
      nextSalaryDate = DateTime(
        currentDate.year,
        currentDate.month + 1,
        salaryDate.day,
      );
    }
    
    return nextSalaryDate;
  }

  String _formatSpendingCategories(Map<ExpenseCategory, double> spendingByCategory) {
    if (spendingByCategory.isEmpty) {
      return 'No spending recorded yet.';
    }

    // Sort categories by amount spent (descending)
    final sortedEntries = spendingByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries
        .where((entry) => entry.value > 0) // Only include categories with spending
        .map((entry) => '- ${entry.key.displayName}: £${entry.value.toStringAsFixed(2)}')
        .join('\n');
  }
} 


