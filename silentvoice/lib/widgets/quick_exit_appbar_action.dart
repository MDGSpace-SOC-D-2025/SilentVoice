import 'package:flutter/material.dart';
import 'package:silentvoice/screens/calculator_screen.dart';

class QuickExitButton extends StatelessWidget {
  const QuickExitButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Exit',
      icon: const Icon(Icons.calculate_outlined),
      onPressed: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const CalculatorScreen()),
          (route) => false,
        );
      },
    );
  }
}
