import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:silentvoice/firebase_options.dart';
import 'screens/calculator_screen.dart';
import 'package:silentvoice/auth/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final AuthService authService = AuthService();

  final user = await authService.signInAnonymously();

  if (user == null) {
    debugPrint("Anonymous login failed");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "SilentVoice",

      home: const CalculatorScreen(),
    );
  }
}
