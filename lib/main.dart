import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter
import 'dart:math'; // For pow

// Define enums for our unit toggles
enum WeightUnit { kg, lb }
enum HeightUnit { m, cm, ftIn }

void main() {
  runApp(const BmiCalculatorApp());
}

class BmiCalculatorApp extends StatelessWidget {
  const BmiCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const BmiCalculatorPage(),
    );
  }
}

class BmiCalculatorPage extends StatefulWidget {
  const BmiCalculatorPage({super.key});

  @override
  State<BmiCalculatorPage> createState() => _BmiCalculatorPageState();
}

class _BmiCalculatorPageState extends State<BmiCalculatorPage> {
  // Global key for form validation
  final _formKey = GlobalKey<FormState>();

  // State variables for unit selection
  WeightUnit _weightUnit = WeightUnit.kg;
  HeightUnit _heightUnit = HeightUnit.cm;

  // Controllers for text fields
  final _weightController = TextEditingController();
  final _heightCmController = TextEditingController(text: "170"); // Pre-fill for test case
  final _heightMController = TextEditingController();
  final _heightFtController = TextEditingController(text: "5"); // Pre-fill for test case
  final _heightInController = TextEditingController(text: "7"); // Pre-fill for test case

  // State variables for the result
  double _bmiResult = 0.0;
  String _bmiCategory = "";
  Color _bmiColor = Colors.grey;
  bool _showResult = false;

  // --- Helper: Input Formatter ---
  // Allows only numbers and a single decimal point
  final _decimalInputFormatter = FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'));

  // --- Helper: Validation ---
  String? _validateNumber(String? value, String fieldName, {bool allowZero = false}) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    if (value.split('.').length > 2) {
      return 'Invalid number (too many dots)';
    }
    final double? num = double.tryParse(value);
    if (num == null) {
      return 'Please enter a valid number';
    }
    if (!allowZero && num <= 0) {
      return '$fieldName must be greater than 0';
    }
    return null;
  }

  // --- Core Logic: Conversions ---
  double _poundsToKg(double lb) {
    return lb * 0.45359237;
  }

  double _cmToMeters(double cm) {
    return cm / 100.0;
  }

  double _feetInchToMeters(double ft, double inch) {
    return (ft * 12 + inch) * 0.0254;
  }

  // --- NEW: Reset Form Logic ---
  void _resetForm() {
    setState(() {
      _formKey.currentState?.reset(); // Reset validation state
      _weightController.clear();
      _heightCmController.text = "170"; // Reset to default
      _heightMController.clear();
      _heightFtController.text = "5"; // Reset to default
      _heightInController.text = "7"; // Reset to default

      _weightUnit = WeightUnit.kg;
      _heightUnit = HeightUnit.cm;

      _showResult = false;
      _bmiResult = 0.0;
      _bmiCategory = "";
      _bmiColor = Colors.grey;
    });
    FocusScope.of(context).unfocus(); // Hide keyboard
  }

  // --- Core Logic: BMI Calculation ---
  void _calculateBmi() {
    // 1. Hide keyboard
    FocusScope.of(context).unfocus();

    // 2. Validate all visible fields
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _showResult = false; // Hide old result if new input is invalid
      });
      return;
    }

    // 3. Get values from controllers
    double weight = double.tryParse(_weightController.text) ?? 0;
    double heightCm = double.tryParse(_heightCmController.text) ?? 0;
    double heightM = double.tryParse(_heightMController.text) ?? 0;
    double heightFt = double.tryParse(_heightFtController.text) ?? 0;
    double heightIn = double.tryParse(_heightInController.text) ?? 0;

    // 4. (Bonus UX) Handle inch carry-over
    if (heightIn >= 12) {
      heightFt += (heightIn ~/ 12); // Integer division
      heightIn = heightIn % 12; // Remainder

      // Update controllers to reflect this change
      _heightFtController.text = heightFt.toString();
      _heightInController.text = heightIn.toString();
    }

    // 5. Convert all inputs to metric (kg and m)
    double weightInKg;
    if (_weightUnit == WeightUnit.lb) {
      weightInKg = _poundsToKg(weight);
    } else {
      weightInKg = weight;
    }

    double heightInMeters;
    switch (_heightUnit) {
      case HeightUnit.m:
        heightInMeters = heightM;
        break;
      case HeightUnit.cm:
        heightInMeters = _cmToMeters(heightCm);
        break;
      case HeightUnit.ftIn:
        heightInMeters = _feetInchToMeters(heightFt, heightIn);
        break;
    }

    // 6. Check for zero height (which would cause a crash)
    if (heightInMeters == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Height cannot be zero.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 7. Calculate BMI
    double bmi = weightInKg / pow(heightInMeters, 2);

    // 8. Set result state (category and color)
    _setBmiResult(bmi);
  }

  void _setBmiResult(double bmi) {
    setState(() {
      _bmiResult = bmi;

      if (bmi < 18.5) {
        _bmiCategory = "Underweight";
        _bmiColor = Colors.blue;
      } else if (bmi >= 18.5 && bmi <= 24.9) {
        _bmiCategory = "Normal";
        _bmiColor = Colors.green;
      } else if (bmi >= 25.0 && bmi <= 29.9) {
        _bmiCategory = "Overweight";
        _bmiColor = Colors.orange;
      } else {
        _bmiCategory = "Obese";
        _bmiColor = Colors.red;
      }

      _showResult = true; // Show the result card
    });
  }

  @override
  void dispose() {
    // Clean up controllers
    _weightController.dispose();
    _heightCmController.dispose();
    _heightMController.dispose();
    _heightFtController.dispose();
    _heightInController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Calculator'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Weight Section ---
                _buildWeightInput(),
                const SizedBox(height: 24),

                // --- Height Section ---
                _buildHeightInput(),
                const SizedBox(height: 32),

                // --- Buttons Row (Calculate & Reset) ---
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _resetForm,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          side: BorderSide(color: Theme.of(context).colorScheme.primary),
                          foregroundColor: Theme.of(context).colorScheme.primary,
                        ),
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _calculateBmi,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                        child: const Text('Calculate'), // Shortened text
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // --- Result Card ---
                _buildResultCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI Widget: Weight Input ---
  Widget _buildWeightInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Weight', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        SegmentedButton<WeightUnit>(
          segments: const [
            ButtonSegment(value: WeightUnit.kg, label: Text('kg')),
            ButtonSegment(value: WeightUnit.lb, label: Text('lb')),
          ],
          selected: {_weightUnit},
          onSelectionChanged: (newSelection) {
            setState(() {
              _weightUnit = newSelection.first;
            });
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _weightController,
          validator: (value) => _validateNumber(value, "Weight"),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [_decimalInputFormatter],
          decoration: InputDecoration(
            labelText: 'Enter Weight',
            suffixText: _weightUnit == WeightUnit.kg ? 'kg' : 'lb',
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  // --- UI Widget: Height Input ---
  Widget _buildHeightInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Height', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        SegmentedButton<HeightUnit>(
          segments: const [
            ButtonSegment(value: HeightUnit.cm, label: Text('cm')),
            ButtonSegment(value: HeightUnit.m, label: Text('m')),
            ButtonSegment(value: HeightUnit.ftIn, label: Text('ft/in')),
          ],
          selected: {_heightUnit},
          onSelectionChanged: (newSelection) {
            setState(() {
              _heightUnit = newSelection.first;
              // Clear validation when switching types
              _formKey.currentState?.reset();
            });
          },
        ),
        const SizedBox(height: 16),
        // --- Dynamic Height Fields ---
        // Use an animated switcher for a smooth transition
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: _buildDynamicHeightFields(),
        ),
      ],
    );
  }

  // --- UI Widget: Dynamic Height Fields ---
  Widget _buildDynamicHeightFields() {
    // We use a `Key` to ensure Flutter rebuilds the right widget
    if (_heightUnit == HeightUnit.cm) {
      return TextFormField(
        key: const ValueKey('cm'),
        controller: _heightCmController,
        validator: (value) => _validateNumber(value, "Height"),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [_decimalInputFormatter],
        decoration: const InputDecoration(
          labelText: 'Enter Height',
          suffixText: 'cm',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      );
    } else if (_heightUnit == HeightUnit.m) {
      return TextFormField(
        key: const ValueKey('m'),
        controller: _heightMController,
        validator: (value) => _validateNumber(value, "Height"),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [_decimalInputFormatter],
        decoration: const InputDecoration(
          labelText: 'Enter Height',
          suffixText: 'm',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      );
    } else {
      // This is for ft/in
      return Row(
        key: const ValueKey('ftIn'),
        children: [
          Expanded(
            child: TextFormField(
              controller: _heightFtController,
              validator: (value) => _validateNumber(value, "Feet", allowZero: true),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [_decimalInputFormatter],
              decoration: const InputDecoration(
                labelText: 'Feet',
                suffixText: 'ft',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: _heightInController,
              validator: (value) => _validateNumber(value, "Inches", allowZero: true),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [_decimalInputFormatter],
              decoration: const InputDecoration(
                labelText: 'Inches',
                suffixText: 'in',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  // --- UI Widget: Result Card ---
  Widget _buildResultCard() {
    // Use AnimatedOpacity for a smooth fade-in/out
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _showResult ? 1.0 : 0.0,
      child: _showResult
          ? Card(
        elevation: 4,
        color: _bmiColor.withOpacity(0.1), // Tinted card background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: _bmiColor, width: 1.5), // Colored border
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Your Result',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Chip(
                label: Text(
                  _bmiCategory,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: _bmiColor, // Solid color chip
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              const SizedBox(height: 16),
              Text(
                _bmiResult.toStringAsFixed(1), // BMI value to 1 decimal place
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: _bmiColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getBmiMessage(_bmiCategory), // Get descriptive message
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      )
          : const SizedBox.shrink(), // Don't show anything if _showResult is false
    );
  }

  // --- Helper: Get a message for the category ---
  String _getBmiMessage(String category) {
    switch (category) {
      case "Underweight":
        return "You may need to gain some weight. Consider consulting a nutritionist.";
      case "Normal":
        return "You have a healthy body weight. Keep up the good work!";
      case "Overweight":
        return "You may be overweight. Consider a balanced diet and exercise.";
      case "Obese":
        return "You are in the obese category. It's recommended to consult a doctor.";
      default:
        return "";
    }
  }
}