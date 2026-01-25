import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:silentvoice/evidence_vault/models/evidence_item.dart';
import 'package:silentvoice/evidence_vault/repository/evidence_repository.dart';
import 'package:silentvoice/evidence_vault/repository/cloud_evidence_repository.dart';
import 'package:silentvoice/evidence_vault/widgets/empty_vault_view.dart';
import 'package:silentvoice/evidence_vault/widgets/evidence_tile.dart';
import 'package:silentvoice/evidence_vault/screens/add_evidence_sheet.dart';
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

  late final EvidenceRepository repository;

  @override
  void initState() {
    super.initState();
    encryptionKey = widget.encryptionKey;
    repository = CloudEvidenceRepository();
    _loadEvidence();
  }

  Future<void> _loadEvidence() async {
    final stored = await repository.loadEvidence();

    if (!mounted) return;

    setState(() {
      evidenceList
        ..clear()
        ..addAll(stored);
    });
  }

  void _onEvidenceAdded(EvidenceItem item) {
    if (!mounted) return;
    setState(() {
      evidenceList.insert(0, item);
    });
  }

  Future<void> _deleteEvidence(int index) async {
    final item = evidenceList[index];

    await repository.deleteEvidence(item);

    if (!mounted) return;

    setState(() {
      evidenceList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evidence Vault'),
        actions: const [QuickExitButton()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => AddEvidenceSheet(
              encryptionKey: encryptionKey,
              repository: repository,
              onEvidenceAdded: _onEvidenceAdded,
            ),
          );
          await _loadEvidence();
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
                  onDelete: () => _deleteEvidence(index),
                );
              },
            ),
    );
  }
}
