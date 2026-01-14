import 'package:cloud_firestore/cloud_firestore.dart';

class ChatLifecycleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> endChat(String chatId) async {
    await _firestore.collection('chats').doc(chatId).update({
      'status': 'closed',
      'endedAt': FieldValue.serverTimestamp(),
    });
  }
}
