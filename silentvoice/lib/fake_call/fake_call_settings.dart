import 'package:flutter/material.dart';

class FakeCallSettingsScreen extends StatelessWidget {
  const FakeCallSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fake Incoming Call')),
      body: const Center(
        child: Text(
          'Fake Call Settings (coming soon)',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
