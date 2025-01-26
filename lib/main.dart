import 'dart:math';

import 'package:buttons_panel/buttons_panel.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Airvana',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ShapeAnimationScreen(),
    );
  }
}

// Shape enum to track current shape
enum ShapeType {
  line,
  triangle,
  square,
}

// Main screen widget structure
class ShapeAnimationScreen extends StatefulWidget {
  const ShapeAnimationScreen({super.key});

  @override
  _ShapeAnimationScreenState createState() => _ShapeAnimationScreenState();
}

class _ShapeAnimationScreenState extends State<ShapeAnimationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  ShapeType _currentShape = ShapeType.line;
  int _durationSeconds = 3;
  bool _isAnimating = false;
  bool _isReverse = false;
  int _selectedButtonIndex = 0;
  int _rotationCount = 0;

  Widget panelButton(String name, ShapeType shape, bool isSelected) {
    Color color = isSelected ? Colors.blue : Colors.black;

    Widget shapeIndicator;
    switch (shape) {
      case ShapeType.line:
        shapeIndicator = SizedBox(
            width: 20,
            height: 20,
            child: CustomPaint(
              size: const Size(20, 20),
              painter: ButtonPanelShapePainter(
                  selected: isSelected, shape: ShapeType.line),
            ));
        break;
      case ShapeType.triangle:
        shapeIndicator = SizedBox(
            width: 20,
            height: 20,
            child: CustomPaint(
              size: const Size(20, 20),
              painter: ButtonPanelShapePainter(
                  selected: isSelected, shape: ShapeType.triangle),
            ));
        break;
      case ShapeType.square:
        shapeIndicator = SizedBox(
            width: 20,
            height: 20,
            child: CustomPaint(
              size: const Size(20, 20),
              painter: ButtonPanelShapePainter(
                  selected: isSelected, shape: ShapeType.square),
            ));
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          shapeIndicator,
          Text(
            name,
            style: TextStyle(color: color),
          ),
        ],
      ),
    );
  }

  void _toggleAnimation() {
    setState(() {
      _isAnimating = !_isAnimating;
      if (_isAnimating) {
        _controller.forward();
        _isReverse = false;
      } else {
        _controller.reset();
        _controller.stop();
        _isReverse = false;
        _isAnimating = false;
        _rotationCount = 0;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _durationSeconds),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (_isAnimating) {
            setState(() {
              _isReverse = true;
              _rotationCount++;
            });
          }
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          if (!_isAnimating) {
            setState(() {
              _isReverse = false;
            });
          }
          _controller.forward();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ShapeAnimationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // _controller.stop();
    _controller.duration = Duration(seconds: _durationSeconds);

    if (_isAnimating) {
      _isReverse = false;
      _controller.forward(from: 0.0);
    } else {
      _controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: SizedBox(
                height: 200,
                width: 200, // Adjust height as needed
                child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(2, 100),
                        painter: LineAnimatorPainter(progress: _controller.value ,
                          isReverse: _isReverse ),
                        // Width of 2 for the line thickness
                        // painter: _currentShape == ShapeType.triangle
                        //     ? TrianglePainter(
                        //   progress: _controller.value,
                        //   isAnimating: _isAnimating,
                        //   rotationCount: _rotationCount,
                        // )
                        //     : LinePainter(
                        //   progress: _controller.value,
                        //   isReverse: _isReverse,
                        // ),
                      );
                    }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: ElevatedButton(
                  onPressed: _toggleAnimation,
                  child: Text(_isAnimating ? 'Stop' : 'Start')),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 30.0, top: 10.0, bottom: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  NumberPicker(
                    value: _durationSeconds,
                    // decoration: ,
                    onChanged: (change) => {
                      setState(() {
                        _durationSeconds = change;
                        _controller.duration =
                            Duration(seconds: _durationSeconds);
                        _controller.reset();
                        !_isAnimating ? _controller.stop() : null;
                      }),
                    },
                    minValue: 1,
                    maxValue: 10,
                  ),
                  const Text("Secs"),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
              child: ButtonsPanel(
                  currentIndex: _selectedButtonIndex,
                  onTap: (value) => setState(() {
                        _selectedButtonIndex = value;
                        _currentShape = value == 0
                            ? ShapeType.line
                            : value == 1
                                ? ShapeType.triangle
                                : ShapeType.square;
                      }),
                  backgroundColor: Theme.of(context).focusColor,
                  children: [
                    panelButton(
                        "Line", ShapeType.line, _selectedButtonIndex == 0),
                    panelButton("Triangle", ShapeType.triangle,
                        _selectedButtonIndex == 1),
                    panelButton(
                        "Square", ShapeType.square, _selectedButtonIndex == 2),
                  ]),
            )
          ],
        ),
      ),
    );
  }
}

class LineAnimatorPainter extends CustomPainter {
  final double progress;
  final bool isReverse;

  LineAnimatorPainter({
    required this.progress,
    required this.isReverse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final blackPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 20;

    final bluePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 20;

    // Draw the black background line
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      blackPaint,
    );

    // Moving from bottom to top
    canvas.drawLine(
      Offset(size.width / 2, size.height * (1 - progress)),
      Offset(size.width / 2, size.height),
      bluePaint,
    );
  }

  @override
  bool shouldRepaint(LineAnimatorPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isReverse != isReverse;
  }

}

class ButtonPanelShapePainter extends CustomPainter {
  final bool selected;
  final ShapeType shape;

  ButtonPanelShapePainter({
    required this.selected,
    required this.shape,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final blackPaint = Paint()
      ..color = selected ? Colors.blue : Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Define the triangle points
    final trianglePath = Path()
      ..moveTo((size.width) / 2, 0 + (size.height * .1)) //top
      ..lineTo(size.width * .1, size.height - (size.height * .1)) // left
      ..lineTo(size.width - size.width * .1,
          size.height - (size.height * .1)) //right
      ..close();

    // Define the square dimensions
    final squareRect = Rect.fromLTWH(
      size.width * 0.1, // Left margin
      size.height * 0.1, // Top margin
      size.width * 0.8, // Width (90% of size)
      size.height * 0.8, // Height (90% of size)
    );

    shape == ShapeType.triangle
        ? canvas.drawPath(trianglePath, blackPaint)
        : shape == ShapeType.square
            ? canvas.drawRect(squareRect, blackPaint)
            : canvas.drawLine(Offset(size.width / 2, 0),
                Offset(size.width / 2, size.height), blackPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
