import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:silentvoice/anonymous_chat/services/message_service.dart';
import 'package:silentvoice/anonymous_chat/services/chat_lifecycle_service.dart';

class HelperChatScreen extends StatefulWidget {
  const HelperChatScreen({super.key});

  @override
  State<HelperChatScreen> createState() => _HelperChatScreenState();
}

class _HelperChatScreenState extends State<HelperChatScreen> {
  String? _chatId;
  final TextEditingController _controller = TextEditingController();
  final MessageService _messageService = MessageService();

  @override
  void initState() {
    super.initState();
    _loadActiveChat();
  }

  Future<void> _loadActiveChat() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final snapshot = await FirebaseFirestore.instance
        .collection('chats')
        .where('helperId', isEqualTo: uid)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _chatId = snapshot.docs.first.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_chatId == null) {
      return const Scaffold(body: Center(child: Text('No active chat')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              await ChatLifecycleService().endChat(
                chatId: _chatId!,
                helperId: FirebaseAuth.instance.currentUser!.uid,
              );
              if (mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _messageService.messageStream(_chatId!),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index];
                    final isHelper = data['sender'] == 'helper';

                    return Align(
                      alignment: isHelper
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isHelper ? Colors.blue[200] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(data['text']),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    if (_controller.text.trim().isEmpty) return;

                    await _messageService.sendMessage(
                      chatId: _chatId!,
                      text: _controller.text.trim(),
                      sender: 'helper',
                    );

                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
