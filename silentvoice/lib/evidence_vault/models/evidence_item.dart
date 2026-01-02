enum EvidenceType { image, audio, video }

class EvidenceItem {
  final String id;
  final EvidenceType type;
  final DateTime createdAt;
  final String encryptedPath;

  EvidenceItem({
    required this.id,
    required this.type,
    required this.createdAt,
    required this.encryptedPath,
  });
}
