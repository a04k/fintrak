import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http; // new import
import '../models/user_profile.dart';
import '../models/category.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';

class AIService {
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

  // New method using base64 with HTTP POST to call Gemini Vision API
  Future<double?> extractReceiptTotal(String imagePath) async {
    try {
      // Read image file and encode to base64
      final bytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(bytes);
      print("Image encoded: Length = ${base64Image.length}");

      final prompt = '''
        Extract only the total/final amount from this receipt image. 
        Return ONLY the numerical value with up to 2 decimal places.
        Example response: "25.99"
        Do not include any currency symbols or text.
      ''';
      print("Prompt: $prompt");

      // Build the JSON payload per Gemini API specifications
      final requestBody = {
        "contents": [
          {
            "parts": [
              {
                "inlineData": {
                  "mimeType": "image/jpeg",
                  "data": base64Image
                }
              },
              {"text": prompt}
            ]
          }
        ]
      };
      final requestJson = jsonEncode(requestBody);
      print("Request JSON: $requestJson");

      // Construct URL with API key
      final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_apiKey');
      print("Request URL: $url");

      final httpResponse = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: requestJson,
      );

      print("HTTP status: ${httpResponse.statusCode}");
      print("HTTP body: ${httpResponse.body}");

      if (httpResponse.statusCode == 200) {
        final decoded = jsonDecode(httpResponse.body);
        print("Decoded response: $decoded");
        // Adjust extraction based on the actual response structure:
        final responseText = decoded["candidates"]?[0]?["content"] as String? ?? '';
        print("Extracted response text: $responseText");
        final amount = double.tryParse(responseText.trim());
        print("Parsed amount: $amount");
        return amount;
      }
      print("Non-200 HTTP response");
      return null;
    } catch (e, stackTrace) {
      print("Error in extractReceiptTotal: $e");
      print(stackTrace);
      return null;
    }
  }
  
  // New method that accepts a base64 string (for web environments)
  Future<double?> extractReceiptTotalFromBase64(String base64Image) async {
    try {
      final prompt = '''
        Extract only the total/final amount from this receipt image. 
        Return ONLY the numerical value with up to 2 decimal places.
        Example response: "25.99"
        Do not include any currency symbols or text.
      ''';

      final requestBody = {
        "contents": [
          {
            "parts": [
              {
                "inlineData": {
                  "mimeType": "image/jpeg",
                  "data": base64Image
                }
              },
              {"text": prompt}
            ]
          }
        ]
      };

      final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_apiKey');

      final httpResponse = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (httpResponse.statusCode == 200) {
        final decoded = jsonDecode(httpResponse.body);
        final responseText = decoded["candidates"]?[0]?["content"] as String? ?? '';
        return double.tryParse(responseText.trim());
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}