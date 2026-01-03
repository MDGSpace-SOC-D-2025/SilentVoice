import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/evidence_item.dart';
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

  @override
  void initState() {
    super.initState();
    _loadAndDecrypt();
  }

  Future<void> _loadAndDecrypt() async {
    try {
      final file = File(widget.item.encryptedPath);
      final encryptedBytes = await file.readAsBytes();

      final bytes = AesCrypto.decrypt(
        encryptedData: encryptedBytes,
        key: widget.encryptionKey,
      );

      if (!mounted) return;

      setState(() {
        decryptedBytes = bytes;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to open evidence';
        isLoading = false;
      });
    }
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
      appBar: AppBar(title: const Text('Evidence')),
      body: _buildViewer(),
    );
  }

  Widget _buildViewer() {
    switch (widget.item.type) {
      case EvidenceType.image:
        return Image.memory(decryptedBytes!);

      case EvidenceType.audio:
        return const Center(child: Text('Audio playback comes next'));

      case EvidenceType.video:
        return const Center(child: Text('Video playback comes next'));
    }
  }
}
