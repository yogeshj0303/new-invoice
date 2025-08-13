import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _previousValue = '';
  String _operation = '';
  bool _newNumber = true;
  double _memory = 0;
  bool _isGSTMode = false;
  String _displayExpression = '0';

  void _onNumberPressed(String number) {
    setState(() {
      if (_newNumber) {
        // If we're starting a new number and there's no operation, clear the display
        if (_operation.isEmpty && _previousValue.isEmpty) {
          _display = number;
          _newNumber = false;
        } else {
          _display = number;
          _newNumber = false;
        }
      } else {
        if (_display == '0' && number != '.') {
          _display = number;
        } else if (_display == 'Error') {
          _display = number;
          _newNumber = false;
        } else if (number == '.' && _display.contains('.')) {
          // Don't add another decimal point if one already exists
          return;
        } else {
          _display += number;
        }
      }
      // Update the display expression
      if (_operation.isNotEmpty) {
        _displayExpression = '$_previousValue $_operation $_display';
      } else {
        _displayExpression = _display;
      }
    });
  }

  void _onOperatorPressed(String operator) {
    setState(() {
      // If we already have a previous value and operation, calculate the result first
      if (_previousValue.isNotEmpty && _operation.isNotEmpty && !_newNumber) {
        _calculate();
        _previousValue = _display;
      } else {
        // Store the current display value as the first operand
        _previousValue = _display;
      }
      // Set the new operation
      _operation = operator;
      // Prepare for the next number input
      _newNumber = true;
      // Update the display expression to show the operation
      _displayExpression = '$_previousValue $_operation';
    });
  }

  void _calculate() {
    setState(() {
      try {
        if (_previousValue.isEmpty || _operation.isEmpty) {
          return;
        }
        
        double prev = double.parse(_previousValue);
        double current = double.parse(_display);
        double result = 0;

        switch (_operation) {
          case '+':
            result = prev + current;
            break;
          case '-':
            result = prev - current;
            break;
          case '×':
            result = prev * current;
            break;
          case '÷':
            if (current != 0) {
              result = prev / current;
            } else {
              _display = 'Error';
              _newNumber = true;
              _displayExpression = 'Error';
              return;
            }
            break;
          case '%':
            result = prev % current;
            break;
          default:
            return;
        }

        _display = result.toString();
        if (_display.endsWith('.0')) {
          _display = _display.substring(0, _display.length - 2);
        }
        _newNumber = true;
        // Update the display expression to show the result
        _displayExpression = _display;
      } catch (e) {
        _display = 'Error';
        _newNumber = true;
        _displayExpression = 'Error';
      }
    });
  }

  void _onEqualsPressed() {
    if (_previousValue.isNotEmpty && _operation.isNotEmpty && !_newNumber) {
      _calculate();
      _previousValue = '';
      _operation = '';
      _displayExpression = _display;
    } else if (_previousValue.isNotEmpty && _operation.isNotEmpty && _newNumber) {
      // If we have a previous value and operation but no new number, repeat the last operation
      _display = _previousValue;
      _newNumber = false;
      _displayExpression = _display;
    }
    // After equals, prepare for new calculation
    _newNumber = true;
  }

  void _onClearPressed() {
    setState(() {
      _display = '0';
      _previousValue = '';
      _operation = '';
      _newNumber = true;
      _isGSTMode = false;
      _displayExpression = '0';
    });
  }

  void _onPercentagePressed(double percentage) {
    if (_display != '0' && _display != 'Error') {
      double value = double.parse(_display);
      double result = value * (percentage / 100);
      setState(() {
        _display = result.toString();
        if (_display.endsWith('.0')) {
          _display = _display.substring(0, _display.length - 2);
        }
        _newNumber = true;
      });
    }
  }

  void _onGSTPressed() {
    if (_display != '0' && _display != 'Error') {
      double value = double.parse(_display);
      double gstAmount = value * 0.18; // 18% GST
      double totalWithGST = value + gstAmount;
      setState(() {
        _display = totalWithGST.toString();
        if (_display.endsWith('.0')) {
          _display = _display.substring(0, _display.length - 2);
        }
        _newNumber = true;
      });
    }
  }

  void _onCashInOutPressed(bool isCashIn) {
    if (_display != '0' && _display != 'Error') {
      double value = double.parse(_display);
      setState(() {
        _display = isCashIn ? '+${value.toString()}' : '-${value.toString()}';
        _newNumber = true;
      });
    }
  }

  void _onMemoryPressed(String memoryOp) {
    double currentValue = double.tryParse(_display) ?? 0;
    
    switch (memoryOp) {
      case 'GT':
        _memory += currentValue;
        break;
      case 'MU':
        if (_previousValue.isNotEmpty && _operation.isNotEmpty) {
          double prev = double.parse(_previousValue);
          double markup = currentValue;
          double result = prev + (prev * markup / 100);
          _display = result.toString();
          if (_display.endsWith('.0')) {
            _display = _display.substring(0, _display.length - 2);
          }
          _newNumber = true;
        }
        break;
    }
  }

  Widget _buildButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
    double? width,
    double? height,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: height ?? 70,
          margin: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF2E3085)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Calculator',
          style: TextStyle(
            color: Color(0xFF2E3085),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Color(0xFF2E3085)),
            onPressed: () {
              // TODO: Implement calculator settings
            },
          ),
        ],
      ),
             body: SafeArea(
         bottom: true,
         child: SingleChildScrollView(
           physics: BouncingScrollPhysics(),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.end,
             mainAxisAlignment: MainAxisAlignment.end,
             children: [
                         // Display Area
             Container(
               margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
               height: MediaQuery.of(context).size.height * 0.2,
               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
               decoration: BoxDecoration(
                 color: Colors.grey[50],
                 borderRadius: BorderRadius.circular(12),
                 border: Border.all(color: Colors.grey.withOpacity(0.1)),
               ),
                                 child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                                         Container(
                      width: double.infinity,
                       height: 60,
                       child: Text(
                         _displayExpression,
                         style: TextStyle(
                           fontSize: 18,
                           fontWeight: FontWeight.w500,
                           color: Colors.black87,
                         ),
                         textAlign: TextAlign.right,
                       ),
                     ),
                    GestureDetector(
                                             onTap: () {
                         if (_display.length > 1) {
                           setState(() {
                             _display = _display.substring(0, _display.length - 1);
                             if (_display.isEmpty) _display = '0';
                             // Update the display expression
                             if (_operation.isNotEmpty) {
                               _displayExpression = '$_previousValue $_operation $_display';
                             } else {
                               _displayExpression = _display;
                             }
                           });
                         } else {
                           setState(() {
                             _display = '0';
                             _displayExpression = '0';
                           });
                         }
                       },
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Color(0xFF2E3085),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.backspace,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
            ),

            // Calculator Buttons
            Container(
              height: MediaQuery.of(context).size.height * 0.65,
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  // Special Function Buttons
                  Row(
                    children: [
                      _buildButton(
                        text: 'GT',
                        color: Colors.grey[400]!,
                        onPressed: () => _onMemoryPressed('GT'),
                      ),
                      _buildButton(
                        text: 'MU',
                        color: Colors.grey[400]!,
                        onPressed: () => _onMemoryPressed('MU'),
                      ),
                      _buildButton(
                        text: 'Cash IN',
                        color: Colors.teal,
                        onPressed: () => _onCashInOutPressed(true),
                      ),
                      _buildButton(
                        text: 'Cash OUT',
                        color: Colors.red[300]!,
                        onPressed: () => _onCashInOutPressed(false),
                      ),
                    ],
                  ),

                  // Percentage Buttons
                  Row(
                    children: [
                      _buildButton(
                        text: '+3%',
                        color: Colors.grey[400]!,
                        onPressed: () => _onPercentagePressed(3),
                      ),
                      _buildButton(
                        text: '+5%',
                        color: Colors.grey[400]!,
                        onPressed: () => _onPercentagePressed(5),
                      ),
                      _buildButton(
                        text: '+12%',
                        color: Colors.grey[400]!,
                        onPressed: () => _onPercentagePressed(12),
                      ),
                      _buildButton(
                        text: '+18%',
                        color: Colors.grey[400]!,
                        onPressed: () => _onPercentagePressed(18),
                      ),
                      _buildButton(
                        text: '+GST',
                        color: Colors.grey[400]!,
                        onPressed: _onGSTPressed,
                      ),
                    ],
                  ),

                  // Negative Percentage Buttons
                  Row(
                    children: [
                      _buildButton(
                        text: '-3%',
                        color: Colors.grey[400]!,
                        onPressed: () => _onPercentagePressed(-3),
                      ),
                      _buildButton(
                        text: '-5%',
                        color: Colors.grey[400]!,
                        onPressed: () => _onPercentagePressed(-5),
                      ),
                      _buildButton(
                        text: '-12%',
                        color: Colors.grey[400]!,
                        onPressed: () => _onPercentagePressed(-12),
                      ),
                      _buildButton(
                        text: '-18%',
                        color: Colors.grey[400]!,
                        onPressed: () => _onPercentagePressed(-18),
                      ),
                      _buildButton(
                        text: '-GST',
                        color: Colors.grey[400]!,
                        onPressed: () {
                          if (_display != '0' && _display != 'Error') {
                            double value = double.parse(_display);
                            double gstAmount = value * 0.18;
                            double baseAmount = value - gstAmount;
                            setState(() {
                              _display = baseAmount.toString();
                              if (_display.endsWith('.0')) {
                                _display = _display.substring(0, _display.length - 2);
                              }
                              _newNumber = true;
                            });
                          }
                        },
                      ),
                    ],
                  ),

                  // Number Pad and Operators
                  Expanded(
                    child: Row(
                      children: [
                        // Number Pad
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              // 7, 8, 9
                              Row(
                                children: [
                                  _buildButton(
                                    text: '7',
                                    color: Color(0xFF2E3085),
                                    onPressed: () => _onNumberPressed('7'),
                                  ),
                                  _buildButton(
                                    text: '8',
                                    color: Color(0xFF2E3085),
                                    onPressed: () => _onNumberPressed('8'),
                                  ),
                                  _buildButton(
                                    text: '9',
                                    color: Color(0xFF2E3085),
                                    onPressed: () => _onNumberPressed('9'),
                                  ),
                                ],
                              ),
                              // 4, 5, 6
                              Row(
                                children: [
                                  _buildButton(
                                    text: '4',
                                    color: Color(0xFF2E3085),
                                    onPressed: () => _onNumberPressed('4'),
                                  ),
                                  _buildButton(
                                    text: '5',
                                    color: Color(0xFF2E3085),
                                    onPressed: () => _onNumberPressed('5'),
                                  ),
                                  _buildButton(
                                    text: '6',
                                    color: Color(0xFF2E3085),
                                    onPressed: () => _onNumberPressed('6'),
                                  ),
                                ],
                              ),
                              // 1, 2, 3
                              Row(
                                children: [
                                  _buildButton(
                                    text: '1',
                                    color: Color(0xFF2E3085),
                                    onPressed: () => _onNumberPressed('1'),
                                  ),
                                  _buildButton(
                                    text: '2',
                                    color: Color(0xFF2E3085),
                                    onPressed: () => _onNumberPressed('2'),
                                  ),
                                  _buildButton(
                                    text: '3',
                                    color: Color(0xFF2E3085),
                                    onPressed: () => _onNumberPressed('3'),
                                  ),
                                ],
                              ),
                              // 0, 00, .
                              Row(
                                children: [
                                  _buildButton(
                                    text: '0',
                                    color: Color(0xFF2E3085),
                                    onPressed: () => _onNumberPressed('0'),
                                  ),
                                  _buildButton(
                                    text: '00',
                                    color: Color(0xFF2E3085),
                                    onPressed: () => _onNumberPressed('00'),
                                  ),
                                  _buildButton(
                                    text: '.',
                                    color: Color(0xFF2E3085),
                                    onPressed: () => _onNumberPressed('.'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Right Side Operators
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              Container(
                                height: 70,
                                margin: EdgeInsets.all(2),
                                child: GestureDetector(
                                  onTap: () => _onOperatorPressed('%'),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[400]!,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey[400]!.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: Offset(0, 2), 
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        '%',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 70,
                                margin: EdgeInsets.all(2),
                                child: GestureDetector(
                                  onTap: () => _onOperatorPressed('-'),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[400]!,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey[400]!.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        '-',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 142,
                                margin: EdgeInsets.all(4),
                                child: GestureDetector(
                                  onTap: () => _onOperatorPressed('+'),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[400]!,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey[400]!.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        '+',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Far Right Operators
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              Container(
                                height: 70,
                                margin: EdgeInsets.all(2),
                                child: GestureDetector(
                                  onTap: _onClearPressed,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.orange.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        'AC',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 70,
                                margin: EdgeInsets.all(2),
                                child: GestureDetector(
                                  onTap: () => _onOperatorPressed('÷'),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[400]!,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey[400]!.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        '÷',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 70,
                                margin: EdgeInsets.all(2),
                                child: GestureDetector(
                                  onTap: () => _onOperatorPressed('×'),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[400]!,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey[400]!.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        '×',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 70,
                                margin: EdgeInsets.all(2),
                                child: GestureDetector(
                                  onTap: _onEqualsPressed,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[400]!,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey[400]!.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        '=',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
                         ),
           ],
         ),
       ),
     ),
   );
   }
} 