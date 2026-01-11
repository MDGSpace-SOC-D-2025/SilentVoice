import 'package:flutter/material.dart';
import 'package:silentvoice/emergency_sos/models/trusted_contacts.dart';
import 'package:silentvoice/emergency_sos/services/trusted_contacts_service.dart';
import 'package:silentvoice/widgets/quick_exit_appbar_action.dart';

class TrustedContactsScreen extends StatefulWidget {
  const TrustedContactsScreen({super.key});

  @override
  State<TrustedContactsScreen> createState() => _TrustedContactsScreenState();
}

class _TrustedContactsScreenState extends State<TrustedContactsScreen> {
  final _service = TrustedContactsService();
  List<TrustedContact> _contacts = [];
  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final data = await _service.loadContacts();
    setState(() => _contacts = data);
  }

  void _addContactDialog() {
    if (_contacts.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can add up to 5 trusted contacts only'),
        ),
      );
      return;
    }
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Trusted Contact'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone number'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty ||
                  phoneController.text.trim().isEmpty) {
                return;
              }
              final contact = TrustedContact(
                name: nameController.text.trim(),
                phone: phoneController.text.trim(),
              );

              await _service.addContact(contact);
              await _loadContacts();
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trusted Contacts'),
        actions: [QuickExitButton()],
      ),
      body: _contacts.isEmpty
          ? const Center(
              child: Text(
                'No trusted contacts added.\nAdd up to 5 contacts for emergencies.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: _contacts.length,
              itemBuilder: (_, i) {
                final c = _contacts[i];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(c.name),
                  subtitle: Text(c.phone),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await _service.removeContact(c);
                      await _loadContacts();
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addContactDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
