import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:silentvoice/anonymous_chat/services/message_service.dart';
import 'package:silentvoice/anonymous_chat/services/chat_encryption_service.dart';

class UserChatScreen extends StatefulWidget {
  const UserChatScreen({super.key});

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen>
    with WidgetsBindingObserver {
  final MessageService _messageService = MessageService();
  final ChatEncryptionService _encryption = ChatEncryptionService();
  final TextEditingController _controller = TextEditingController();

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  Stream<QuerySnapshot> activeChatStream() {
    return FirebaseFirestore.instance
        .collection('chats')
        .where('userId', isEqualTo: uid)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .snapshots();
  }

  Stream<QuerySnapshot> requestStream() {
    return FirebaseFirestore.instance
        .collection('chat_requests')
        .where('userId', isEqualTo: uid)
        .where('status', isEqualTo: 'waiting')
        .limit(1)
        .snapshots();
  }

  Future<void> _cancelWaitingRequest() async {
    final snap = await FirebaseFirestore.instance
        .collection('chat_requests')
        .where('userId', isEqualTo: uid)
        .where('status', isEqualTo: 'waiting')
        .limit(1)
        .get();

    if (snap.docs.isNotEmpty) {
      await snap.docs.first.reference.update({
        'status': 'cancelled',
        'lastSeen': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _cancelWaitingRequest();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: activeChatStream(),
      builder: (context, chatSnapshot) {
        if (chatSnapshot.hasData && chatSnapshot.data!.docs.isNotEmpty) {
          final chatId = chatSnapshot.data!.docs.first.id;
          return _buildChatUI(chatId);
        }

        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) await _cancelWaitingRequest();
          },
          child: StreamBuilder<QuerySnapshot>(
            stream: requestStream(),
            builder: (context, requestSnapshot) {
              if (requestSnapshot.hasData &&
                  requestSnapshot.data!.docs.isNotEmpty) {
                return const Scaffold(
                  body: Center(
                    child: Text(
                      'A helper will connect with you shortly...',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                );
              }

              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Chat ended.', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Start New Chat'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildChatUI(String chatId) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          await FirebaseFirestore.instance
              .collection('chats')
              .doc(chatId)
              .update({
                'status': 'closed',
                'endedAt': FieldValue.serverTimestamp(),
                'endedBy': 'user',
              });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Anonymous Chat'),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: _messageService.messageStream(chatId),
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
                      final isUser = data['sender'] == 'user';
                      final isEncrypted = data['encrypted'] == true;

                      final text = isEncrypted
                          ? _encryption.decryptText(
                              chatId: chatId,
                              cipherText: data['text'],
                            )
                          : data['text'];

                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Colors.green[200]
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
                        chatId: chatId,
                        text: plainText,
                        sender: 'user',
                      );

                      _controller.clear();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
