import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:silentvoice/anonymous_chat/screens/helper_dashboard_screen.dart';
import 'package:silentvoice/anonymous_chat/services/chat_lifecycle_service.dart';
import 'package:silentvoice/anonymous_chat/services/message_service.dart';

class HelperChatScreen extends StatefulWidget {
  const HelperChatScreen({super.key});

  @override
  State<HelperChatScreen> createState() => _HelperChatScreenState();
}

class _HelperChatScreenState extends State<HelperChatScreen> {
  String? _chatId;
  final TextEditingController _controller = TextEditingController();
  final MessageService _messageService = MessageService();
  final ChatLifecycleService _lifecycleService = ChatLifecycleService();

  @override
  void initState() {
    super.initState();
    _loadActiveChat();
  }

  Future<void> _loadActiveChat() async {
    final helperId = FirebaseAuth.instance.currentUser!.uid;

    final snapshot = await FirebaseFirestore.instance
        .collection('chats')
        .where('helperId', isEqualTo: helperId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty && mounted) {
      setState(() {
        _chatId = snapshot.docs.first.id;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chatId == null) {
      return const Scaffold(body: Center(child: Text('No active chat')));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(_chatId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final status = data['status'];
        final endedBy = data['endedBy'];

        if (status == 'closed') {
          final message = endedBy == 'user'
              ? 'The user is no longer present.'
              : 'Chat ended.';

          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HelperDashboardScreen()),
            );
          });

          return Scaffold(
            body: Center(
              child: Text(
                message,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Active Chat'),
            automaticallyImplyLeading: false,
            actions: [
              TextButton(
                onPressed: () async {
                  await _lifecycleService.endChat(
                    chatId: _chatId!,
                    endedBy: 'helper',
                  );
                },
                child: const Text(
                  'End Chat',
                  style: TextStyle(color: Color.fromARGB(255, 243, 3, 3)),
                ),
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
                        final msg = messages[index];
                        final isHelper = msg['sender'] == 'helper';

                        return Align(
                          alignment: isHelper
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isHelper
                                  ? Colors.blue[200]
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(msg['text']),
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
                        final text = _controller.text.trim();
                        if (text.isEmpty) return;

                        await _messageService.sendMessage(
                          chatId: _chatId!,
                          text: text,
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
      },
    );
  }
}
