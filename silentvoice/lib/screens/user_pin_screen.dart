import 'package:flutter/material.dart';
import 'package:silentvoice/screens/calculator_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    // Mark app lock as enabled
    await prefs.setBool('isAppLockEnabled', true);
    if (widget.role == PinRole.user) {
      await prefs.setString('userPin', pin); // TEMP
    } else {
      await prefs.setString('helperPin', pin);
      await prefs.setBool('isHelperSetupComplete', true);
    }
    // SAFETY CHECK
    if (!mounted) return;

    // Go back to calculator
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
                color: Color.fromARGB(255, 134, 133, 133),
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
