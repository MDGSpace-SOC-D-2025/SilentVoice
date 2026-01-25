import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/evidence_item.dart';
import 'evidence_repository.dart';

class CloudEvidenceRepository implements EvidenceRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  CloudEvidenceRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _evidenceCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('evidence');
  }

  @override
  Future<EvidenceItem> addEvidence({
    required EvidenceType type,
    required String encryptedFilePath,
    String? note,
    void Function(double progress)? onProgress,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User must be authenticated to add evidence');
    }

    final evidenceId = DateTime.now().millisecondsSinceEpoch.toString();

    final storagePath = 'evidence/${user.uid}/$evidenceId.enc';
    final storageRef = _storage.ref().child(storagePath);

    final uploadTask = storageRef.putFile(File(encryptedFilePath));

    uploadTask.snapshotEvents.listen((snapshot) {
      final progress = snapshot.bytesTransferred / snapshot.totalBytes;
      onProgress?.call(progress);
    });
    final snapshot = await uploadTask;
    final sizeBytes = snapshot.totalBytes;
    final downloadUrl = await storageRef.getDownloadURL();

    final item = EvidenceItem(
      id: evidenceId,
      type: type,
      storagePath: storagePath,
      downloadUrl: downloadUrl,
      createdAt: DateTime.now(),
      isEncrypted: true,
      sizeBytes: sizeBytes,
      note: note,
    );

    await _evidenceCollection(user.uid).doc(evidenceId).set(item.toJson());

    return item;
  }

  @override
  Future<List<EvidenceItem>> loadEvidence() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _evidenceCollection(
      user.uid,
    ).orderBy('createdAt', descending: true).get();

    return snapshot.docs
        .map((doc) => EvidenceItem.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<void> deleteEvidence(EvidenceItem item) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final storageRef = _storage.ref().child(item.storagePath);
    await storageRef.delete();

    await _evidenceCollection(user.uid).doc(item.id).delete();
  }
}
