import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:silentvoice/evidence_vault/models/evidence_item.dart';
import 'package:silentvoice/evidence_vault/screens/evidence_viewer_screen.dart';

class EvidenceTile extends StatelessWidget {
  final EvidenceItem item;
  final Uint8List encryptionKey;
  final VoidCallback onDelete;

  const EvidenceTile({
    super.key,
    required this.item,
    required this.encryptionKey,
    required this.onDelete,
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
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.createdAt.toString()),
          if (item.note != null && item.note!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              item.note!,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                EvidenceViewerScreen(item: item, encryptionKey: encryptionKey),
          ),
        );
      },

      onLongPress: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete Evidence'),
            content: const Text(
              'This will permanently delete the evidence. This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );

        if (confirm == true) {
          onDelete();
        }
      },
    );
  }
}
