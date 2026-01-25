import 'package:flutter/material.dart';
import 'package:silentvoice/emergency_sos/screens/trusted_contacts_screen.dart';
import 'package:silentvoice/widgets/quick_exit_appbar_action.dart';
import 'package:silentvoice/fake_call/fake_call_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [QuickExitButton()],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.contacts),
            title: const Text('Trusted Contacts (SOS)'),
            subtitle: const Text('Manage emergency SMS contacts'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TrustedContactsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.call),
            title: const Text('Fake Incoming Call'),
            subtitle: const Text('Configure emergency fake call'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FakeCallSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
