import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'message_bubble.dart'; // Import the MessageBubble widget

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // Listen to the stream of messages
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: false)
          .snapshots(),
      builder: (ctx, AsyncSnapshot<QuerySnapshot> chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return const Center(child: Text('No messages found.'));
        }

        final loadedMessages = chatSnapshots.data!.docs;
        String previousUserId = '';

        return ListView.builder(
          itemCount: loadedMessages.length,
          itemBuilder: (ctx, index) {
            final messageData =
                loadedMessages[index].data() as Map<String, dynamic>;
            final bool isMe =
                messageData['userId'] == FirebaseAuth.instance.currentUser?.uid;
            final bool isFirstInSequence =
                previousUserId != messageData['userId'];
            previousUserId = messageData['userId'];

            return isFirstInSequence
                ? MessageBubble.first(
                    message: messageData['text'],
                    username: messageData['username'],
                    userImage: messageData['userImage'],
                    isMe: isMe,
                  )
                : MessageBubble.next(
                    message: messageData['text'],
                    isMe: isMe,
                  );
          },
        );
      },
    );
  }
}
