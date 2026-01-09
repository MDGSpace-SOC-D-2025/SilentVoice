import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HelperStatusService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> setOffline() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('helpers').doc(uid).update({
      'isOnline': false,
      'isBusy': false,
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setOnline() async {
    final uid = _auth.currentUser!.uid;

    await _firestore.collection('helpers').doc(uid).update({
      'isOnline': true,
      'isBusy': false,
      'lastActive': FieldValue.serverTimestamp(),
    });
  }
}
