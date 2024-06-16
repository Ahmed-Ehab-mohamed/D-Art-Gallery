import 'package:flutter/material.dart';
import 'chat_messages.dart'; // Custom widget for displaying messages
import 'new_chat.dart'; // Custom widget for sending messages
// ignore: unused_import
import 'message_bubble.dart'; // Import MessageBubble widget

class ChatScreen extends StatelessWidget {
  final Map<String, dynamic>? userData; // Expect user data to be passed

  const ChatScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlutterChat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatMessages(), // Display list of messages
          ),
          NewMessage(userData: userData), // Pass user data to NewMessage
        ],
      ),
    );
  }
}
