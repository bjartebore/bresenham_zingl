import 'dart:math' as math;
import 'package:bresenham_zingl/bresenham_zingl.dart';

/*
 * Line segment rasterisation
 * @param  {number} x0
 * @param  {number} y0
 * @param  {number} x1
 * @param  {number} y1
 * @param  {setPixel} setPixel
 */
void line(
  double x0,
  double y0,
  double x1,
  double y1,
  SetPixel setPixel,
) {
  final double dx = (x1 - x0).floorToDouble(), sx = x0 < x1 ? 1 : -1;
  final double dy = -(y1 - y0).floorToDouble(), sy = y0 < y1 ? 1 : -1;
  double err = dx + dy, e2; /* error value e_xy */

  for (;;) {
    /* loop */
    setPixel(x0, y0);
    e2 = 2 * err;
    if (e2 >= dy) {
      /* e_xy+e_x > 0 */
      if (x0 == x1) {
        break;
      }
      err += dy;
      x0 += sx;
    }
    if (e2 <= dx) {
      /* e_xy+e_y < 0 */
      if (y0 == y1) {
        break;
      }
      err += dx;
      y0 += sy;
    }
  }
}

/*
 * Draw a black (0) anti-aliased line on white (255) background
 * @param  {number} x0
 * @param  {number} y0
 * @param  {number} x1
 * @param  {number} y1
 * @param  {setPixelAlpha} setPixelAA
 * @return {number}
 */
void lineAA(double x0, double y0, double x1, double y1, SetPixel setPixelAA) {
  final double sx = x0 < x1 ? 1 : -1;
  final double sy = y0 < y1 ? 1 : -1;
  double x2;
  double dx = (x1 - x0).abs(), dy = (y1 - y0).abs(), err = dx * dx + dy * dy;
  double e2 = err == 0 ? 1 : 0xffff7f / math.sqrt(err); /* multiplication factor */

  dx *= e2;
  dy *= e2;
  err = dx - dy; /* error value e_xy */
  for (;;) {
    /* pixel loop */
    setPixelAA(x0, y0, (err - dx + dy).abs().toInt() >> 16);
    e2 = err;
    x2 = x0;
    if (2 * e2 >= -dx) {
      /* x step */
      if (x0 == x1) {
        break;
      }
      if (e2 + dy < 0xff0000) {
        setPixelAA(x0, y0 + sy, (e2 + dy).toInt() >> 16);
      }
      err -= dy;
      x0 += sx;
    }
    if (2 * e2 <= dy) {
      /* y step */
      if (y0 == y1) {
        break;
      }
      if (dx - e2 < 0xff0000) {
        setPixelAA(x2 + sx, y0, (dx - e2).toInt() >> 16);
      }
      err += dx;
      y0 += sy;
    }
  }
}

/*
 * Plot an anti-aliased line of width wd
 * @param  {number} x0
 * @param  {number} y0
 * @param  {number} x1
 * @param  {number} y1
 * @param  {number} wd
 * @param  {setPixel} setPixel
 */
void lineWidth(
  double x0,
  double y0,
  double x1,
  double y1,
  double wd,
  SetPixel setPixel,
) {
  final double dx = (x1 - x0).abs();
  final double sx = x0 < x1 ? 1 : -1;
  final double dy = (y1 - y0).abs();
  final double sy = y0 < y1 ? 1 : -1;
  double err = dx - dy, e2, x2; /* error value e_xy */
  final double ed = dx + dy == 0 ? 1 : math.sqrt(dx * dx + dy * dy);

  for (wd = (wd + 1) / 2;;) {
    /* pixel loop */
    setPixel(x0, y0, math.max(0, 255 * ((err - dx + dy).abs() / ed - wd + 1).toInt()));
    e2 = err;
    x2 = x0;
    if (2 * e2 >= -dx) {
      /* x step */
      e2 += dy;
      double y2 = y0;
      for (; e2 < ed * wd && (y1 != y2 || dx > dy); e2 += dx) {
        e2 += dy;
        y2 = y0;
        setPixel(x0, y2 += sy, math.max(0, 255 * (e2.abs() / ed - wd + 1)).toInt());
      }

      if (x0 == x1) {
        break;
      }
      e2 = err;
      err -= dy;
      x0 += sx;
    }
    if (2 * e2 <= dy) {
      /* y step */
      for (e2 = dx - e2; e2 < ed * wd && (x1 != x2 || dx < dy); e2 += dy) {
        setPixel(x2 += sx, y0, math.max(0, 255 * (e2.abs() / ed - wd + 1)).toInt());
      }
      if (y0 == y1) {
        break;
      }
      err += dx;
      y0 += sy;
    }
  }
}
