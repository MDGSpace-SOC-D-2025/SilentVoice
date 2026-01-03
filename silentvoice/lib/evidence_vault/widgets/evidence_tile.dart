import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:silentvoice/evidence_vault/models/evidence_item.dart';
import 'package:silentvoice/evidence_vault/screens/evidence_viewer_screen.dart';

class EvidenceTile extends StatelessWidget {
  final EvidenceItem item;
  final Uint8List encryptionKey;

  const EvidenceTile({
    super.key,
    required this.item,
    required this.encryptionKey,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        item.type == EvidenceType.image
            ? Icons.image
            : item.type == EvidenceType.audio
            ? Icons.mic
            : Icons.videocam,
      ),
      title: Text(item.type.name.toUpperCase()),
      subtitle: Text(item.createdAt.toString()),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                EvidenceViewerScreen(item: item, encryptionKey: encryptionKey),
          ),
        );
      },
    );
  }
}
