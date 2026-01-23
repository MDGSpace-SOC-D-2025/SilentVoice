import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:silentvoice/anonymous_chat/screens/helper_dashboard_screen.dart';
import 'package:silentvoice/anonymous_chat/services/chat_lifecycle_service.dart';
import 'package:silentvoice/anonymous_chat/services/chat_encryption_service.dart';
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
  final ChatEncryptionService _encryption = ChatEncryptionService();

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
      setState(() => _chatId = snapshot.docs.first.id);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToDashboard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HelperDashboardScreen()),
      );
    });
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

        final chatDoc = snapshot.data!;

        if (!chatDoc.exists) {
          _goToDashboard();
          return const Scaffold(
            body: Center(child: Text('Chat deleted by user')),
          );
        }

        final chatData = chatDoc.data() as Map<String, dynamic>;

        if (chatData['status'] != 'active') {
          _goToDashboard();
          return const Scaffold(body: Center(child: Text('Chat ended')));
        }

        final expiresAt = (chatData['expiresAt'] as Timestamp).toDate();

        if (DateTime.now().isAfter(expiresAt)) {
          _goToDashboard();
          return const Scaffold(body: Center(child: Text('Chat expired')));
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
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _messageService.messageStream(_chatId!),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final messages = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final data =
                            messages[index].data() as Map<String, dynamic>;
                        final isHelper = data['sender'] == 'helper';

                        final text = _encryption.decryptText(
                          chatId: _chatId!,
                          cipherText: data['text'],
                        );

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
                            child: Text(text),
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
                        final plainText = _controller.text.trim();
                        if (plainText.isEmpty) return;

                        await _messageService.sendMessage(
                          chatId: _chatId!,
                          text: plainText,
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
