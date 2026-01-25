import 'package:flutter/material.dart';
import 'package:silentvoice/fake_call/fake_call_prefs.dart';

class FakeCallSettingsScreen extends StatefulWidget {
  const FakeCallSettingsScreen({super.key});

  @override
  State<FakeCallSettingsScreen> createState() => _FakeCallSettingsScreenState();
}

class _FakeCallSettingsScreenState extends State<FakeCallSettingsScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCallerName();
  }

  Future<void> _loadCallerName() async {
    final name = await FakeCallPrefs.getCallerName();
    final number = await FakeCallPrefs.getCallerNumber();

    _controller.text = name;
    _numberController.text = number;

    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final name = _controller.text.trim();
    final number = _numberController.text.trim();

    if (name.isEmpty) return;

    await FakeCallPrefs.setCallerName(name);
    await FakeCallPrefs.setCallerNumber(number.isEmpty ? 'Unknown' : number);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Fake call details saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fake Call Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Caller Name',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Mom, Boss, Unknown',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Phone Number',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _numberController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: 'e.g. +91 98XXXXXXX',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _save,
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
