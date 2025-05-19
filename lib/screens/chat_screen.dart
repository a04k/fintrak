import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/expense_provider.dart';
import '../services/ai_service.dart';
import '../config/api_config.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  late final AIService _aiService;

  @override
  void initState() {
    super.initState();
    _aiService = AIService(APIConfig.geminiApiKey);
    _sendInitialMessage();
  }

  void _sendInitialMessage() {
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    final userName = expenseProvider.userProfile?.name ?? "there";
    
    _addBotMessage(
      "Hi $userName! 👋 I'm your FinTrak AI assistant. I can help you with:\n"
      "• Analyzing your spending patterns\n"
      "• Providing budget recommendations\n"
      "• Offering savings tips\n"
      "• Answering financial questions\n\n"
      "What would you like to know about?"
    );
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    _addUserMessage(text);
    _messageController.clear();
    setState(() => _isTyping = true);
    _generateAIResponse(text);
  }

  Future<void> _generateAIResponse(String userMessage) async {
    try {
      final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
      final profile = expenseProvider.userProfile;
      
      if (profile == null) {
        throw Exception('User profile not found');
      }

      final response = await _aiService.generateResponse(
        userMessage,
        profile,
        totalSpending: expenseProvider.totalSpending,
        remainingBudget: expenseProvider.remainingBudget,
        spendingByCategory: expenseProvider.spendingByCategory,
      );

      if (mounted) {
        setState(() {
          _isTyping = false;
          _addBotMessage(response);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _addBotMessage(
            "I apologize, but I'm having trouble accessing your financial data right now. "
            "Please make sure your profile is set up correctly and try again."
          );
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final inputBgColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[200];
    final hintColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];
    final borderColor = isDarkMode ? Colors.grey[800] : Colors.grey[300];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'WiseWallet Assistant',
          style: TextStyle(color: textColor),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _messages[index];
              },
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: LoadingDots(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border(
                top: BorderSide(
                  color: borderColor!,
                  width: 0.5,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Ask about your finances...',
                      hintStyle: TextStyle(color: hintColor),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 10.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: inputBgColor,
                    ),
                    onSubmitted: _handleSubmitted,
                  ),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(Icons.send, color: textColor),
                  onPressed: () => _handleSubmitted(_messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });


// === CHAT BUBBLE ===

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final userBubbleColor = isDarkMode ? Colors.blue : Theme.of(context).colorScheme.primary;
    final botBubbleColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[300];
    final userTextColor = Colors.white;
    final botTextColor = isDarkMode ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: userBubbleColor,
              child: const Icon(Icons.assistant, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: isUser ? userBubbleColor : botBubbleColor,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isUser ? userTextColor : botTextColor,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class LoadingDots extends StatefulWidget {
  const LoadingDots({super.key});

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _numDots = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..addListener(() {
        setState(() {
          _numDots = (_controller.value * 3).floor() + 1;
        });
      });

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('.' * _numDots, style: const TextStyle(fontSize: 20)),
      ],
    );
  }
} 