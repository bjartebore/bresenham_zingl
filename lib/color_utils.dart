// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';

extension ColorUtils on Color {
  Color applyOverlayColor(Color overlayColor) {
    if (alpha < 255) {
      throw Exception('the fromColor should not have any form of opacity');
    }

    final int r2 = overlayColor.red;
    final int g2 = overlayColor.green;
    final int b2 = overlayColor.blue;
    final double a2 = overlayColor.alpha / 255;

    final int r = ((a2 * r2) + ((1.0 - a2) * red)).round().clamp(0, 255);
    final int g = ((a2 * g2) + ((1.0 - a2) * green)).round().clamp(0, 255);
    final int b = ((a2 * b2) + ((1.0 - a2) * blue)).round().clamp(0, 255);

    return Color.fromRGBO(r, g, b, 1);
  }
}
