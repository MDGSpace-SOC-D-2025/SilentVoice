import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:silentvoice/evidence_vault/models/evidence_item.dart';
import 'package:silentvoice/evidence_vault/repository/evidence_repository.dart';
import 'package:silentvoice/evidence_vault/repository/local_evidence_repository.dart';
import 'package:silentvoice/evidence_vault/widgets/empty_vault_view.dart';
import 'package:silentvoice/evidence_vault/widgets/evidence_tile.dart';
import 'package:silentvoice/evidence_vault/SCREENS/add_evidence_sheet.dart';
import 'package:silentvoice/widgets/quick_exit_appbar_action.dart';

class VaultHomeScreen extends StatefulWidget {
  final Uint8List encryptionKey;

  const VaultHomeScreen({super.key, required this.encryptionKey});

  @override
  State<VaultHomeScreen> createState() => _VaultHomeScreenState();
}

class _VaultHomeScreenState extends State<VaultHomeScreen> {
  late final Uint8List encryptionKey;
  final List<EvidenceItem> evidenceList = [];

  final EvidenceRepository repository = LocalEvidenceRepository();

  @override
  void initState() {
    super.initState();
    encryptionKey = widget.encryptionKey;
    _loadEvidence();
  }

  Future<void> _loadEvidence() async {
    final stored = await repository.loadEvidence();

    if (!mounted) return;

    setState(() {
      evidenceList.clear();
      evidenceList.addAll(stored);
    });
  }

  Future<void> _addEvidence(EvidenceItem item) async {
    setState(() {
      evidenceList.add(item);
    });

    await repository.saveEvidence(evidenceList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evidence Vault'),
        actions: [QuickExitButton()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (_) => AddEvidenceSheet(
              encryptionKey: encryptionKey,
              onEvidenceAdded: _addEvidence,
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: evidenceList.isEmpty
          ? const EmptyVaultView()
          : ListView.builder(
              itemCount: evidenceList.length,
              itemBuilder: (context, index) {
                return EvidenceTile(
                  item: evidenceList[index],
                  encryptionKey: encryptionKey,
                  onDelete: () async {
                    final item = evidenceList[index];

                    // 1️⃣ Delete encrypted file
                    final file = File(item.encryptedPath);
                    if (await file.exists()) {
                      await file.delete();
                    }

                    // 2️⃣ Remove metadata from list
                    setState(() {
                      evidenceList.removeAt(index);
                    });

                    // 3️⃣ Persist updated metadata
                    await repository.saveEvidence(evidenceList);
                  },
                );
              },
            ),
    );
  }
}
