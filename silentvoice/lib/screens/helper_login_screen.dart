import 'package:flutter/material.dart';
import 'package:silentvoice/screens/user_pin_screen.dart';
import 'package:silentvoice/auth/auth_service.dart';

class HelperLoginScreen extends StatefulWidget {
  const HelperLoginScreen({super.key});

  @override
  State<HelperLoginScreen> createState() => _HelperLoginScreenState();
}

class _HelperLoginScreenState extends State<HelperLoginScreen> {
  String email = '';
  String password = '';
  bool isLoading = false;
  String? errorMessage;
  final AuthService _authService = AuthService();

  bool get isValid {
    return email.isNotEmpty && password.isNotEmpty;
  }

  Future<void> _handleLogin() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final user = await _authService.signInHelperWithEmail(
      email.trim(),
      password,
    );

    setState(() {
      isLoading = false;
    });

    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => UserPinScreen(role: PinRole.helper)),
      );
    } else {
      setState(() {
        errorMessage = 'Invalid Email or Password';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
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
              'Authorized helpers can log in to assist users.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 24),

            TextField(
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                setState(() {
                  email = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              obscureText: true,
              onChanged: (value) {
                setState(() {
                  password = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Enter password',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isValid && !isLoading ? _handleLogin : null,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Login'),
              ),
            ),

            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
