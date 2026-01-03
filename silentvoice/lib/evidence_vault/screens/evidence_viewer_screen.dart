import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

import 'package:silentvoice/widgets/quick_exit_appbar_action.dart';
import 'package:silentvoice/evidence_vault/models/evidence_item.dart';
import 'package:silentvoice/security/aes_crypto.dart';

class EvidenceViewerScreen extends StatefulWidget {
  final EvidenceItem item;
  final Uint8List encryptionKey;

  const EvidenceViewerScreen({
    super.key,
    required this.item,
    required this.encryptionKey,
  });

  @override
  State<EvidenceViewerScreen> createState() => _EvidenceViewerScreenState();
}

class _EvidenceViewerScreenState extends State<EvidenceViewerScreen> {
  Uint8List? decryptedBytes;
  bool isLoading = true;
  String? error;

  AudioPlayer? _audioPlayer;
  File? _tempAudioFile;

  @override
  void initState() {
    super.initState();
    _loadAndDecrypt();
  }

  Future<void> _loadAndDecrypt() async {
    try {
      final file = File(widget.item.encryptedPath);
      final encryptedBytes = await file.readAsBytes();

      final decrypted = AesCrypto.decrypt(
        encryptedData: encryptedBytes,
        key: widget.encryptionKey,
      );

      if (!mounted) return;

      if (widget.item.type == EvidenceType.audio) {
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/${widget.item.id}');

        await tempFile.writeAsBytes(decrypted);

        _tempAudioFile = tempFile;
        _audioPlayer = AudioPlayer();
        await _audioPlayer!.setReleaseMode(ReleaseMode.stop);
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          decryptedBytes = decrypted;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Failed to open evidence';
        isLoading = false;
      });
    }
  }

  Future<void> _playAudio() async {
    if (_audioPlayer == null || _tempAudioFile == null) return;

    await _audioPlayer!.setVolume(1.0);

    await _audioPlayer!.play(
      DeviceFileSource(_tempAudioFile!.path),
      volume: 1.0,
    );
  }

  Future<void> _stopAudio() async {
    await _audioPlayer?.stop();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Evidence')),
        body: Center(child: Text(error!)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evidence'),
        actions: [QuickExitButton()],
      ),
      body: _buildViewer(),
    );
  }

  Widget _buildViewer() {
    switch (widget.item.type) {
      case EvidenceType.image:
        return Image.memory(decryptedBytes!);

      case EvidenceType.audio:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.audiotrack, size: 64),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _playAudio,
                child: const Text('Play Audio'),
              ),
              ElevatedButton(
                onPressed: _stopAudio,
                child: const Text('Stop Audio'),
              ),
            ],
          ),
        );

      case EvidenceType.video:
        return const Center(child: Text('Video playback comes next'));
    }
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();

    if (_tempAudioFile != null && _tempAudioFile!.existsSync()) {
      _tempAudioFile!.deleteSync();
    }

    super.dispose();
  }
}
