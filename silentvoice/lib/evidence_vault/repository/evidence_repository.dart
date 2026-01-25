import '../models/evidence_item.dart';

abstract class EvidenceRepository {
  Future<EvidenceItem> addEvidence({
    required EvidenceType type,
    required String encryptedFilePath,
    String? note,
    void Function(double progress)? onProgress,
  });

  Future<List<EvidenceItem>> loadEvidence();

  Future<void> deleteEvidence(EvidenceItem item);
}
