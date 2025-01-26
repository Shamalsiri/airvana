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
  bool _isLineReverse = false;
  int _selectedButtonIndex = 0;
  int _rotationCount = 0;
  bool _isAnimating = false;
  bool _isPrimaryColor = true ;
  int _durationSeconds = 3;

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

    if (isSelected) {
      _currentShape = shape;
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
        _isLineReverse = false;
      } else {
        _controller.reset();
        _controller.stop();
        _isLineReverse = false;
        _isAnimating = false;
        _isPrimaryColor = true;
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
              _isLineReverse = true;
              _rotationCount++;
              _isPrimaryColor = !_isPrimaryColor;
            });

            if (_currentShape == ShapeType.line) {
              _controller.forward();
            } else
            if (_currentShape == ShapeType.triangle) {
              _controller.reset();
              if (_isAnimating) {
                _controller.forward();
              }
            }
          }
        } else if (status == AnimationStatus.dismissed) {
          if (!_isAnimating) {
            setState(() {
              _isLineReverse = false;
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
      _isLineReverse = false;
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
                        painter:
                        _currentShape == ShapeType.line ?
                        LineAnimatorPainter(progress: _controller.value, isReverse: _isLineReverse):
                        TriangleAnimatorPainter(progress: _controller.value, isPrimaryColor: _isPrimaryColor)
                        ,
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

class TriangleAnimatorPainter extends CustomPainter {
  final double progress;
  final bool isPrimaryColor;

  TriangleAnimatorPainter({
    required this.progress,
    required this.isPrimaryColor
  });

  /*@override
  void paint(Canvas canvas, Size size) {
    final bluePaint = Paint()
      ..color =  Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    final blackPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;


    // Define the triangle points
    final topPoint = Offset(size.width / 2, 0);
    final bottomLeft = Offset(0, size.height);
    final bottomRight = Offset(size.width, size.height);

    final trianglePath = Path()
      ..moveTo(bottomLeft.dx, bottomLeft.dy)
      ..lineTo(topPoint.dx, topPoint.dy)..lineTo(bottomRight.dx, bottomRight.dy)
      ..close();

    canvas.drawPath(trianglePath, blackPaint);

    Path progressPath = Path();
    final currentPaint = isPrimaryColor ? bluePaint : blackPaint;

    const totalSides = 3.0;
    final currentSide = (progress * totalSides).floor();
    final sideProgress = (progress * totalSides) % 1;

    if (currentSide == 0) {
      // Bottom left to top
      final partialX = bottomLeft.dx + (topPoint.dx - bottomLeft.dx) * sideProgress;
      final partialY = bottomLeft.dy + (topPoint.dy - bottomLeft.dy) * sideProgress;

      progressPath
        ..moveTo(bottomLeft.dx, bottomLeft.dy)
        ..lineTo(partialX, partialY);
    } else if (currentSide == 1) {
      // Top to bottom right (corrected direction)
      progressPath
        ..moveTo(bottomLeft.dx, bottomLeft.dy)
        ..lineTo(topPoint.dx, topPoint.dy)
        ..lineTo(topPoint.dx + (bottomRight.dx - topPoint.dx) * sideProgress,
            topPoint.dy + (bottomRight.dy - topPoint.dy) * sideProgress);
    } else if (currentSide == 2) {
      // Bottom right to bottom left
      progressPath
        ..moveTo(bottomLeft.dx, bottomLeft.dy)
        ..lineTo(topPoint.dx, topPoint.dy)
        ..lineTo(bottomRight.dx, bottomRight.dy)
        ..lineTo(bottomRight.dx + (bottomLeft.dx - bottomRight.dx) * sideProgress,
            bottomRight.dy + (bottomLeft.dy - bottomRight.dy) * sideProgress);
    }

    canvas.drawPath(progressPath, currentPaint);

  }*/
  @override
  void paint(Canvas canvas, Size size) {
    final blackPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    final bluePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    // Define the triangle points
    final topPoint = Offset(size.width / 2, 0);
    final bottomLeft = Offset(0, size.height);
    final bottomRight = Offset(size.width, size.height);

    final trianglePath = Path()
      ..moveTo(bottomLeft.dx, bottomLeft.dy)
      ..lineTo(topPoint.dx, topPoint.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..close();

    // Background painting
    canvas.drawPath(trianglePath, isPrimaryColor ? blackPaint : bluePaint);

    Path progressPath = Path();
    final currentPaint = isPrimaryColor ? bluePaint : blackPaint;

    // Clockwise progression calculation
    const totalSides = 3.0;
    final currentSide = (progress * totalSides).floor();
    final sideProgress = (progress * totalSides) % 1;

    if (currentSide == 0) {
      // Bottom left to top
      final partialX = bottomLeft.dx + (topPoint.dx - bottomLeft.dx) * sideProgress;
      final partialY = bottomLeft.dy + (topPoint.dy - bottomLeft.dy) * sideProgress;

      progressPath
        ..moveTo(bottomLeft.dx, bottomLeft.dy)
        ..lineTo(partialX, partialY);
    } else if (currentSide == 1) {
      // Top to bottom right (corrected direction)
      progressPath
        ..moveTo(bottomLeft.dx, bottomLeft.dy)
        ..lineTo(topPoint.dx, topPoint.dy)
        ..lineTo(topPoint.dx + (bottomRight.dx - topPoint.dx) * sideProgress,
            topPoint.dy + (bottomRight.dy - topPoint.dy) * sideProgress);
    } else if (currentSide == 2) {
      // Bottom right to bottom left
      progressPath
        ..moveTo(bottomLeft.dx, bottomLeft.dy)
        ..lineTo(topPoint.dx, topPoint.dy)
        ..lineTo(bottomRight.dx, bottomRight.dy)
        ..lineTo(bottomRight.dx + (bottomLeft.dx - bottomRight.dx) * sideProgress,
            bottomRight.dy + (bottomLeft.dy - bottomRight.dy) * sideProgress);
    }

    canvas.drawPath(progressPath, currentPaint);
  }

  @override
  bool shouldRepaint(TriangleAnimatorPainter oldDelegate) {
    // return false;
    return oldDelegate.progress != progress ||
        oldDelegate.isPrimaryColor != isPrimaryColor;
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
