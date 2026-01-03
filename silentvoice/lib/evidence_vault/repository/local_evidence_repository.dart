import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/evidence_item.dart';
import 'evidence_repository.dart';

class LocalEvidenceRepository implements EvidenceRepository {
  static const _storageKey = 'evidence_metadata';

  @override
  Future<List<EvidenceItem>> loadEvidence() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null) return [];

    final List decoded = jsonDecode(jsonString);

    return decoded
        .map((e) => EvidenceItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveEvidence(List<EvidenceItem> items) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonList = items.map((e) => e.toJson()).toList();
    final jsonString = jsonEncode(jsonList);

    await prefs.setString(_storageKey, jsonString);
  }
}
