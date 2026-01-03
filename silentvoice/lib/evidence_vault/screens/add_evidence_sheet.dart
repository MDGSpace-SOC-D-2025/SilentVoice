import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:silentvoice/evidence_vault/models/evidence_item.dart';
import 'package:silentvoice/security/aes_crypto.dart';
import 'package:silentvoice/security/app_lock_controller.dart';

class AddEvidenceSheet extends StatelessWidget {
  final Uint8List encryptionKey;
  final void Function(EvidenceItem) onEvidenceAdded;

  const AddEvidenceSheet({
    super.key,
    required this.encryptionKey,
    required this.onEvidenceAdded,
  });

  Future<void> _pickFile(BuildContext context, FileType type) async {
    try {
      AppLockController.allowBackground = true;

      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowMultiple: false,
      );

      if (result == null || result.files.single.path == null) return;

      final pickedFile = File(result.files.single.path!);

      final rawBytes = await pickedFile.readAsBytes();

      final encryptedBytes = AesCrypto.encrypt(
        data: rawBytes,
        key: encryptionKey,
      );

      final dir = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.enc';
      final encryptedFile = File('${dir.path}/$fileName');

      await encryptedFile.writeAsBytes(encryptedBytes);

      final item = EvidenceItem(
        id: fileName,
        type: type == FileType.image
            ? EvidenceType.image
            : type == FileType.audio
            ? EvidenceType.audio
            : EvidenceType.video,
        encryptedPath: encryptedFile.path,
        createdAt: DateTime.now(),
      );

      onEvidenceAdded(item);

      if (context.mounted) {
        Navigator.pop(context);
      }
    } finally {
      AppLockController.allowBackground = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add Evidence',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Add Image'),
              onTap: () => _pickFile(context, FileType.image),
            ),

            ListTile(
              leading: const Icon(Icons.mic),
              title: const Text('Add Audio'),
              onTap: () => _pickFile(context, FileType.audio),
            ),

            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Add Video'),
              onTap: () => _pickFile(context, FileType.video),
            ),
          ],
        ),
      ),
    );
  }
}
