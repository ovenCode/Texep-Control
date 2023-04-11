import 'dart:math';
import 'dart:developer' as logger show log;

import 'package:flutter/material.dart';

class RadialIndicator extends StatefulWidget {
  final double height, width, _start, _end;
  final Color primaryColor, secondaryColor;
  final String _text;

  const RadialIndicator(
      {super.key,
      this.height = 200,
      this.width = 200,
      this.primaryColor = Colors.deepPurple,
      this.secondaryColor = Colors.white,
      required double start,
      required double end,
      String text = "no value"})
      : _start = start,
        _end = end,
        _text = text;

  @override
  State<RadialIndicator> createState() => _RadialIndicatorState();
}

class _RadialIndicatorState extends State<RadialIndicator> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return SizedBox(
          height: widget.height,
          width: widget.width,
          child: Container(
            color: widget.secondaryColor,
            child: CustomPaint(
              painter: _RadialIndicatorPainter(
                  start: widget._start,
                  end: widget._end,
                  radius: widget.height,
                  paintBrush: Paint()..color = widget.primaryColor),
              child: Container(
                margin: EdgeInsets.all(widget.height * 0.15),
                decoration: BoxDecoration(
                  color: widget.secondaryColor,
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text(widget._text)),
              ),
            ),
          ));
    } catch (e) {
      logger.log("RadialIndicator::build:Error: ${e.toString()}");
      throw Exception();
    }
  }
}

class _RadialIndicatorPainter extends CustomPainter {
  final double _start, _end, _radius;
  final Paint paintBrush;
  _RadialIndicatorPainter(
      {required start, required end, required radius, required this.paintBrush})
      : _start = start,
        _end = end,
        _radius = radius;
  @override
  void addListener(VoidCallback listener) {
    // TODO: implement addListener
  }

  @override
  bool? hitTest(Offset position) => null;

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint

    Path cone = Path()
      ..moveTo(_radius, _radius)
      ..arcTo(
          Rect.fromCircle(center: Offset(_radius, _radius), radius: _radius),
          _start,
          _end,
          false)
      ..close();
    double radius = min(size.width / 2, size.height / 2);

    canvas.drawArc(
        Rect.fromCircle(
            center: Offset(size.width / 2, size.height / 2), radius: radius),
        _start * pi / 180,
        _end * pi / 180,
        true,
        paintBrush);
  }

  @override
  void removeListener(VoidCallback listener) {
    // TODO: implement removeListener
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return oldDelegate != this;
  }
}
