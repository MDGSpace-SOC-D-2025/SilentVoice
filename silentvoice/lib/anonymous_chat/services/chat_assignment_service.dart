import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatAssignmentService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<String?> assignHelperToUser() async {
    final userId = _auth.currentUser!.uid;

    final helpersSnapshot = await _firestore
        .collection('helpers')
        .where('isOnline', isEqualTo: true)
        .get();

    final availableHelpers = <QueryDocumentSnapshot>[];

    for (final helper in helpersSnapshot.docs) {
      final activeChat = await _firestore
          .collection('chats')
          .where('helperId', isEqualTo: helper.id)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (activeChat.docs.isEmpty) {
        availableHelpers.add(helper);
      }
    }

    if (availableHelpers.isEmpty) {
      return null;
    }

    final random = Random();
    final selectedHelper =
        helpersSnapshot.docs[random.nextInt(helpersSnapshot.docs.length)];

    final helperId = selectedHelper.id;

    final chatRef = await _firestore.collection('chats').add({
      'userId': userId,
      'helperId': helperId,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'endedAt': null,
    });

    await _firestore.collection('helpers').doc(helperId).update({
      'isBusy': true,
    });

    return chatRef.id;
  }
}
