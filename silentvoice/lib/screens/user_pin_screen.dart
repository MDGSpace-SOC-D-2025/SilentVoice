import 'package:flutter/material.dart';

class UserPinScreen extends StatefulWidget {
  const UserPinScreen({super.key});
  @override
  State<UserPinScreen> createState() => _UserPinScreenState();
}

class _UserPinScreenState extends State<UserPinScreen> {
  String pin = '';
  String confirmPin = '';

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
              'ⓘ Used to protect app settings\nⓘ If you forget this PIN, data cannot be recovered',
              style: TextStyle(
                fontSize: 13,
                color: Color.fromARGB(255, 134, 133, 133),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isValid ? () {} : null,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
