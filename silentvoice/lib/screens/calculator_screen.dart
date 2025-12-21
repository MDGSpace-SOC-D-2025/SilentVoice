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
                    CalculatorButton(
                      label: "⌫",
                      backgroundColor: Color.fromARGB(255, 210, 203, 190),
                    ),
                    CalculatorButton(
                      label: "AC",
                      backgroundColor: Color.fromARGB(255, 210, 203, 190),
                    ),

                    CalculatorButton(
                      label: "+",
                      backgroundColor: Color.fromARGB(255, 210, 203, 190),
                    ),
                    CalculatorButton(
                      label: "−",
                      backgroundColor: Color.fromARGB(255, 210, 203, 190),
                    ),

                    CalculatorButton(label: "7"),
                    CalculatorButton(label: "8"),
                    CalculatorButton(label: "9"),
                    CalculatorButton(
                      label: "×",
                      backgroundColor: Color.fromARGB(255, 235, 177, 70),
                    ),

                    CalculatorButton(label: "4"),
                    CalculatorButton(label: "5"),
                    CalculatorButton(label: "6"),
                    CalculatorButton(
                      label: "÷",
                      backgroundColor: Color.fromARGB(255, 235, 177, 70),
                    ),

                    CalculatorButton(label: "1"),
                    CalculatorButton(label: "2"),
                    CalculatorButton(label: "3"),
                    CalculatorButton(
                      label: "( )",
                      backgroundColor: Color.fromARGB(255, 235, 177, 70),
                    ),

                    CalculatorButton(label: "±"),
                    CalculatorButton(label: "0"),
                    CalculatorButton(label: "."),
                    CalculatorButton(
                      label: "=",
                      backgroundColor: Color.fromARGB(255, 235, 177, 70),
                    ),
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

class CalculatorButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;

  const CalculatorButton({
    super.key,
    required this.label,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      alignment: Alignment.center,

      child: Text(
        label,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      ),
    );
  }
}
