import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silentvoice/emergency_sos/models/trusted_contacts.dart';

class TrustedContactsService {
  static const String _key = 'trusted_contacts';

  Future<void> saveContacts(List<TrustedContact> contacts) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonList = contacts.map((c) => jsonEncode(c.toJson())).toList();

    await prefs.setStringList(_key, jsonList);
  }

  Future<List<TrustedContact>> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];

    return jsonList.map((jsonStr) {
      return TrustedContact.fromJson(jsonDecode(jsonStr));
    }).toList();
  }

  Future<void> addContact(TrustedContact contact) async {
    final contacts = await loadContacts();
    contacts.add(contact);
    await saveContacts(contacts);
  }

  Future<void> removeContact(TrustedContact contact) async {
    final contacts = await loadContacts();
    contacts.removeWhere((c) => c.phone == contact.phone);
    await saveContacts(contacts);
  }
}
