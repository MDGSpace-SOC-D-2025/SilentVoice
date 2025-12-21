import 'package:flutter/material.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 DISPLAY AREA
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text("5 - 9"),
                    SizedBox(height: 8),
                    Text("-4", style: TextStyle(fontSize: 40)),
                  ],
                ),
              ),
            ),

            // 🔹 BUTTON AREA (empty placeholder for now)
            Expanded(
              flex: 7,
              child: Container(
                width: double.infinity,
                color: const Color.fromARGB(255, 231, 229, 229),
                padding: const EdgeInsets.all(12),
                child: GridView.count(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: const [
                    Text("⌫"),
                    Text("AC"),
                    Text("+"),
                    Text("-"),

                    Text("7"),
                    Text("8"),
                    Text("9"),
                    Text("×"),

                    Text("4"),
                    Text("5"),
                    Text("6"),
                    Text("÷"),

                    Text("1"),
                    Text("2"),
                    Text("3"),
                    Text(""),

                    Text("±"),
                    Text("0"),
                    Text("."),
                    Text("="),
                  ],

                  // buttons will go here
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
