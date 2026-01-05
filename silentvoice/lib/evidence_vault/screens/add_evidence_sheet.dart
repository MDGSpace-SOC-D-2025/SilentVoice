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
import 'package:record/record.dart';

class AddEvidenceSheet extends StatefulWidget {
  final Uint8List encryptionKey;
  final void Function(EvidenceItem) onEvidenceAdded;

  const AddEvidenceSheet({
    super.key,
    required this.encryptionKey,
    required this.onEvidenceAdded,
  });

  @override
  State<AddEvidenceSheet> createState() => _AddEvidenceSheetState();
}

class _AddEvidenceSheetState extends State<AddEvidenceSheet> {
  final AudioRecorder _recorder = AudioRecorder();

  Future<void> _saveEncryptedEvidence({
    required File sourceFile,
    required EvidenceType type,
  }) async {
    final rawBytes = await sourceFile.readAsBytes();

    final encryptedBytes = AesCrypto.encrypt(
      data: rawBytes,
      key: widget.encryptionKey,
    );

    final dir = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.enc';
    final encryptedFile = File('${dir.path}/$fileName');

    await encryptedFile.writeAsBytes(encryptedBytes);

    final note = await _askForNote(context);

    final item = EvidenceItem(
      id: fileName,
      type: type,
      encryptedPath: encryptedFile.path,
      createdAt: DateTime.now(),
      note: note?.isEmpty == true ? null : note,
    );

    widget.onEvidenceAdded(item);
  }

  Future<File?> _captureImage() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) return null;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    return picked == null ? null : File(picked.path);
  }

  Future<File?> _pickImage() async {
    return showDialog<File?>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Add Image'),
        children: [
          SimpleDialogOption(
            child: const Text('Take Photo'),
            onPressed: () async {
              Navigator.pop(context, await _captureImage());
            },
          ),
          SimpleDialogOption(
            child: const Text('Choose from Device'),
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.image,
              );
              Navigator.pop(
                context,
                result?.files.single.path == null
                    ? null
                    : File(result!.files.single.path!),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<File?> _recordAudio() async {
    final tempDir = await getTemporaryDirectory();
    final path =
        '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

    bool isRecording = false;

    return showDialog<File?>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (_, setState) {
            return AlertDialog(
              title: const Text('Record Audio'),
              content: Icon(
                isRecording ? Icons.mic : Icons.mic_none,
                size: 64,
                color: isRecording ? Colors.red : Colors.grey,
              ),
              actions: [
                TextButton(
                  onPressed: isRecording
                      ? null
                      : () async {
                          if (!await _recorder.hasPermission()) return;
                          await _recorder.start(
                            const RecordConfig(),
                            path: path,
                          );
                          setState(() => isRecording = true);
                        },
                  child: const Text('Start'),
                ),
                TextButton(
                  onPressed: !isRecording
                      ? null
                      : () async {
                          await _recorder.stop();
                          Navigator.pop(dialogContext, File(path));
                        },
                  child: const Text('Stop'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<File?> _chooseAudioSource(BuildContext context) async {
    return showDialog<File?>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Add Audio'),
        children: [
          SimpleDialogOption(
            onPressed: () async {
              Navigator.pop(context, await _recordAudio());
            },
            child: const Text('Record Audio'),
          ),
          SimpleDialogOption(
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.audio,
                allowMultiple: false,
              );
              Navigator.pop(
                context,
                result?.files.single.path == null
                    ? null
                    : File(result!.files.single.path!),
              );
            },
            child: const Text('Pick Audio File'),
          ),
        ],
      ),
    );
  }

  Future<String?> _askForNote(BuildContext context) async {
    final controller = TextEditingController();
    final width = MediaQuery.of(context).size.width;

    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add a note (optional)'),
        content: SizedBox(
          width: width * 0.9,
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
      ),
    );
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
                  final file = await _pickImage();
                  if (file == null) return;

                  await _saveEncryptedEvidence(
                    sourceFile: file,
                    type: EvidenceType.image,
                  );

                  if (context.mounted) Navigator.pop(context);
                } finally {
                  AppLockController.allowBackground = false;
                }
              },
            ),

            ListTile(
              leading: const Icon(Icons.mic),
              title: const Text('Add Audio'),
              onTap: () async {
                try {
                  AppLockController.allowBackground = true;

                  final file = await _chooseAudioSource(context);
                  if (file == null) return;

                  await _saveEncryptedEvidence(
                    sourceFile: file,
                    type: EvidenceType.audio,
                  );

                  if (await file.exists()) {
                    await file.delete();
                  }

                  if (context.mounted) Navigator.pop(context);
                } finally {
                  AppLockController.allowBackground = false;
                }
              },
            ),

            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Add Video'),
              onTap: () async {
                try {
                  AppLockController.allowBackground = true;

                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.video,
                  );
                  if (result?.files.single.path == null) return;

                  await _saveEncryptedEvidence(
                    sourceFile: File(result!.files.single.path!),
                    type: EvidenceType.video,
                  );

                  if (context.mounted) Navigator.pop(context);
                } finally {
                  AppLockController.allowBackground = false;
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }
}
