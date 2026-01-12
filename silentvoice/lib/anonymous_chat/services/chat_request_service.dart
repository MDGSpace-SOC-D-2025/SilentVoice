import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> takeNextUser() async {
    final helperId = FirebaseAuth.instance.currentUser!.uid;

    final requestSnapshot = await _firestore
        .collection('chat_requests')
        .where('status', isEqualTo: 'waiting')
        .orderBy('createdAt')
        .limit(1)
        .get();

    if (requestSnapshot.docs.isEmpty) {
      return null;
    }

    final requestDoc = requestSnapshot.docs.first;
    final userId = requestDoc['userId'];

    final chatRef = await _firestore.collection('chats').add({
      'userId': userId,
      'helperId': helperId,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'endedAt': null,
    });

    await requestDoc.reference.update({'status': 'assigned'});

    return chatRef.id;
  }
}
