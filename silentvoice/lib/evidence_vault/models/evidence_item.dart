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
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'encryptedPath': encryptedPath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory EvidenceItem.fromJson(Map<String, dynamic> json) {
    return EvidenceItem(
      id: json['id'] as String,
      type: EvidenceType.values.firstWhere((e) => e.name == json['type']),
      encryptedPath: json['encryptedPath'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
