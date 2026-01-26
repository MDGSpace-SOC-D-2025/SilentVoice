import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:silentvoice/anonymous_chat/screens/user_chat_screen.dart';
import 'package:silentvoice/widgets/quick_exit_appbar_action.dart';

class StartChatScreen extends StatelessWidget {
  const StartChatScreen({super.key});

  Future<int?> _selectRetentionDays(BuildContext context) {
    return showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Auto-delete chat after'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('24 hours'),
                onTap: () => Navigator.pop(context, 1),
              ),
              ListTile(
                title: const Text('7 days'),
                onTap: () => Navigator.pop(context, 7),
              ),
              ListTile(
                title: const Text('30 days'),
                onTap: () => Navigator.pop(context, 30),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anonymous Chat'),
        actions: [QuickExitButton()],
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Start Chat'),
          onPressed: () async {
            final retentionDays = await _selectRetentionDays(context);
            if (retentionDays == null) return;

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
                'retentionDays': retentionDays,
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
