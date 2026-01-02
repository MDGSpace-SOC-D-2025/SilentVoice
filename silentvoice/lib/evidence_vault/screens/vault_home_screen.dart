import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../models/evidence_item.dart';
import '../widgets/empty_vault_view.dart';
import '../widgets/evidence_tile.dart';
import 'add_evidence_sheet.dart';

class VaultHomeScreen extends StatefulWidget {
  final Uint8List encryptionKey;

  const VaultHomeScreen({super.key, required this.encryptionKey});

  @override
  State<VaultHomeScreen> createState() => _VaultHomeScreenState();
}

class _VaultHomeScreenState extends State<VaultHomeScreen> {
  late final Uint8List encryptionKey;

  @override
  void initState() {
    super.initState();
    encryptionKey = widget.encryptionKey;
  }

  @override
  Widget build(BuildContext context) {
    final List<EvidenceItem> evidenceList = [];

    return Scaffold(
      appBar: AppBar(title: const Text('Evidence Vault')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (_) => const AddEvidenceSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: evidenceList.isEmpty
          ? const EmptyVaultView()
          : ListView.builder(
              itemCount: evidenceList.length,
              itemBuilder: (context, index) {
                return EvidenceTile(item: evidenceList[index]);
              },
            ),
    );
  }
}
