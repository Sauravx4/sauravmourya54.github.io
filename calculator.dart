import 'package:flutter/material.dart';

// The main application widget for the calculator.
class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hide the debug banner
      title: 'Calculator', // Application title
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ), // Define the primary theme color
      home: const CalculatorScreen(), // Set CalculatorScreen as the home widget
    );
  }
}

// The stateful widget for the calculator screen.
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

// The state for the CalculatorScreen.
class _CalculatorScreenState extends State<CalculatorScreen> {
  String _output = "0"; // The text displayed as the current result or input
  String _expression = ""; // The internal expression string being built
  bool _evaluated =
      false; // Flag to indicate if the last operation was an evaluation (=)

  // Handles button presses from the calculator UI.
  void _buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        // Clear all: reset output, expression, and evaluation flag
        _output = "0";
        _expression = "";
        _evaluated = false;
      } else if (buttonText == "=") {
        // Evaluate the expression
        try {
          if (_expression.isNotEmpty) {
            // Remove any trailing operators before evaluation for a more forgiving input
            // Ensure _expression is not modified while iterating with RegExp if not needed,
            // but this loop structure is fine for progressive trimming.
            String currentExprForTrim = _expression;
            while (currentExprForTrim.isNotEmpty &&
                RegExp(r'[+\-*/×÷]$').hasMatch(currentExprForTrim)) {
              currentExprForTrim = currentExprForTrim.substring(
                0,
                currentExprForTrim.length - 1,
              );
            }
            _expression =
                currentExprForTrim; // Update _expression after trimming

            if (_expression.isEmpty) {
              // If only operators were trimmed, reset to "0"
              _output = "0";
              _expression = "";
            } else {
              // Evaluate the expression and update output/expression
              _output = _evaluateExpression(_expression);
              _expression = _output; // Store result for chained operations
            }
            _evaluated = true; // Mark as evaluated
          }
        } catch (e) {
          // Catch any errors during evaluation and display "Error"
          _output = "Error";
          _expression = ""; // Clear expression on error
          _evaluated = true;
        }
      } else {
        // Handle number and operator button presses
        if (_evaluated) {
          // If the last action was an evaluation (after pressing '=')
          if (double.tryParse(buttonText) != null || buttonText == '.') {
            // If a number or decimal is pressed, start a new expression
            _expression = buttonText;
            _output = buttonText;
            _evaluated = false;
          } else {
            // If an operator is pressed, continue with the previous result
            _expression += buttonText;
            _output = _expression;
            _evaluated = false;
          }
        } else {
          // Building the current expression (not after '=')
          // Prevent multiple leading zeros for non-decimal numbers (e.g., "05" becomes "5")
          if (_expression == "0" &&
              buttonText != "." &&
              double.tryParse(buttonText) != null) {
            _expression = buttonText;
          }
          // Handle decimal point input
          else if (buttonText == '.') {
            // Check if the current number segment already contains a decimal point
            final RegExpMatch? lastNumberMatch = RegExp(
              r'(\d*\.?\d*)$',
            ).firstMatch(_expression);
            // Ensure lastNumber is always a non-null string.
            // Explicitly handling possible null match or group value,
            // though Dart's null-aware operators already provide this.
            final String lastNumber = (lastNumberMatch?.group(0) ?? '');

            if (lastNumber.contains('.')) {
              return; // Do nothing if decimal already exists in the current number
            }
            // If expression is empty or ends with an operator, prepend "0" (e.g., ".5" becomes "0.5")
            if (_expression.isEmpty ||
                RegExp(r'[+\-*/×÷]$').hasMatch(_expression)) {
              _expression += "0.";
            } else {
              _expression += buttonText; // Append decimal to the current number
            }
          }
          // Handle operator input
          else if (RegExp(r'[+\-*/×÷]').hasMatch(buttonText)) {
            // If expression is empty, allow only '-' for unary minus at the start
            if (_expression.isEmpty) {
              if (buttonText == '-') {
                _expression += buttonText;
              } else {
                return; // Prevent starting with other operators
              }
            }
            // If the last character in the expression is an operator
            else if (RegExp(r'[+\-*/×÷]$').hasMatch(_expression)) {
              // _expression is guaranteed non-empty here by the hasMatch check
              final String lastOperator = _expression.substring(
                _expression.length - 1,
              );
              // Allow "5*-" or "5/-" to signify negative number
              if ((lastOperator == '*' || lastOperator == '/') &&
                  buttonText == '-') {
                _expression += buttonText;
              }
              // If the last operator is '-' and a non-minus operator is pressed (e.g., "5-+")
              else if (lastOperator == '-' &&
                  (buttonText == '+' ||
                      buttonText == '×' ||
                      buttonText == '÷')) {
                _expression =
                    _expression.substring(0, _expression.length - 1) +
                    buttonText; // Replace '-' with new operator
              }
              // If the new operator is the same as the last (e.g., "5++" or "5--"), just replace it with itself
              else if (lastOperator == buttonText) {
                _expression =
                    _expression.substring(0, _expression.length - 1) +
                    buttonText;
              }
              // For other consecutive operators (e.g., "5*+"), replace the last operator
              else {
                _expression =
                    _expression.substring(0, _expression.length - 1) +
                    buttonText;
              }
            }
            // Otherwise, simply append the operator
            else {
              _expression += buttonText;
            }
          }
          // Handle number input (any digit)
          else {
            _expression += buttonText;
          }
          _output = _expression; // Update the displayed output
        }
      }
    });
  }

  // Evaluates the given arithmetic expression string.
  String _evaluateExpression(String expr) {
    // Replace custom UI operators with standard ones for internal calculation
    String processedExpr = expr.replaceAll('×', '*');
    processedExpr = processedExpr.replaceAll('÷', '/');

    try {
      // Perform the actual calculation respecting operator precedence
      final double result = _calculate(processedExpr);
      // Format the result to avoid ".0" for integer results
      if (result == result.toInt()) {
        return result.toInt().toString();
      }
      return result.toString();
    } catch (e) {
      // Provide specific error messages for common calculation issues
      if (e is FormatException) {
        return "Syntax Error";
      } else if (e is ArgumentError && e.message == "Division by zero") {
        return "Div by Zero";
      }
      return "Error"; // Generic error for unexpected issues
    }
  }

  // Core calculation logic that handles operator precedence.
  double _calculate(String expression) {
    // Step 1: Tokenize the expression into a list of numbers (doubles) and operators (strings)
    final RegExp tokenRegex = RegExp(
      r'(\d+\.?\d*)|([+\-*/])',
    ); // Matches numbers (int/float) or operators
    List<dynamic> tokens = <dynamic>[];
    for (final RegExpMatch match in tokenRegex.allMatches(expression)) {
      final String? value = match.group(0);
      if (value != null) {
        if (double.tryParse(value) != null) {
          tokens.add(double.parse(value));
        } else {
          tokens.add(value); // It's an operator
        }
      }
    }

    // Step 1.5: Handle unary minus (e.g., -5, 2*-5).
    List<dynamic> processedTokens = <dynamic>[];
    for (int i = 0; i < tokens.length; i++) {
      // Check for unary minus: '-' at the start or immediately after an operator
      if (tokens[i] == '-' && (i == 0 || (tokens[i - 1] is String))) {
        if (i + 1 < tokens.length && tokens[i + 1] is double) {
          processedTokens.add(
            -(tokens[i + 1] as double),
          ); // Apply the minus to the number
          i++; // Skip the next token as it has been processed with the minus
        } else {
          // Unary minus without a subsequent number is a syntax error
          throw const FormatException(
            "Syntax Error: Unary minus not followed by a number.",
          );
        }
      } else {
        processedTokens.add(tokens[i]); // Add other tokens as-is
      }
    }
    tokens = processedTokens; // Update tokens with unary minus handled

    // Step 2: First pass - handle multiplication and division (higher precedence)
    List<dynamic> temp = <dynamic>[];
    for (int i = 0; i < tokens.length; i++) {
      if (tokens[i] == '*') {
        // Ensure there's a left operand and a right operand
        if (temp.isEmpty || !(temp.last is double)) {
          throw const FormatException(
            "Syntax Error: Missing left operand for multiplication.",
          );
        }
        final double left = temp.removeLast() as double; // Get left operand
        if (i + 1 >= tokens.length || !(tokens[i + 1] is double)) {
          throw const FormatException(
            "Syntax Error: Missing right operand for multiplication.",
          );
        }
        final double right =
            tokens[++i] as double; // Get right operand and advance index
        temp.add(left * right); // Perform multiplication
      } else if (tokens[i] == '/') {
        // Ensure there's a left operand and a right operand
        if (temp.isEmpty || !(temp.last is double)) {
          throw const FormatException(
            "Syntax Error: Missing left operand for division.",
          );
        }
        final double left = temp.removeLast() as double; // Get left operand
        if (i + 1 >= tokens.length || !(tokens[i + 1] is double)) {
          throw const FormatException(
            "Syntax Error: Missing right operand for division.",
          );
        }
        final double right =
            tokens[++i] as double; // Get right operand and advance index
        if (right == 0) {
          throw ArgumentError("Division by zero"); // Handle division by zero
        }
        temp.add(left / right); // Perform division
      } else {
        temp.add(tokens[i]); // Add numbers and other operators to temp list
      }
    }
    tokens = temp; // Update tokens list after first pass

    // Step 3: Second pass - handle addition and subtraction (lower precedence)
    if (tokens.isEmpty) return 0.0; // Return 0 if expression became empty
    if (tokens.length == 1 && tokens[0] is double)
      return tokens[0] as double; // If only one number, it's the result

    // Validate the structure for the final pass (should be number, operator, number, ...)
    for (int i = 0; i < tokens.length; i++) {
      if (i % 2 == 0 && !(tokens[i] is double)) {
        // Even indices must be numbers
        throw FormatException(
          "Syntax Error: Expected number but found operator at position ${i + 1}.",
        );
      } else if (i % 2 != 0 && !(tokens[i] is String)) {
        // Odd indices must be operators
        throw FormatException(
          "Syntax Error: Expected operator but found number at position ${i + 1}.",
        );
      }
    }
    if (tokens.length % 2 == 0) {
      // Should not end with an operator
      throw const FormatException(
        "Syntax Error: Invalid expression ending with an operator.",
      );
    }

    double result = tokens[0] as double; // Start with the first number
    for (int i = 1; i < tokens.length - 1; i += 2) {
      final String operator = tokens[i] as String;
      final double nextNumber = tokens[i + 1] as double;

      if (operator == '+') {
        result += nextNumber;
      } else if (operator == '-') {
        result -= nextNumber;
      } else {
        // This case indicates an internal logic error if multiplication/division are fully handled
        throw FormatException(
          "Internal Error: Unexpected operator '$operator' during final evaluation.",
        );
      }
    }

    return result;
  }

  // Helper widget to build individual calculator buttons.
  Widget _buildButton(String text, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(
          4.0,
        ), // Add padding for visual spacing between buttons
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.all(24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                8,
              ), // Rounded corners for buttons
            ),
            minimumSize: const Size(
              60,
              60,
            ), // Ensure buttons have a minimum touch target size
          ),
          onPressed: () =>
              _buttonPressed(text), // Hook up the button press handler
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
            ), // Button text style
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Dark background for the calculator
      body: Column(
        children: [
          // Display area for the expression/output
          Expanded(
            child: Container(
              alignment:
                  Alignment.bottomRight, // Align text to the bottom right
              padding: const EdgeInsets.all(
                24,
              ), // Padding around the display text
              child: FittedBox(
                // Use FittedBox to prevent text overflow for long results
                fit: BoxFit.scaleDown,
                child: Text(
                  _output,
                  style: const TextStyle(
                    fontSize: 48, // Max font size for the output
                    color: Colors.white,
                  ),
                  maxLines: 1, // Ensure the output is a single line
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ),
          // Button layout section
          Column(
            children: [
              // First row of buttons
              Row(
                children: [
                  _buildButton("7", Colors.grey[800]!),
                  _buildButton("8", Colors.grey[800]!),
                  _buildButton("9", Colors.grey[800]!),
                  _buildButton("÷", Colors.orange),
                ],
              ),
              // Second row of buttons
              Row(
                children: [
                  _buildButton("4", Colors.grey[800]!),
                  _buildButton("5", Colors.grey[800]!),
                  _buildButton("6", Colors.grey[800]!),
                  _buildButton("×", Colors.orange),
                ],
              ),
              // Third row of buttons
              Row(
                children: [
                  _buildButton("1", Colors.grey[800]!),
                  _buildButton("2", Colors.grey[800]!),
                  _buildButton("3", Colors.grey[800]!),
                  _buildButton("-", Colors.orange),
                ],
              ),
              // Fourth row of buttons (includes decimal point)
              Row(
                children: [
                  _buildButton("C", Colors.red),
                  _buildButton("0", Colors.grey[800]!),
                  _buildButton(".", Colors.grey[800]!), // Decimal point button
                  _buildButton("=", Colors.green),
                  _buildButton("+", Colors.orange),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// The main function, which is the entry point of the Flutter application.
void main() {
  runApp(const CalculatorApp());
}
