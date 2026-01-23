import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> takeNextUser() async {
    final helperId = FirebaseAuth.instance.currentUser!.uid;

    final snapshot = await _firestore
        .collection('chat_requests')
        .where('status', isEqualTo: 'waiting')
        .orderBy('createdAt')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final requestDoc = snapshot.docs.first;
    final data = requestDoc.data();
    final userId = data['userId'];

    final lastSeen = (data['lastSeen'] as Timestamp?)?.toDate();
    if (lastSeen != null &&
        DateTime.now().difference(lastSeen).inSeconds > 15) {
      await requestDoc.reference.update({'status': 'expired'});
      return null;
    }
    final retentionDays = data['retentionDays'] ?? 7;
    final DateTime now = DateTime.now();
    final DateTime expiresAt = now.add(Duration(days: retentionDays));
    final chatRef = await _firestore.collection('chats').add({
      'userId': userId,
      'helperId': helperId,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'endedAt': null,
      'endedBy': null,

      'retentionDays': retentionDays,
      'expiresAt': Timestamp.fromDate(expiresAt),
    });

    await requestDoc.reference.update({'status': 'assigned'});
    await _firestore.collection('helpers').doc(helperId).update({
      'isBusy': true,
    });

    return chatRef.id;
  }
}
