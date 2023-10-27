
import 'dart:ui';

import 'package:flutter/material.dart';

class Paths {
  Paths._();

  static Path buildSquareFatLegs(Size size, double radius){
    final p = Path();

    final pa = radius;
    final start = size.topLeft(Offset(pa, pa));

    p.moveTo(start.dx, start.dy);

    final leftOff1 = Offset(0, size.height/2);
    final leftOff2 = Offset(start.dx, size.height - pa);

    p.quadraticBezierTo(leftOff1.dx, leftOff1.dy, leftOff2.dx, leftOff2.dy);

    final bottomOff1 = Offset(size.width/2, size.height);
    final bottomOff2 = Offset(size.width - pa, leftOff2.dy);

    p.quadraticBezierTo(bottomOff1.dx, bottomOff1.dy, bottomOff2.dx, bottomOff2.dy);

    final rightOff1 = Offset(size.width, leftOff1.dy);
    final rightOff2 = Offset(bottomOff2.dx, pa);

    p.quadraticBezierTo(rightOff1.dx, rightOff1.dy, rightOff2.dx, rightOff2.dy);

    final topOff1 = Offset(bottomOff1.dx, 0);
    //final topOff2 = Offset(start.dx, size.height);

    p.quadraticBezierTo(topOff1.dx, topOff1.dy, start.dx, start.dy);

    return p;
  }

  static Path buildSquareFatSide(Size size, double radius){
    final path = Path();

    final pa = radius;
    path.moveTo(size.width, size.height / 2);

    path.cubicTo(size.width, size.height,
        size.width - pa, size.height,
        size.width /2, size.height);

    path.cubicTo( pa, size.height,
        0, size.height,
        0, size.height / 2);

    path.cubicTo(0, 0,
        pa , 0,
        size.width /2, 0);

    path.cubicTo(size.width - pa, 0,
        size.width , 0,
        size.width, size.height / 2);

    return path;
  }

  static Path buildSquareFatSideCorner(Size size, double radius, double corner){
    final path = Path();
    final pa = radius;

    path.moveTo(size.width, size.height / 2);

    path.cubicTo(size.width, size.height -corner,
        size.width - pa, size.height,
        size.width /2, size.height);

    path.cubicTo( pa, size.height,
        0, size.height -corner,
        0, size.height / 2);

    path.cubicTo(0, corner,
        pa , 0,
        size.width /2, 0);

    path.cubicTo(size.width - corner, 0,
        size.width , pa,
        size.width, size.height / 2);

    return path;
  }
}
///=============================================================================
class DashLinePainter extends CustomPainter {
  final double progress;

  DashLinePainter({required this.progress});

  Paint _paint = Paint()
    ..color = Colors.black
    ..strokeWidth = 4.0
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path()
      ..moveTo(0, size.height / 2)
      ..lineTo(size.width * progress, size.height / 2);

    Path dashPath = Path();

    double dashWidth = 10.0;
    double dashSpace = 5.0;
    double distance = 0.0;

    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth;
        distance += dashSpace;
      }
    }
    canvas.drawPath(dashPath, _paint);
  }

  @override
  bool shouldRepaint(DashLinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
///=============================================================================

typedef PathBuilder = Path Function(Size size);

class PathClipper extends CustomClipper<Path> {
  final PathBuilder builder;
  bool reBuild = true;

  PathClipper({required this.builder, this.reBuild = true});

  @override
  Path getClip(Size size) {
    return builder.call(size);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return reBuild;
  }

}