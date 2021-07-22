library bresenham_zingl;

export 'package:curve/curve.dart';
export 'bezier/cubic.dart' show plotCubicBezier;
export 'line.dart';

typedef SetPixel = void Function(double, double, [int]);
