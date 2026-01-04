import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:silentvoice/evidence_vault/models/evidence_item.dart';
import 'package:silentvoice/security/aes_crypto.dart';
import 'package:silentvoice/security/app_lock_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AddEvidenceSheet extends StatelessWidget {
  final Uint8List encryptionKey;
  final void Function(EvidenceItem) onEvidenceAdded;

  const AddEvidenceSheet({
    super.key,
    required this.encryptionKey,
    required this.onEvidenceAdded,
  });
  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<File?> _captureImageFromCamera() async {
    final granted = await _requestCameraPermission();
    if (!granted) return null;

    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (picked == null) return null;

    return File(picked.path);
  }

  Future<String?> _askForNote(BuildContext context) async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;

        return AlertDialog(
          title: const Text('Add a note (optional)'),

          content: SizedBox(
            width: screenWidth * 0.90,
            child: TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Write a short description',
                border: OutlineInputBorder(),
              ),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Skip'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<File?> _pickImage(BuildContext context) async {
    return showDialog<File?>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Add Image'),
        children: [
          SimpleDialogOption(
            onPressed: () async {
              Navigator.pop(context, await _captureImageFromCamera());
            },
            child: const Text('Take Photo'),
          ),
          SimpleDialogOption(
            onPressed: () async {
              Navigator.pop(context, await _pickFileFromGallery());
            },
            child: const Text('Choose from Device'),
          ),
        ],
      ),
    );
  }

  Future<File?> _pickFileFromGallery() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result == null || result.files.single.path == null) return null;

    return File(result.files.single.path!);
  }

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

      final note = await _askForNote(context);
      final item = EvidenceItem(
        id: fileName,
        type: type == FileType.image
            ? EvidenceType.image
            : type == FileType.audio
            ? EvidenceType.audio
            : EvidenceType.video,
        encryptedPath: encryptedFile.path,
        createdAt: DateTime.now(),
        note: note == null || note.isEmpty ? null : note,
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
              onTap: () async {
                try {
                  AppLockController.allowBackground = true;

                  final file = await _pickImage(context);
                  if (file == null) return;

                  final rawBytes = await file.readAsBytes();

                  final encryptedBytes = AesCrypto.encrypt(
                    data: rawBytes,
                    key: encryptionKey,
                  );

                  final dir = await getApplicationDocumentsDirectory();
                  final fileName =
                      '${DateTime.now().millisecondsSinceEpoch}.enc';
                  final encryptedFile = File('${dir.path}/$fileName');

                  await encryptedFile.writeAsBytes(encryptedBytes);

                  final note = await _askForNote(context);

                  final item = EvidenceItem(
                    id: fileName,
                    type: EvidenceType.image,
                    encryptedPath: encryptedFile.path,
                    createdAt: DateTime.now(),
                    note: note?.isEmpty == true ? null : note,
                  );

                  onEvidenceAdded(item);

                  if (context.mounted) Navigator.pop(context);
                } finally {
                  AppLockController.allowBackground = false;
                }
              },
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
