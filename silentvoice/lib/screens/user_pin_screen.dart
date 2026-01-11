import 'package:flutter/material.dart';
import 'package:silentvoice/screens/calculator_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silentvoice/security/pin_hash.dart';

enum PinRole { user, helper }

class UserPinScreen extends StatefulWidget {
  final PinRole role;
  const UserPinScreen({super.key, required this.role});

  @override
  State<UserPinScreen> createState() => _UserPinScreenState();
}

class _UserPinScreenState extends State<UserPinScreen> {
  String pin = '';
  String confirmPin = '';
  Future<void> onSavePressed() async {
    final prefs = await SharedPreferences.getInstance();

    final salt = DateTime.now().millisecondsSinceEpoch.toString();
    final pinHash = hashPin(pin, salt);

    await prefs.setBool('isAppLockEnabled', true);

    if (widget.role == PinRole.user) {
      await prefs.setString('user_pin_hash', pinHash);
      await prefs.setString('user_pin_salt', salt);
    } else {
      await prefs.setString('helper_pin_hash', pinHash);
      await prefs.setString('helper_pin_salt', salt);
      await prefs.setBool('isHelperSetupComplete', true);
    }

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const CalculatorScreen()),
      (route) => false,
    );
  }

  bool get isValid {
    return pin.length >= 4 && pin == confirmPin;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            const Text(
              'Set PIN',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            TextField(
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              onChanged: (value) {
                setState(() => pin = value);
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 16),

            const Text(
              'Confirm PIN',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            TextField(
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              onChanged: (value) {
                setState(() => confirmPin = value);
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 16),

            const Text(
              'ⓘ If you forget this PIN, data cannot be recovered',
              style: TextStyle(
                fontSize: 13,
                color: Color.fromARGB(255, 108, 108, 108),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isValid ? onSavePressed : null,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
