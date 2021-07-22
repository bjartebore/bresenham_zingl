// Dart imports:
import 'dart:math' as math;

// Project imports:
import 'package:bresenham_zingl/bresenham_zingl.dart';

void plotLine(
  double x0,
  double y0,
  double x1,
  double y1,
  SetPixel setPixel, {
  int width = 1,
}) {
  /* plot an anti-aliased line of width th pixel */
  double dx = (x1 - x0).abs();
  final double sx = x0 < x1 ? 1 : -1;
  double dy = (y1 - y0).abs();
  final double sy = y0 < y1 ? 1 : -1;
  double err;
  double e2 = math.sqrt(dx * dx + dy * dy); /* length */

  if (width <= 1 || e2 == 0) {
    return _plotLineAA(x0, y0, x1, y1, setPixel); /* assert */
  }
  dx *= 255 / e2;
  dy *= 255 / e2;
  width = 255 * (width - 1); /* scale values */

  if (dx < dy) {
    /* steep line */
    x1 = ((e2 + width / 2) / dy).roundToDouble(); /* start offset */
    err = x1 * dy - width / 2; /* shift error value to offset width */
    for (x0 -= x1 * sx;; y0 += sy) {
      setPixel(x1 = x0, y0, err.round()); /* aliasing pre-pixel */
      for (e2 = dy - err - width; e2 + dy < 255; e2 += dy) {
        setPixel(x1 += sx, y0); /* pixel on the line */
      }
      setPixel(x1 + sx, y0, e2.round()); /* aliasing post-pixel */
      if (y0 == y1) {
        break;
      }
      err += dx; /* y-step */
      if (err > 255) {
        err -= dy;
        x0 += sx;
      } /* x-step */
    }
  } else {
    /* flat line */
    y1 = ((e2 + width / 2) / dx).roundToDouble(); /* start offset */
    err = y1 * dx - width / 2; /* shift error value to offset width */
    for (y0 -= y1 * sy;; x0 += sx) {
      setPixel(x0, y1 = y0, err.round()); /* aliasing pre-pixel */
      for (e2 = dx - err - width; e2 + dx < 255; e2 += dx) {
        setPixel(x0, y1 += sy); /* pixel on the line */
      }
      setPixel(x0, y1 + sy, e2.round()); /* aliasing post-pixel */
      if (x0 == x1) {
        break;
      }
      err += dy; /* x-step */
      if (err > 255) {
        err -= dx;
        y0 += sy;
      } /* y-step */
    }
  }
}

void _plotLineAA(double x0, double y0, double x1, double y1, SetPixel setPixel) {
  /* draw a black (0) anti-aliased line on white (255) background */
  final double dx = (x1 - x0).abs();
  final double sx = x0 < x1 ? 1 : -1;
  final double dy = (y1 - y0).abs();
  final double sy = y0 < y1 ? 1 : -1;
  double err = dx - dy;
  double e2;
  double x2; /* error value e_xy */
  final double ed = dx + dy == 0 ? 1 : math.sqrt(dx * dx + dy * dy);

  for (;;) {
    /* pixel loop */
    setPixel(x0, y0, (255 * (err - dx + dy).abs() / ed).round());
    e2 = err;
    x2 = x0;
    if (2 * e2 >= -dx) {
      /* x step */
      if (x0 == x1) {
        break;
      }
      if (e2 + dy < ed) {
        setPixel(x0, y0 + sy, (255 * (e2 + dy) / ed).round());
      }
      err -= dy;
      x0 += sx;
    }
    if (2 * e2 <= dy) {
      /* y step */
      if (y0 == y1) {
        break;
      }
      if (dx - e2 < ed) {
        setPixel(x2 + sx, y0, (255 * (dx - e2) / ed).round());
      }
      err += dx;
      y0 += sy;
    }
  }
}
