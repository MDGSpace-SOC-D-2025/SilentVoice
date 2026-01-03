import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:silentvoice/security/key_derivation.dart';
import 'package:silentvoice/evidence_vault/screens/vault_home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silentvoice/security/pin_hash.dart';
import 'package:silentvoice/widgets/quick_exit_appbar_action.dart';

class VaultLockScreen extends StatefulWidget {
  const VaultLockScreen({super.key});

  @override
  State<VaultLockScreen> createState() => _VaultLockScreenState();
}

class _VaultLockScreenState extends State<VaultLockScreen> {
  final TextEditingController _pinController = TextEditingController();
  String? errorText;
  String? userPinHash;
  String? userPinSalt;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadPinData();
  }

  Future<void> _loadPinData() async {
    final prefs = await SharedPreferences.getInstance();

    final hash = prefs.getString('user_pin_hash');
    final salt = prefs.getString('user_pin_salt');

    if (!mounted) return;

    setState(() {
      userPinHash = hash;
      userPinSalt = salt;
      isLoading = false;
    });
  }

  void _verifyPin() {
    if (userPinHash == null || userPinSalt == null) {
      setState(() {
        errorText = 'Vault not set up';
      });
      return;
    }

    final enteredPin = _pinController.text.trim();
    if (enteredPin.isEmpty) {
      setState(() {
        errorText = 'Please enter PIN';
      });
      return;
    }

    final enteredHash = hashPin(enteredPin, userPinSalt!);

    if (enteredHash == userPinHash) {
      final saltBytes = Uint8List.fromList(userPinSalt!.codeUnits);

      final encryptionKey = deriveKeyFromPin(pin: enteredPin, salt: saltBytes);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VaultHomeScreen(encryptionKey: encryptionKey),
        ),
      );
    } else {
      setState(() {
        errorText = 'Incorrect PIN';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unlock Evidence Vault'),
        actions: [QuickExitButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 64),
            const SizedBox(height: 24),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: 'Enter PIN',
                errorText: errorText,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _verifyPin, child: const Text('Unlock')),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }
}
