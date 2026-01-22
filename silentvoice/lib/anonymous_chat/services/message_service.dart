import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_encryption_service.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ChatEncryptionService _encryption = ChatEncryptionService();

  Future<void> sendMessage({
    required String chatId,
    required String text,
    required String sender,
  }) async {
    final encryptedText = _encryption.encryptText(
      chatId: chatId,
      plainText: text,
    );

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
          'text': encryptedText,
          'encrypted': true,
          'sender': sender,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  Stream<QuerySnapshot> messageStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots();
  }
}
