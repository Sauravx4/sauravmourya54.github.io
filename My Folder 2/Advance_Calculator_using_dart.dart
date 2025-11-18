import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// The main application widget for the calculator.
class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hide the debug banner
      title: 'Calculator & Converter', // Application title
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        brightness: Brightness.dark, // Use dark theme for overall app
      ), // Define the primary theme color
      home: const CalculatorScreen(), // Set CalculatorScreen as the home widget
    );
  }
}

// Data Model for the Temperature Converter using ChangeNotifier.
class TemperatureData extends ChangeNotifier {
  String _currentInputText = "";
  double? _parsedInput;
  String _displayUnit = "N/A";
  String _convertedUnit = "N/A";
  String _inputValueDisplay = "N/A";
  String _convertedValueDisplay = "N/A";
  String? _errorMessage;

  String get inputValueDisplay => _inputValueDisplay;
  String get convertedValueDisplay => _convertedValueDisplay;
  String get displayUnit => _displayUnit;
  String get convertedUnit => _convertedUnit;
  String? get errorMessage => _errorMessage;

  TemperatureData()
      : _currentInputText = "",
        _parsedInput = null,
        _displayUnit = "N/A",
        _convertedUnit = "N/A",
        _inputValueDisplay = "N/A",
        _convertedValueDisplay = "N/A",
        _errorMessage = null;

  void updateInputText(String text) {
    _currentInputText = text;
    _parsedInput = double.tryParse(text);

    if (_parsedInput == null && text.isNotEmpty) {
      _errorMessage = "Invalid number";
    } else if (text.isEmpty) {
      _errorMessage = null;
    } else {
      _errorMessage = null;
    }

    // Clear previous conversion results when input text changes
    _displayUnit = "N/A";
    _convertedUnit = "N/A";
    _inputValueDisplay = "N/A";
    _convertedValueDisplay = "N/A";

    notifyListeners();
  }

  void convertFromCelsius() {
    if (_parsedInput == null) {
      _errorMessage = "Please enter a number.";
      notifyListeners();
      return;
    }

    final double celsius = _parsedInput!;
    final double fahrenheit = (celsius * 9 / 5) + 32;

    _displayUnit = "Celsius";
    _convertedUnit = "Fahrenheit";
    _inputValueDisplay = '${celsius.toStringAsFixed(2)} °C';
    _convertedValueDisplay = '${fahrenheit.toStringAsFixed(2)} °F';
    _errorMessage = null;
    notifyListeners();
  }

  void convertFromFahrenheit() {
    if (_parsedInput == null) {
      _errorMessage = "Please enter a number.";
      notifyListeners();
      return;
    }

    final double fahrenheit = _parsedInput!;
    final double celsius = (fahrenheit - 32) * 5 / 9;

    _displayUnit = "Fahrenheit";
    _convertedUnit = "Celsius";
    _inputValueDisplay = '${fahrenheit.toStringAsFixed(2)} °F';
    _convertedValueDisplay = '${celsius.toStringAsFixed(2)} °C';
    _errorMessage = null;
    notifyListeners();
  }
}

// Data Model for GST Calculator
class GstData extends ChangeNotifier {
  String _baseAmountText = "";
  String _gstPercentageText = "";
  double? _parsedBaseAmount;
  double? _parsedGstPercentage;
  String _gstAmountDisplay = "0.00";
  String _totalAmountDisplay = "0.00";
  String? _errorMessage;

  String get gstAmountDisplay => _gstAmountDisplay;
  String get totalAmountDisplay => _totalAmountDisplay;
  String? get errorMessage => _errorMessage;

  GstData()
      : _baseAmountText = "",
        _gstPercentageText = "",
        _parsedBaseAmount = null,
        _parsedGstPercentage = null,
        _gstAmountDisplay = "0.00",
        _totalAmountDisplay = "0.00",
        _errorMessage = null;

  void updateBaseAmount(String text) {
    _baseAmountText = text;
    _parsedBaseAmount = double.tryParse(text);
    _calculateGst();
  }

  void updateGstPercentage(String text) {
    _gstPercentageText = text;
    _parsedGstPercentage = double.tryParse(text);
    _calculateGst();
  }

  void _calculateGst() {
    _errorMessage = null;
    _gstAmountDisplay = "0.00";
    _totalAmountDisplay = "0.00";

    if (_baseAmountText.isEmpty && _gstPercentageText.isEmpty) {
      notifyListeners();
      return;
    }

    if (_parsedBaseAmount == null) {
      _errorMessage = "Invalid base amount.";
      notifyListeners();
      return;
    }

    if (_parsedGstPercentage == null) {
      _errorMessage = "Invalid GST percentage.";
      notifyListeners();
      return;
    }

    if (_parsedBaseAmount! < 0 || _parsedGstPercentage! < 0) {
      _errorMessage = "Values cannot be negative.";
      notifyListeners();
      return;
    }

    final double base = _parsedBaseAmount!;
    final double gstRate = _parsedGstPercentage!;

    final double gstAmount = base * (gstRate / 100);
    final double totalAmount = base + gstAmount;

    _gstAmountDisplay = gstAmount.toStringAsFixed(2);
    _totalAmountDisplay = totalAmount.toStringAsFixed(2);
    notifyListeners();
  }
}

// Data Model for Shopkeeper Notes
class ShopkeeperNotesData extends ChangeNotifier {
  static const String _notesKey = 'shopkeeper_daily_sales_notes';
  final TextEditingController _noteController = TextEditingController();
  List<String> _notes = <String>[];

  TextEditingController get noteController => _noteController;
  List<String> get notes => _notes;

  ShopkeeperNotesData() {
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _notes = prefs.getStringList(_notesKey) ?? <String>[];
    notifyListeners();
  }

  Future<void> saveNote() async {
    if (_noteController.text.trim().isNotEmpty) {
      _notes.insert(0, _noteController.text.trim()); // Add to top
      _noteController.clear();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_notesKey, _notes);
      notifyListeners();
    }
  }

  Future<void> clearNotes() async {
    _notes.clear();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_notesKey, _notes);
    notifyListeners();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}

// Data Model for Profit Calculator
class ProfitCalculatorData extends ChangeNotifier {
  String _buyPriceText = "";
  String _salesPriceText = "";
  double? _parsedBuyPrice;
  double? _parsedSalesPrice;
  String _profitAmountDisplay = "0.00";
  String _profitPercentageDisplay = "0.00%";
  String? _errorMessage;

  String get profitAmountDisplay => _profitAmountDisplay;
  String get profitPercentageDisplay => _profitPercentageDisplay;
  String? get errorMessage => _errorMessage;

  ProfitCalculatorData()
      : _buyPriceText = "",
        _salesPriceText = "",
        _parsedBuyPrice = null,
        _parsedSalesPrice = null,
        _profitAmountDisplay = "0.00",
        _profitPercentageDisplay = "0.00%",
        _errorMessage = null;

  void updateBuyPrice(String text) {
    _buyPriceText = text;
    _parsedBuyPrice = double.tryParse(text);
    _calculateProfit();
  }

  void updateSalesPrice(String text) {
    _salesPriceText = text;
    _parsedSalesPrice = double.tryParse(text);
    _calculateProfit();
  }

  void _calculateProfit() {
    _errorMessage = null;
    _profitAmountDisplay = "0.00";
    _profitPercentageDisplay = "0.00%";

    if (_buyPriceText.isEmpty && _salesPriceText.isEmpty) {
      notifyListeners();
      return;
    }

    if (_parsedBuyPrice == null) {
      _errorMessage = "Invalid buy price.";
      notifyListeners();
      return;
    }

    if (_parsedSalesPrice == null) {
      _errorMessage = "Invalid sales price.";
      notifyListeners();
      return;
    }

    if (_parsedBuyPrice! < 0 || _parsedSalesPrice! < 0) {
      _errorMessage = "Prices cannot be negative.";
      notifyListeners();
      return;
    }

    final double buyPrice = _parsedBuyPrice!;
    final double salesPrice = _parsedSalesPrice!;

    final double profitAmount = salesPrice - buyPrice;
    _profitAmountDisplay = profitAmount.toStringAsFixed(2);

    if (buyPrice == 0) {
      if (profitAmount > 0) {
        _profitPercentageDisplay = "∞%"; // Infinite profit if buy price is zero and sales price is positive
      } else {
        _profitPercentageDisplay = "N/A";
      }
    } else {
      final double profitPercentage = (profitAmount / buyPrice) * 100;
      _profitPercentageDisplay = '${profitPercentage.toStringAsFixed(2)}%';
    }
    
    notifyListeners();
  }
}

// The stateful widget for the calculator and converter screen, managing tabs.
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 4, vsync: this); // Four tabs now
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose the tab controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Dark background for the main screen
      appBar: AppBar(
        title: const Text(
          'Commercial Calculator',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[850], // Darker app bar
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(icon: Icon(Icons.calculate), text: "Calculator"),
            Tab(icon: Icon(Icons.thermostat), text: "Temperature"),
            Tab(icon: Icon(Icons.percent), text: "GST"),
            Tab(icon: Icon(Icons.store), text: "Shopkeeper"),
          ],
          labelColor: Colors.white, // Active tab text color
          unselectedLabelColor: Colors.grey, // Inactive tab text color
          indicatorColor: Colors.orange, // Tab indicator color
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          const CalculatorPanel(), // The original calculator UI
          ChangeNotifierProvider<TemperatureData>(
            create: (BuildContext context) => TemperatureData(),
            builder: (BuildContext context, Widget? child) =>
                const TemperatureConverterUI(),
          ),
          ChangeNotifierProvider<GstData>(
            create: (BuildContext context) => GstData(),
            builder: (BuildContext context, Widget? child) =>
                const GstCalculatorUI(),
          ),
          MultiProvider(
            // Corrected type argument for the list of providers
            providers: <ChangeNotifierProvider<ChangeNotifier>>[
              ChangeNotifierProvider<ShopkeeperNotesData>(
                create: (BuildContext context) => ShopkeeperNotesData(),
              ),
              ChangeNotifierProvider<ProfitCalculatorData>(
                create: (BuildContext context) => ProfitCalculatorData(),
              ),
            ],
            builder: (BuildContext context, Widget? child) =>
                const ShopkeeperSectionUI(),
          ),
        ],
      ),
    );
  }
}

// The dedicated widget for the calculator panel.
class CalculatorPanel extends StatefulWidget {
  const CalculatorPanel({super.key});

  @override
  State<CalculatorPanel> createState() => _CalculatorPanelState();
}

class _CalculatorPanelState extends State<CalculatorPanel> {
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
            String currentExprForTrim = _expression;
            while (currentExprForTrim.isNotEmpty &&
                RegExp(r'[+\-*/×÷]$').hasMatch(currentExprForTrim)) {
              currentExprForTrim = currentExprForTrim.substring(
                0,
                currentExprForTrim.length - 1,
              );
            }
            _expression = currentExprForTrim;

            if (_expression.isEmpty) {
              _output = "0";
              _expression = "";
            } else {
              _output = _evaluateExpression(_expression);
              _expression = _output; // Store result for chained operations
            }
            _evaluated = true; // Mark as evaluated
          }
        } catch (e) {
          _output = "Error";
          _expression = ""; // Clear expression on error
          _evaluated = true;
        }
      } else {
        // Handle number and operator button presses
        if (_evaluated) {
          if (double.tryParse(buttonText) != null || buttonText == '.') {
            _expression = buttonText;
            _output = buttonText;
            _evaluated = false;
          } else {
            _expression += buttonText;
            _output = _expression;
            _evaluated = false;
          }
        } else {
          // Prevent multiple leading zeros for non-decimal numbers
          if (_expression == "0" &&
              buttonText != "." &&
              double.tryParse(buttonText) != null) {
            _expression = buttonText;
          }
          // Handle decimal point input
          else if (buttonText == '.') {
            final RegExpMatch? lastNumberMatch = RegExp(
              r'(\d*\.?\d*)$',
            ).firstMatch(_expression);
            final String lastNumber = (lastNumberMatch?.group(0) ?? '');

            if (lastNumber.contains('.')) {
              return; // Do nothing if decimal already exists in the current number
            }
            if (_expression.isEmpty ||
                RegExp(r'[+\-*/×÷]$').hasMatch(_expression)) {
              _expression += "0.";
            } else {
              _expression += buttonText;
            }
          }
          // Handle operator input
          else if (RegExp(r'[+\-*/×÷]').hasMatch(buttonText)) {
            if (_expression.isEmpty) {
              if (buttonText == '-') {
                _expression += buttonText;
              } else {
                return;
              }
            } else if (RegExp(r'[+\-*/×÷]$').hasMatch(_expression)) {
              final String lastOperator = _expression.substring(
                _expression.length - 1,
              );
              if ((lastOperator == '*' || lastOperator == '/') &&
                  buttonText == '-') {
                _expression += buttonText;
              } else if (lastOperator == '-' &&
                  (buttonText == '+' ||
                      buttonText == '×' ||
                      buttonText == '÷')) {
                _expression =
                    _expression.substring(0, _expression.length - 1) +
                    buttonText;
              } else {
                _expression =
                    _expression.substring(0, _expression.length - 1) +
                    buttonText;
              }
            } else {
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
    String processedExpr = expr.replaceAll('×', '*');
    processedExpr = processedExpr.replaceAll('÷', '/');

    try {
      final double result = _calculate(processedExpr);
      if (result == result.toInt()) {
        return result.toInt().toString();
      }
      return result.toString();
    } catch (e) {
      if (e is FormatException) {
        return "Syntax Error";
      } else if (e is ArgumentError && e.message == "Division by zero") {
        return "Div by Zero";
      }
      return "Error";
    }
  }

  // Core calculation logic that handles operator precedence.
  double _calculate(String expression) {
    final RegExp tokenRegex = RegExp(r'(-?\d+\.?\d*)|([+\-*/])');
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

    // Step 1.5: Handle unary minus at the start or after an operator
    List<dynamic> processedTokens = <dynamic>[];
    for (int i = 0; i < tokens.length; i++) {
      if (tokens[i] == '-' && (i == 0 || (tokens[i - 1] is String))) {
        if (i + 1 < tokens.length && tokens[i + 1] is double) {
          processedTokens.add(-(tokens[i + 1] as double));
          i++; // Skip the next token as it's been processed with the minus
        } else {
          throw const FormatException(
            "Syntax Error: Unary minus not followed by a number.",
          );
        }
      } else {
        processedTokens.add(tokens[i]);
      }
    }
    tokens = processedTokens;

    // Step 2: First pass - handle multiplication and division (higher precedence)
    List<dynamic> temp = <dynamic>[];
    for (int i = 0; i < tokens.length; i++) {
      if (tokens[i] == '*') {
        if (temp.isEmpty || !(temp.last is double)) {
          throw const FormatException(
            "Syntax Error: Missing left operand for multiplication.",
          );
        }
        final double left = temp.removeLast() as double;
        if (i + 1 >= tokens.length || !(tokens[i + 1] is double)) {
          throw const FormatException(
            "Syntax Error: Missing right operand for multiplication.",
          );
        }
        final double right = tokens[++i] as double;
        temp.add(left * right);
      } else if (tokens[i] == '/') {
        if (temp.isEmpty || !(temp.last is double)) {
          throw const FormatException(
            "Syntax Error: Missing left operand for division.",
          );
        }
        final double left = temp.removeLast() as double;
        if (i + 1 >= tokens.length || !(tokens[i + 1] is double)) {
          throw const FormatException(
            "Syntax Error: Missing right operand for division.",
          );
        }
        final double right = tokens[++i] as double;
        if (right == 0) {
          throw ArgumentError("Division by zero");
        }
        temp.add(left / right);
      } else {
        temp.add(tokens[i]);
      }
    }
    tokens = temp;

    // Step 3: Second pass - handle addition and subtraction (lower precedence)
    if (tokens.isEmpty) {
      return 0.0;
    }
    if (tokens.length == 1 && tokens[0] is double) {
      return tokens[0] as double;
    }

    for (int i = 0; i < tokens.length; i++) {
      if (i % 2 == 0 && !(tokens[i] is double)) {
        throw FormatException(
          "Syntax Error: Expected number but found operator at position ${i + 1}.",
        );
      } else if (i % 2 != 0 && !(tokens[i] is String)) {
        throw FormatException(
          "Syntax Error: Expected operator but found number at position ${i + 1}.",
        );
      }
    }
    if (tokens.length % 2 == 0) {
      throw const FormatException(
        "Syntax Error: Invalid expression ending with an operator.",
      );
    }

    double result = tokens[0] as double;
    for (int i = 1; i < tokens.length - 1; i += 2) {
      final String operator = tokens[i] as String;
      final double nextNumber = tokens[i + 1] as double;

      if (operator == '+') {
        result += nextNumber;
      } else if (operator == '-') {
        result -= nextNumber;
      } else {
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
    return Column(
      children: <Widget>[
        // Display area for the expression/output
        Expanded(
          child: Container(
            alignment: Alignment.bottomRight, // Align text to the bottom right
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
          children: <Widget>[
            // First row of buttons
            Row(
              children: <Widget>[
                _buildButton("7", Colors.grey[800]!),
                _buildButton("8", Colors.grey[800]!),
                _buildButton("9", Colors.grey[800]!),
                _buildButton("÷", Colors.orange),
              ],
            ),
            // Second row of buttons
            Row(
              children: <Widget>[
                _buildButton("4", Colors.grey[800]!),
                _buildButton("5", Colors.grey[800]!),
                _buildButton("6", Colors.grey[800]!),
                _buildButton("×", Colors.orange),
              ],
            ),
            // Third row of buttons
            Row(
              children: <Widget>[
                _buildButton("1", Colors.grey[800]!),
                _buildButton("2", Colors.grey[800]!),
                _buildButton("3", Colors.grey[800]!),
                _buildButton("-", Colors.orange),
              ],
            ),
            // Fourth row of buttons (includes decimal point)
            Row(
              children: <Widget>[
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
    );
  }
}

// The dedicated widget for the temperature converter UI.
class TemperatureConverterUI extends StatelessWidget {
  const TemperatureConverterUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TemperatureData>(
      builder:
          (BuildContext context, TemperatureData temperatureData, Widget? child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextField(
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Enter temperature value',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: 'e.g., 25.5',
                  hintStyle: const TextStyle(color: Colors.white54),
                  errorText: temperatureData.errorMessage,
                  border: const OutlineInputBorder(),
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54)),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange)),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 20),
                onChanged: (String value) =>
                    temperatureData.updateInputText(value),
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => temperatureData.convertFromCelsius(),
                      child: const Text('Convert from Celsius',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => temperatureData.convertFromFahrenheit(),
                      child: const Text('Convert from Fahrenheit',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              _buildResultDisplay(
                  'Input (${temperatureData.displayUnit}):',
                  temperatureData.inputValueDisplay),
              const SizedBox(height: 10),
              _buildResultDisplay(
                  'Converted (${temperatureData.convertedUnit}):',
                  temperatureData.convertedValueDisplay),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResultDisplay(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label,
              style: const TextStyle(fontSize: 18, color: Colors.white70)),
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// The dedicated widget for the GST Calculator UI.
class GstCalculatorUI extends StatelessWidget {
  const GstCalculatorUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GstData>(
      builder: (BuildContext context, GstData gstData, Widget? child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextField(
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Base Amount (e.g., 1000)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintStyle: const TextStyle(color: Colors.white54),
                  errorText: gstData.errorMessage,
                  border: const OutlineInputBorder(),
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54)),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange)),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 20),
                onChanged: (String value) => gstData.updateBaseAmount(value),
              ),
              const SizedBox(height: 15),
              TextField(
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'GST Percentage (e.g., 18)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintStyle: const TextStyle(color: Colors.white54),
                  errorText: gstData.errorMessage,
                  border: const OutlineInputBorder(),
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54)),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange)),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 20),
                onChanged: (String value) => gstData.updateGstPercentage(value),
              ),
              const SizedBox(height: 30),
              _buildResultDisplay('GST Amount:', '₹ ${gstData.gstAmountDisplay}'),
              const SizedBox(height: 10),
              _buildResultDisplay(
                  'Total Amount (with GST):', '₹ ${gstData.totalAmountDisplay}'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResultDisplay(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label,
              style: const TextStyle(fontSize: 18, color: Colors.white70)),
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// The dedicated widget for the Shopkeeper Section UI.
class ShopkeeperSectionUI extends StatelessWidget {
  const ShopkeeperSectionUI({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          Text(
            'Daily Sales Notes',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 15),
          NotesSectionUI(),
          SizedBox(height: 30),
          Text(
            'Profit Calculator',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 15),
          ProfitCalculatorUI(),
        ],
      ),
    );
  }
}

class NotesSectionUI extends StatelessWidget {
  const NotesSectionUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopkeeperNotesData>(
      builder:
          (BuildContext context, ShopkeeperNotesData notesData, Widget? child) {
        return Column(
          children: <Widget>[
            TextField(
              controller: notesData.noteController,
              keyboardType: TextInputType.multiline,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Enter daily sales notes',
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: 'e.g., Sold 5 items, total 1500. Collected cash.',
                hintStyle: const TextStyle(color: Colors.white54),
                border: const OutlineInputBorder(),
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54)),
                focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange)),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: notesData.saveNote,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text('Save Note',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: notesData.clearNotes,
                    icon: const Icon(Icons.clear_all, color: Colors.white),
                    label: const Text('Clear All Notes',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (notesData.notes.isEmpty)
              const Text('No notes saved yet.',
                  style: TextStyle(color: Colors.white70, fontSize: 16))
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                constraints: const BoxConstraints(maxHeight: 250),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: notesData.notes.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        '• ${notesData.notes[index]}',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class ProfitCalculatorUI extends StatelessWidget {
  const ProfitCalculatorUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfitCalculatorData>(
      builder: (BuildContext context, ProfitCalculatorData profitData,
          Widget? child) {
        return Column(
          children: <Widget>[
            TextField(
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Buy Price',
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: 'e.g., 500',
                hintStyle: const TextStyle(color: Colors.white54),
                errorText: profitData.errorMessage,
                border: const OutlineInputBorder(),
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54)),
                focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange)),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 20),
              onChanged: (String value) => profitData.updateBuyPrice(value),
            ),
            const SizedBox(height: 15),
            TextField(
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Sales Price',
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: 'e.g., 750',
                hintStyle: const TextStyle(color: Colors.white54),
                errorText: profitData.errorMessage,
                border: const OutlineInputBorder(),
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54)),
                focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange)),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 20),
              onChanged: (String value) => profitData.updateSalesPrice(value),
            ),
            const SizedBox(height: 30),
            _buildResultDisplay(
                'Profit Amount:', '₹ ${profitData.profitAmountDisplay}'),
            const SizedBox(height: 10),
            _buildResultDisplay(
                'Profit Percentage:', profitData.profitPercentageDisplay),
          ],
        );
      },
    );
  }

  Widget _buildResultDisplay(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label,
              style: const TextStyle(fontSize: 18, color: Colors.white70)),
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// The main function, which is the entry point of the Flutter application.
void main() {
  runApp(const CalculatorApp());
}
