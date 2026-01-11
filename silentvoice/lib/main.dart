import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:silentvoice/firebase_options.dart';
import 'package:silentvoice/auth/auth_service.dart';
import 'package:silentvoice/security/app_lifecycle_handler.dart';
import 'screens/calculator_screen.dart';
import 'navigation/root_navigator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final AuthService authService = AuthService();
  if (authService.currentUser == null) {
    await authService.signInAnonymously();
  }

  AppLifecycleHandler().start();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      debugShowCheckedModeBanner: false,
      title: "SilentVoice",
      home: const CalculatorScreen(),
      routes: {'/calculator': (_) => const CalculatorScreen()},
    );
  }
}
