import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinTrak AI Assistant'),
        leading: IconButton( // Add back button
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const Center(
        // TODO: Implement iMessage-like chat UI
        child: Padding(
           padding: EdgeInsets.all(16.0),
           child: Text(
            'Chat Screen - AI suggestions and conversation will go here!',
            textAlign: TextAlign.center,
           ),
        )
      ),
    );
  }
} 