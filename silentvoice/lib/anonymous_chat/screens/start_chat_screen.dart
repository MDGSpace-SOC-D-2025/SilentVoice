import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:silentvoice/anonymous_chat/screens/user_chat_screen.dart';

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
            final userId = FirebaseAuth.instance.currentUser!.uid;

            final existing = await FirebaseFirestore.instance
                .collection('chat_requests')
                .where('userId', isEqualTo: userId)
                .where('status', isEqualTo: 'waiting')
                .limit(1)
                .get();

            if (existing.docs.isEmpty) {
              await FirebaseFirestore.instance.collection('chat_requests').add({
                'userId': userId,
                'status': 'waiting',
                'createdAt': FieldValue.serverTimestamp(),
              });
            }

            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UserChatScreen()),
            );
          },
        ),
      ),
    );
  }
}
