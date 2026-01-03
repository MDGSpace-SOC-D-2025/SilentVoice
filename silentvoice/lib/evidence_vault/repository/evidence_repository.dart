import '../models/evidence_item.dart';

abstract class EvidenceRepository {
  Future<List<EvidenceItem>> loadEvidence();
  Future<void> saveEvidence(List<EvidenceItem> items);
}
