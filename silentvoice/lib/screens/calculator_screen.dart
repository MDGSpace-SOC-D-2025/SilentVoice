import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});
  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String expression = '';
  String result = '0';
  void onButtonPressed(String value) {
    setState(() {
      if (value == 'AC') {
        expression = '';
        result = '0';
      } else if (value == '⌫') {
        if (expression.isNotEmpty) {
          expression = expression.substring(0, expression.length - 1);
        }
      } else if (value == '±') {
        toggleSign();
      } else if (value == '( )') {
        handleParentheses();
      } else {
        expression += value;
      }
    });
  }

  void handleParentheses() {
    int openCount = '('.allMatches(expression).length;
    int closeCount = ')'.allMatches(expression).length;

    if (openCount > closeCount) {
      expression += ')';
    } else {
      expression += '(';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // DISPLAY AREA
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(expression, style: TextStyle(fontSize: 22)),
                    SizedBox(height: 8),
                    Text(result, style: TextStyle(fontSize: 58)),
                  ],
                ),
              ),
            ),

            // BUTTON AREA
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
                  children: [
                    CalculatorButton(
                      label: "⌫",
                      onTap: () => onButtonPressed("⌫"),

                      backgroundColor: Color.fromARGB(255, 210, 203, 190),
                    ),
                    CalculatorButton(
                      label: "AC",
                      onTap: () => onButtonPressed("AC"),
                      backgroundColor: Color.fromARGB(255, 210, 203, 190),
                    ),
                    CalculatorButton(
                      label: "+",
                      onTap: () => onButtonPressed("+"),
                      backgroundColor: Color.fromARGB(255, 210, 203, 190),
                    ),
                    CalculatorButton(
                      label: "−",
                      onTap: () => onButtonPressed("-"),
                      backgroundColor: Color.fromARGB(255, 210, 203, 190),
                    ),

                    CalculatorButton(
                      label: "7",
                      onTap: () => onButtonPressed("7"),
                    ),
                    CalculatorButton(
                      label: "8",
                      onTap: () => onButtonPressed("8"),
                    ),
                    CalculatorButton(
                      label: "9",
                      onTap: () => onButtonPressed("9"),
                    ),
                    CalculatorButton(
                      label: "×",
                      backgroundColor: Color.fromARGB(255, 235, 177, 70),
                      onTap: () => onButtonPressed("×"),
                    ),

                    CalculatorButton(
                      label: "4",
                      onTap: () => onButtonPressed("4"),
                    ),
                    CalculatorButton(
                      label: "5",
                      onTap: () => onButtonPressed("5"),
                    ),
                    CalculatorButton(
                      label: "6",
                      onTap: () => onButtonPressed("6"),
                    ),
                    CalculatorButton(
                      label: "÷",
                      onTap: () => onButtonPressed("÷"),
                      backgroundColor: Color.fromARGB(255, 235, 177, 70),
                    ),

                    CalculatorButton(
                      label: "1",
                      onTap: () => onButtonPressed("1"),
                    ),
                    CalculatorButton(
                      label: "2",
                      onTap: () => onButtonPressed("2"),
                    ),
                    CalculatorButton(
                      label: "3",
                      onTap: () => onButtonPressed("3"),
                    ),
                    CalculatorButton(
                      label: "( )",
                      onTap: () => onButtonPressed("( )"),
                      backgroundColor: Color.fromARGB(255, 235, 177, 70),
                    ),

                    CalculatorButton(
                      label: "±",
                      onTap: () => onButtonPressed("±"),
                    ),
                    CalculatorButton(
                      label: "0",
                      onTap: () => onButtonPressed("0"),
                    ),
                    CalculatorButton(
                      label: ".",
                      onTap: () => onButtonPressed("."),
                    ),
                    CalculatorButton(
                      onTap: () => onButtonPressed("()"),
                      label: "=",
                      backgroundColor: Color.fromARGB(255, 235, 177, 70),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void toggleSign() {
    if (expression.isEmpty) return;

    int lastplus = expression.lastIndexOf('+');
    int lastminus = expression.lastIndexOf('-');
    int lastmultiply = expression.lastIndexOf('×');
    int lastDivide = expression.lastIndexOf('÷');

    int lastOperatorIndex = lastplus;
    if (lastminus > lastOperatorIndex) lastOperatorIndex = lastminus;
    if (lastmultiply > lastOperatorIndex) lastOperatorIndex = lastmultiply;
    if (lastDivide > lastOperatorIndex) lastOperatorIndex = lastDivide;

    String before = expression.substring(0, lastOperatorIndex + 1);
    String currentNumber = expression.substring(lastOperatorIndex + 1);

    if (currentNumber.startsWith('-')) {
      currentNumber = currentNumber.substring(1);
    } else {
      currentNumber = '-$currentNumber';
    }

    expression = before + currentNumber;
  }
}

class CalculatorButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final VoidCallback onTap;

  const CalculatorButton({
    super.key,
    required this.label,
    required this.onTap,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,

        child: Text(
          label,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
