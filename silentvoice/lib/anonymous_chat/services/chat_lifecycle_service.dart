import 'package:cloud_firestore/cloud_firestore.dart';

class ChatLifecycleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> endChat({
    required String chatId,
    required String endedBy,
  }) async {
    final chatRef = _firestore.collection('chats').doc(chatId);
    final chatSnap = await chatRef.get();

    if (!chatSnap.exists) return;

    final helperId = chatSnap['helperId'];

    final batch = _firestore.batch();

    batch.update(chatRef, {
      'status': 'closed',
      'endedAt': FieldValue.serverTimestamp(),
      'endedBy': endedBy,
    });

    batch.update(_firestore.collection('helpers').doc(helperId), {
      'isBusy': false,
    });

    await batch.commit();
  }
}
