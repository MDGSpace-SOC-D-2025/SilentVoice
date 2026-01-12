import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:silentvoice/anonymous_chat/services/chat_assignment_service.dart';

class StartChatScreen extends StatelessWidget {
  const StartChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anonymous Chat')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Start Chat'),
          onPressed: () async {
            final chatId = await ChatAssignmentService().assignHelperToUser();
            if (chatId == null) {
              final userId = FirebaseAuth.instance.currentUser!.uid;

              final existingRequest = await FirebaseFirestore.instance
                  .collection('chat_requests')
                  .where('userId', isEqualTo: userId)
                  .where('status', isEqualTo: 'waiting')
                  .limit(1)
                  .get();

              if (existingRequest.docs.isEmpty) {
                await FirebaseFirestore.instance
                    .collection('chat_requests')
                    .add({
                      'userId': userId,
                      'status': 'waiting',
                      'createdAt': FieldValue.serverTimestamp(),
                    });
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('A helper will connect with you shortly'),
                ),
              );
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Chat created: $chatId')));
            }
          },
        ),
      ),
    );
  }
}
