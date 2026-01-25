enum EvidenceType { image, audio, video }

class EvidenceItem {
  final String id;
  final EvidenceType type;
  final String? note;

  final String storagePath;

  final String? downloadUrl;

  final DateTime createdAt;
  final bool isEncrypted;
  final int? sizeBytes;

  EvidenceItem({
    required this.id,
    required this.type,
    required this.storagePath,
    required this.createdAt,
    required this.isEncrypted,
    this.downloadUrl,
    this.note,
    this.sizeBytes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'storagePath': storagePath,
      'downloadUrl': downloadUrl,
      'createdAt': createdAt.toIso8601String(),
      'isEncrypted': isEncrypted,
      'sizeBytes': sizeBytes,
      'note': note,
    };
  }

  factory EvidenceItem.fromJson(Map<String, dynamic> json) {
    return EvidenceItem(
      id: json['id'] as String,
      type: EvidenceType.values.firstWhere((e) => e.name == json['type']),
      storagePath: json['storagePath'] as String,
      downloadUrl: json['downloadUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt']),
      isEncrypted: json['isEncrypted'] as bool,
      sizeBytes: json['sizeBytes'] as int?,
      note: json['note'] as String?,
    );
  }
}
