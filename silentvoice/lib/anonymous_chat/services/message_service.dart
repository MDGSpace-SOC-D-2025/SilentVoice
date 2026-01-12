import 'package:cloud_firestore/cloud_firestore.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> messageStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots();
  }

  Future<void> sendMessage({
    required String chatId,
    required String text,
    required String sender,
  }) async {
    await _firestore.collection('chats').doc(chatId).collection('messages').add(
      {
        'text': text,
        'sender': sender,
        'createdAt': FieldValue.serverTimestamp(),
      },
    );
  }
}
