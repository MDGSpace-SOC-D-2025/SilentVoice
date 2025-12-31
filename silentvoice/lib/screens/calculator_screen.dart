import 'package:flutter/material.dart';
import 'package:silentvoice/screens/role_selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silentvoice/screens/hidden_dsahboard_screen.dart';
import 'package:silentvoice/screens/helper_dashboard_screen.dart';
import 'package:silentvoice/security/pin_hash.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});
  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String expression = '';
  String result = '0';

  bool isAppLockEnabled = false;
  String? userPinHash;
  String? userPinSalt;

  String? helperPinHash;
  String? helperPinSalt;

  @override
  void initState() {
    super.initState();
    loadAppLockStatus();
  }

  Future<void> loadAppLockStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('isAppLockEnabled') ?? false;
    final uHash = prefs.getString('user_pin_hash');
    final uSalt = prefs.getString('user_pin_salt');

    final hHash = prefs.getString('helper_pin_hash');
    final hSalt = prefs.getString('helper_pin_salt');

    if (!mounted) return;

    setState(() {
      isAppLockEnabled = enabled;

      userPinHash = uHash;
      userPinSalt = uSalt;

      helperPinHash = hHash;
      helperPinSalt = hSalt;
    });
  }

  void handleEquals() {
    if (isAppLockEnabled) {
      if (userPinHash != null && userPinSalt != null) {
        final enteredHash = hashPin(expression, userPinSalt!);
        if (enteredHash == userPinHash) {
          openUserDashboard();
          return;
        }
      }

      if (helperPinHash != null && helperPinSalt != null) {
        final enteredHash = hashPin(expression, helperPinSalt!);
        if (enteredHash == helperPinHash) {
          openHelperDashboard();
          return;
        }
      }
    }
    calculateResult();
  }

  void openUserDashboard() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HiddenDashboardScreen()),
      (route) => false,
    );
  }

  void openHelperDashboard() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HelperDashboardScreen()),
      (route) => false,
    );
  }

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
      } else if (isOperator(value)) {
        handleOperator(value);
      } else if (value == '=') {
        handleEquals();
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

  void handleOperator(String op) {
    if (expression.isEmpty) {
      if (op == '-') {
        expression = '-';
      }
      return;
    }

    String lastChar = expression[expression.length - 1];

    if (isOperator(lastChar)) {
      expression = expression.substring(0, expression.length - 1) + op;
    } else if (lastChar == '(') {
      return;
    } else {
      expression += op;
    }
  }

  bool isOperator(String ch) {
    return ch == '+' || ch == '-' || ch == '×' || ch == '÷';
  }

  void calculateResult() {
    if (expression.isEmpty) return;

    try {
      String exp = expression;

      exp = exp.replaceAll('×', '*');
      exp = exp.replaceAll('÷', '/');

      double eval = _evaluateExpression(exp);
      result = eval.toString();
    } catch (e) {
      result = 'Error';
    }
  }

  double _evaluateExpression(String exp) {

    List<double> numbers = [];
    List<String> operators = [];
    int i = 0;

    while (i < exp.length) {
      if (isDigit(exp[i]) ||
          exp[i] == '-' && (i == 0 || isOperator(exp[i - 1]))) {
        int start = i;
        i++;
        while (i < exp.length && (isDigit(exp[i]) || exp[i] == '.')) {
          i++;
        }
        numbers.add(double.parse(exp.substring(start, i)));
      } else {
        operators.add(exp[i]);
        i++;
      }
    }

    for (int i = 0; i < operators.length; i++) {
      if (operators[i] == '*' || operators[i] == '/') {
        double a = numbers[i];
        double b = numbers[i + 1];
        double res = operators[i] == '*' ? a * b : a / b;

        numbers[i] = res;
        numbers.removeAt(i + 1);
        operators.removeAt(i);
        i--;
      }
    }

    double finalResult = numbers[0];
    for (int i = 0; i < operators.length; i++) {
      if (operators[i] == '+') {
        finalResult += numbers[i + 1];
      } else {
        finalResult -= numbers[i + 1];
      }
    }

    return finalResult;
  }

  bool isDigit(String ch) {
    return ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(expression, style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 8),
                        Text(result, style: const TextStyle(fontSize: 58)),
                      ],
                    ),
                  ),
                ),

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
                          backgroundColor: const Color.fromARGB(
                            255,
                            210,
                            203,
                            190,
                          ),
                        ),
                        CalculatorButton(
                          label: "AC",
                          onTap: () => onButtonPressed("AC"),
                          backgroundColor: const Color.fromARGB(
                            255,
                            210,
                            203,
                            190,
                          ),
                        ),
                        CalculatorButton(
                          label: "+",
                          onTap: () => onButtonPressed("+"),
                          backgroundColor: const Color.fromARGB(
                            255,
                            210,
                            203,
                            190,
                          ),
                        ),
                        CalculatorButton(
                          label: "−",
                          onTap: () => onButtonPressed("-"),
                          backgroundColor: const Color.fromARGB(
                            255,
                            210,
                            203,
                            190,
                          ),
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
                          onTap: () => onButtonPressed("×"),
                          backgroundColor: const Color.fromARGB(
                            255,
                            235,
                            177,
                            70,
                          ),
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
                          backgroundColor: const Color.fromARGB(
                            255,
                            235,
                            177,
                            70,
                          ),
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
                          backgroundColor: const Color.fromARGB(
                            255,
                            235,
                            177,
                            70,
                          ),
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
                          label: "=",
                          onTap: () => onButtonPressed("="),
                          backgroundColor: const Color.fromARGB(
                            255,
                            235,
                            177,
                            70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (!isAppLockEnabled)
              Positioned(
                top: 10,
                left: 10,
                child: PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.grey,
                    size: 22,
                  ),
                  onSelected: (value) {
                    if (value == 'lock') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RoleSelectionScreen(),
                        ),
                      );
                    }
                  },

                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'lock',
                      child: Text('Enable App Lock'),
                    ),
                    PopupMenuItem(value: 'clear', child: Text('Clear History')),
                    PopupMenuItem(value: 'about', child: Text('About')),
                  ],
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
