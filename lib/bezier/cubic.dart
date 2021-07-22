// Dart imports:
import 'dart:math' as math;

// Package imports:
import 'package:curve/curve.dart';

// Project imports:
import 'package:bresenham_zingl/bresenham_zingl.dart';

void plotCubicBezier(
  Curve curve,
  SetPixel setPixel, {
  int width = 1,
}) {
  double x0 = curve.point1.x;
  double y0 = curve.point1.y;
  final double x1 = curve.handle1.x;
  final double y1 = curve.handle1.y;
  final double x2 = curve.handle2.x;
  final double y2 = curve.handle2.y;
  double x3 = curve.point2.x;
  double y3 = curve.point2.y;

  /* plot any cubic Bezier curve */
  int n = 0;
  double i = 0;
  final double xc = x0 + x1 - x2 - x3;
  final double xa = xc - 4 * (x1 - x2);
  final double xb = x0 - x1 - x2 + x3;
  final double xd = xb + 4 * (x1 + x2);
  final double yc = y0 + y1 - y2 - y3;
  final double ya = yc - 4 * (y1 - y2);
  final double yb = y0 - y1 - y2 + y3;
  final double yd = yb + 4 * (y1 + y2);
  double fx0 = x0, fx1, fx2, fx3;
  double fy0 = y0, fy1, fy2, fy3;
  double t1 = xb * xb - xa * xc, t2;
  final List<double?> t = List.generate(7, (index) => null);
  /* sub-divide curve at gradient sign changes */
  if (xa == 0) {
    /* horizontal */
    if (xc.abs() < 2 * xb.abs()) {
      t[n++] = xc / (2.0 * xb); /* one change */
    }
  } else if (t1 > 0.0) {
    /* two changes */
    t2 = math.sqrt(t1);
    t1 = (xb - t2) / xa;
    if (t1.abs() < 1.0) {
      t[n++] = t1;
    }
    t1 = (xb + t2) / xa;
    if (t1.abs() < 1.0) {
      t[n++] = t1;
    }
  }
  t1 = yb * yb - ya * yc;
  if (ya == 0) {
    /* vertical */
    if (yc.abs() < 2 * yb.abs()) {
      t[n++] = yc / (2.0 * yb); /* one change */
    }
  } else if (t1 > 0.0) {
    /* two changes */
    t2 = math.sqrt(t1);
    t1 = (yb - t2) / ya;
    if (t1.abs() < 1.0) {
      t[n++] = t1;
    }
    t1 = (yb + t2) / ya;
    if (t1.abs() < 1.0) {
      t[n++] = t1;
    }
  }
  t1 = 2 * (xa * yb - xb * ya);
  t2 = xa * yc - xc * ya; /* divide at inflection point */
  i = t2 * t2 - 2 * t1 * (xb * yc - xc * yb);
  if (i > 0) {
    i = math.sqrt(i);
    t[n] = (t2 + i) / t1;
    if (t[n]!.abs() < 1.0) {
      n++;
    }
    t[n] = (t2 - i) / t1;
    if (t[n]!.abs() < 1.0) {
      n++;
    }
  }
  for (int i = 1; i < n; i++) {
    /* bubble sort of 4 points */
    if ((t1 = t[i - 1]!) > t[i]!) {
      t[i - 1] = t[i];
      t[i] = t1;
      i = 0;
    }
  }
  t1 = -1.0;
  t[n] = 1.0; /* begin / end points */
  for (int i = 0; i <= n; i++) {
    /* plot each segment separately */
    t2 = t[i]!; /* sub-divide at t[i-1], t[i] */
    fx1 = (t1 * (t1 * xb - 2 * xc) - t2 * (t1 * (t1 * xa - 2 * xb) + xc) + xd) / 8 - fx0;
    fy1 = (t1 * (t1 * yb - 2 * yc) - t2 * (t1 * (t1 * ya - 2 * yb) + yc) + yd) / 8 - fy0;
    fx2 = (t2 * (t2 * xb - 2 * xc) - t1 * (t2 * (t2 * xa - 2 * xb) + xc) + xd) / 8 - fx0;
    fy2 = (t2 * (t2 * yb - 2 * yc) - t1 * (t2 * (t2 * ya - 2 * yb) + yc) + yd) / 8 - fy0;
    fx0 -= fx3 = (t2 * (t2 * (3 * xb - t2 * xa) - 3 * xc) + xd) / 8;
    fy0 -= fy3 = (t2 * (t2 * (3 * yb - t2 * ya) - 3 * yc) + yd) / 8;
    x3 = (fx3 + 0.5).floorToDouble();
    y3 = (fy3 + 0.5).floorToDouble(); /* scale bounds */
    if (fx0 != 0.0) {
      fx1 *= fx0 = (x0 - x3) / fx0;
      fx2 *= fx0;
    }
    if (fy0 != 0.0) {
      fy1 *= fy0 = (y0 - y3) / fy0;
      fy2 *= fy0;
    }
    if (x0 != x3 || y0 != y3) {
      /* segment t1 - t2 */
      _plotCubicBezierSegWidth(
        Curve.fromList([
          [x0, y0],
          [x0 + fx1, y0 + fy1],
          [x0 + fx2, y0 + fy2],
          [x3, y3]
        ]),
        width,
        setPixel,
      );
    }
    x0 = x3;
    y0 = y3;
    fx0 = fx3;
    fy0 = fy3;
    t1 = t2;
  }
}

void _plotCubicBezierSegWidth(
  Curve curve,
  int width,
  SetPixel setPixel,
) {
  for (final qCurve in curve.toQuadraticCurve()) {
    _plotQuadRationalBezierSegAA(
      qCurve,
      1,
      setPixel,
      width: width,
    );
  }
}

void _plotQuadRationalBezierSegAA(
  QuadraticCurve curve,
  double w,
  SetPixel setPixel, {
  int width = 1,
}) {
  double x0 = curve.point1.x;
  double y0 = curve.point1.y;
  double x1 = curve.handle1.x;
  double y1 = curve.handle1.y;
  double x2 = curve.point2.x;
  double y2 = curve.point2.y;

  /* plot a limited rational Bezier segment of thickness th, squared weight */
  double sx = x2 - x1;
  double sy = y2 - y1; /* relative values for checks */
  double dx = x0 - x2;
  double dy = y0 - y2;
  double xx = x0 - x1;
  double yy = y0 - y1;
  double xy = xx * sy + yy * sx;
  double cur = xx * sy - yy * sx;
  double err;
  double e2;
  double ed; /* curvature */

  assert(xx * sx <= 0.0 && yy * sy <= 0.0); /* sign of gradient must not change */

  if (cur != 0.0 && w > 0.0) {
    /* no straight line */
    if (sx * sx + sy * sy > xx * xx + yy * yy) {
      /* begin with longer part */
      x2 = x0;
      x0 -= dx;
      y2 = y0;
      y0 -= dy;
      cur = -cur; /* swap P0 P2 */
    }
    xx = 2.0 * (4.0 * w * sx * xx + dx * dx); /* differences 2nd degree */
    yy = 2.0 * (4.0 * w * sy * yy + dy * dy);
    sx = x0 < x2 ? 1 : -1; /* x step direction */
    sy = y0 < y2 ? 1 : -1; /* y step direction */
    xy = -2.0 * sx * sy * (2.0 * w * xy + dx * dy);

    if (cur * sx * sy < 0) {
      /* negated curvature? */
      xx = -xx;
      yy = -yy;
      cur = -cur;
      xy = -xy;
    }
    dx = 4.0 * w * (x1 - x0) * sy * cur + xx / 2.0; /* differences 1st degree */
    dy = 4.0 * w * (y0 - y1) * sx * cur + yy / 2.0;

    if (w < 0.5 && (dx + xx <= 0 || dy + yy >= 0)) {
      /* flat ellipse, algo fails */
      cur = (w + 1.0) / 2.0;
      w = math.sqrt(w);
      xy = 1.0 / (w + 1.0);
      sx = ((x0 + 2.0 * w * x1 + x2) * xy / 2.0 + 0.5).floorToDouble(); /* subdivide curve  */
      sy = ((y0 + 2.0 * w * y1 + y2) * xy / 2.0 + 0.5).floorToDouble(); /* plot separately */
      dx = ((w * x1 + x0) * xy + 0.5).floorToDouble();
      dy = ((y1 * w + y0) * xy + 0.5).floorToDouble();
      _plotQuadRationalBezierSegAA(
        QuadraticCurve.fromList([
          [x0, y0],
          [dx, dy],
          [sx, sy]
        ]),
        cur,
        setPixel,
        width: 1,
      );
      dx = ((w * x1 + x2) * xy + 0.5).floorToDouble();
      dy = ((y1 * w + y2) * xy + 0.5).floorToDouble();
      return _plotQuadRationalBezierSegAA(
        QuadraticCurve.fromList([
          [sx, sy],
          [dx, dy],
          [x2, y2]
        ]),
        cur,
        setPixel,
        width: 1,
      );
    }
    fail:
    for (err = 0; dy + 2 * yy < 0 && dx + 2 * xx > 0;) {
      /* loop of steep/flat curve */
      if (dx + dy + xy < 0) {
        /* steep curve */
        do {
          ed = -dy - 2 * dy * dx * dx / (4.0 * dy * dy + dx * dx); /* approximate sqrt */
          w = (width - 1) * ed; /* scale line width */
          x1 = ((err - ed - w / 2) / dy).floorToDouble(); /* start offset */
          e2 = err - x1 * dy - w / 2; /* error value at offset */
          x1 = x0 - x1 * sx; /* start point */
          setPixel(x1, y0, (255 * e2 / ed).round()); /* aliasing pre-pixel */
          for (e2 = -w - dy - e2; e2 - dy < ed; e2 -= dy) {
            setPixel(x1 += sx, y0); /* pixel on thick line */
          }
          setPixel(x1 + sx, y0, (255 * e2 / ed).round()); /* aliasing post-pixel */
          if (y0 == y2) {
            return; /* last pixel -> curve finished */
          }
          y0 += sy;
          dy += xy;
          err += dx;
          dx += xx; /* y step */
          if (2 * err + dy > 0) {
            /* e_x+e_xy > 0 */
            x0 += sx;
            dx += xy;
            err += dy;
            dy += yy; /* x step */
          }
          if (x0 != x2 && (dx + 2 * xx <= 0 || dy + 2 * yy >= 0)) {
            if ((y2 - y0).abs() > (x2 - x0).abs()) {
              break fail;
            }
            break;
            /* other curve near */
          }
        } while (dx + dy + xy < 0); /* gradient still steep? */
        /* change from steep to flat curve */

        cur = err - dy - w / 2;
        y1 = y0;
        for (; cur < ed; y1 += sy, cur += dx) {
          e2 = cur;
          x1 = x0;
          for (; e2 - dy < ed; e2 -= dy) {
            setPixel(x1 -= sx, y1); /* pixel on thick line */
          }
          setPixel(x1 - sx, y1, (255 * e2 / ed).round()); /* aliasing post-pixel */
        }
      } else {
        /* flat curve */
        do {
          ed = dx + 2 * dx * dy * dy / (4.0 * dx * dx + dy * dy); /* approximate sqrt */
          w = (width - 1) * ed; /* scale line width */
          y1 = ((err + ed + w / 2) / dx).floorToDouble(); /* start offset */
          e2 = y1 * dx - w / 2 - err; /* error value at offset */
          y1 = y0 - y1 * sy; /* start point */
          setPixel(x0, y1, (255 * e2 / ed).round()); /* aliasing pre-pixel */
          for (e2 = dx - e2 - w; e2 + dx < ed; e2 += dx) {
            setPixel(x0, y1 += sy); /* pixel on thick line */
          }
          setPixel(x0, y1 + sy, (255 * e2 / ed).round()); /* aliasing post-pixel */
          if (x0 == x2) {
            return; /* last pixel -> curve finished */
          }
          x0 += sx;
          dx += xy;
          err += dy;
          dy += yy; /* x step */
          if (2 * err + dx < 0) {
            /* e_y+e_xy < 0 */
            y0 += sy;
            dy += xy;
            err += dx;
            dx += xx; /* y step */
          }
          if (y0 != y2 && (dx + 2 * xx <= 0 || dy + 2 * yy >= 0)) {
            if ((y2 - y0).abs() <= (x2 - x0).abs()) {
              break fail;
            }
            break;
          } /* other curve near */
        } while (dx + dy + xy >= 0); /* gradient still flat? */
        /* change from flat to steep curve */

        cur = -err + dx - w / 2;
        x1 = x0;

        for (; cur < ed; x1 += sx, cur -= dy) {
          e2 = cur;
          y1 = y0;
          for (; e2 + dx < ed; e2 += dx) {
            setPixel(x1, y1 -= sy); /* pixel on thick line */
          }

          setPixel(x1, y1 - sy, (255 * e2 / ed).round()); /* aliasing post-pixel */
        }
      }
    }
  }
  plotLine(x0, y0, x2, y2, setPixel, width: width); /* confusing error values  */
}
