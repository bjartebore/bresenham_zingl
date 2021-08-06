import 'dart:math' as math;
import 'package:bresenham_zingl/bresenham_zingl.dart';
import 'line.dart';

void plotCircle(double xm, double ym, double r, SetPixel setPixel) {
  var x = r, y = 0; /* II. quadrant from bottom left to top right */
  int i;
  double x2;
  double e2;
  double err = 2 - 2 * r; /* error of 1.step */
  r = 1 - err;
  for (;;) {
    i = (255 * (err + 2 * (x + y) - 2).abs() / r).round(); /* get blend value of pixel */
    setPixel(xm + x, ym - y, i); /*   I. Quadrant */
    setPixel(xm + y, ym + x, i); /*  II. Quadrant */
    setPixel(xm - x, ym + y, i); /* III. Quadrant */
    setPixel(xm - y, ym - x, i); /*  IV. Quadrant */
    if (x == 0) {
      break;
    }
    e2 = err;
    x2 = x; /* remember values */
    if (err > y) {
      /* x step */
      i = (255 * (err + 2 * x - 1) / r).round(); /* outward pixel */
      if (i < 255) {
        setPixel(xm + x, ym - y + 1, i);
        setPixel(xm + y - 1, ym + x, i);
        setPixel(xm - x, ym + y - 1, i);
        setPixel(xm - y + 1, ym - x, i);
      }
      err -= --x * 2 - 1;
    }
    if (e2 <= x2--) {
      /* y step */
      i = (255 * (1 - 2 * y - e2) / r).round(); /* inward pixel */
      if (i < 255) {
        setPixel(xm + x2, ym - y, i);
        setPixel(xm + y, ym + x2, i);
        setPixel(xm - x2, ym + y, i);
        setPixel(xm - y, ym - x2, i);
      }
      err -= --y * 2 - 1;
    }
  }
}

void plotCircleWidth(double xm, double ym, double r, double th, SetPixel setPixel) {
  plotEllipseRectWidth(xm, ym, xm, ym, th, setPixel);
}

void plotCircle2(int xm, int ym, int r, SetPixel setPixel) {
  int x = r;
  int y = 0; /* II. quadrant from bottom left to top right */
  int i;
  int x2;
  int e2;
  int err = 2 - 2 * r; /* error of 1.step */
  r = 1 - err;
  for (;;) {
    i = (255 * (err + 2 * (x + y) - 2).abs() / r).round(); /* get blend value of pixel */
    setPixel((xm + x).toDouble(), (ym - y).toDouble(), i); /*   I. Quadrant */
    setPixel((xm + y).toDouble(), (ym + x).toDouble(), i); /*  II. Quadrant */
    setPixel((xm - x).toDouble(), (ym + y).toDouble(), i); /* III. Quadrant */
    setPixel((xm - y).toDouble(), (ym - x).toDouble(), i); /*  IV. Quadrant */
    if (x == 0) {
      break;
    }
    e2 = err;
    x2 = x; /* remember values */
    if (err > y) {
      /* x step */
      i = (255 * (err + 2 * x - 1) / r).round(); /* outward pixel */
      if (i < 255) {
        setPixel((xm + x).toDouble(), (ym - y + 1).toDouble(), i);
        setPixel((xm + y - 1).toDouble(), (ym + x).toDouble(), i);
        setPixel((xm - x).toDouble(), (ym + y - 1).toDouble(), i);
        setPixel((xm - y + 1).toDouble(), (ym - x).toDouble(), i);
      }
      err -= --x * 2 - 1;
    }
    if (e2 <= x2--) {
      /* y step */
      i = (255 * (1 - 2 * y - e2) / r).round(); /* inward pixel */
      if (i < 255) {
        setPixel((xm + x2).toDouble(), (ym - y).toDouble(), i);
        setPixel((xm + y).toDouble(), (ym + x2).toDouble(), i);
        setPixel((xm - x2).toDouble(), (ym + y).toDouble(), i);
        setPixel((xm - y).toDouble(), (ym - x2).toDouble(), i);
      }
      err -= --y * 2 - 1;
    }
  }
}

void plotEllipseRectWidth(double x0, double y0, double x1, double y1, double th, SetPixel setPixel) {
  /* draw anti-aliased ellipse inside rectangle with thick line */
  double a = (x1 - x0).abs();
  final double b = (y1 - y0).abs();
  int b1 = b.floor() & 1; /* outer diameter */
  double a2 = a - 2 * th;
  double b2 = b - 2 * th; /* inner diameter */
  double dx = 4 * (a - 1) * b * b;
  double dy = 4 * (b1 - 1) * a * a; /* error increment */
  double i = a + b2;
  double err = b1 * a * a;
  double dx2;
  double dy2;
  double e2;
  double ed;
  /* thick line correction */
  if (th < 1.5) {
    return plotEllipseRectAA(x0, y0, x1, y1, setPixel);
  }
  if ((th - 1) * (2 * b - th) > a * a) {
    b2 = math.sqrt(a * (b - a) * i * a2) / (a - th);
  }
  if ((th - 1) * (2 * a - th) > b * b) {
    a2 = math.sqrt(b * (a - b) * i * b2) / (b - th);
    th = (a - a2) / 2;
  }
  if (a == 0 || b == 0) {
    return plotLine(x0, y0, x1, y1, setPixel);
  }
  if (x0 > x1) {
    x0 = x1;
    x1 += a;
  } /* if called with swapped points */
  if (y0 > y1) {
    y0 = y1; /* .. exchange them */
  }
  if (b2 <= 0) {
    th = a; /* filled ellipse */
  }
  e2 = th - th.floor();
  th = x0 + th - e2;
  dx2 = 4 * (a2 + 2 * e2 - 1) * b2 * b2;
  dy2 = 4 * (b1 - 1) * a2 * a2;
  e2 = dx2 * e2;
  y0 += (b.floor() + 1) >> 1;
  y1 = y0 - b1; /* starting pixel */
  a = 8 * a * a;
  b1 = 8 * b.floor() * b.floor();
  a2 = 8 * a2 * a2;
  b2 = 8 * b2 * b2;

  do {
    for (;;) {
      if (err < 0 || x0 > x1) {
        i = x0;
        break;
      }
      i = math.min(dx, dy);
      ed = math.max(dx, dy);
      if (y0 == y1 + 1 && 2 * err > dx && a > b1) {
        ed = a / 4; /* x-tip */
      } else {
        ed += 2 * ed * i * i / (4 * ed * ed + i * i + 1) + 1; /* approx ed=sqrt(dx*dx+dy*dy) */
      }

      i = 255 * err / ed; /* outside anti-aliasing */
      setPixel(x0, y0, i.round());
      setPixel(x0, y1, i.round());
      setPixel(x1, y0, i.round());
      setPixel(x1, y1, i.round());
      if (err + dy + a < dx) {
        i = x0 + 1;
        break;
      }
      x0++;
      x1--;
      err -= dx;
      dx -= b1; /* x error increment */
    }
    for (; i < th && 2 * i <= x0 + x1; i++) {
      /* fill line pixel */
      setPixel(i, y0);
      setPixel(x0 + x1 - i, y0);
      setPixel(i, y1);
      setPixel(x0 + x1 - i, y1);
    }
    while (e2 > 0 && x0 + x1 >= 2 * th) {
      /* inside anti-aliasing */
      i = math.min(dx2, dy2);
      ed = math.max(dx2, dy2);
      if (y0 == y1 + 1 && 2 * e2 > dx2 && a2 > b2) {
        ed = a2 / 4; /* x-tip */
      } else {
        ed += 2 * ed * i * i / (4 * ed * ed + i * i); /* approximation */
      }
      i = 255 - 255 * e2 / ed; /* get intensity value by pixel error */
      setPixel(th, y0, i.round());
      setPixel(x0 + x1 - th, y0, i.round());
      setPixel(th, y1, i.round());
      setPixel(x0 + x1 - th, y1, i.round());
      if (e2 + dy2 + a2 < dx2) {
        break;
      }
      th++;
      e2 -= dx2;
      dx2 -= b2; /* x error increment */
    }
    e2 += dy2 += a2;
    y0++;
    y1--;
    err += dy += a; /* y step */
  } while (x0 < x1);

  if (y0 - y1 <= b) {
    if (err > dy + a) {
      y0--;
      y1++;
      err -= dy -= a;
    }
    for (; y0 - y1 <= b; err += dy += a) {
      /* too early stop of flat ellipses */
      i = 255 * 4 * err / b1; /* -> finish tip of ellipse */
      setPixel(x0, y0, i.round());
      setPixel(x1, y0++, i.round());
      setPixel(x0, y1, i.round());
      setPixel(x1, y1--, i.round());
    }
  }
}

void plotEllipseRectAA(double x0, double y0, double x1, double y1, SetPixel setPixel) {
  /* draw a black anti-aliased rectangular ellipse on white background */
  double a = (x1 - x0).abs();
  final double b = (y1 - y0).abs();
  int b1 = b.floor() & 1; /* diameter */
  double dx = 4 * (a - 1) * b * b;
  double dy = 4 * (b1 + 1) * a * a; /* error increment */
  double ed;
  double i;
  var err = b1 * a * a - dx + dy; /* error of 1.step */

  if (a == 0 || b == 0) {
    return plotLine(x0, y0, x1, y1, setPixel);
  }
  if (x0 > x1) {
    x0 = x1;
    x1 += a;
  } /* if called with swapped points */
  if (y0 > y1) {
    y0 = y1; /* .. exchange them */
  }
  y0 += (b.floor() + 1) >> 1;
  y1 = y0 - b1; /* starting pixel */
  a = 8 * a * a;
  b1 = 8 * b.floor() * b.floor();

  for (;;) {
    /* approximate ed=Math.sqrt(dx*dx+dy*dy) */
    i = math.min(dx, dy);
    ed = math.max(dx, dy);
    if (y0 == y1 + 1 && err > dy && a > b1) {
      ed = 255 * 4 / a; /* x-tip */
    } else {
      ed = 255 / (ed + 2 * ed * i * i / (4 * ed * ed + i * i)); /* approximation */
    }

    i = ed * (err + dx - dy).abs(); /* get intensity value by pixel err */
    setPixel(x0, y0, i.round());
    setPixel(x0, y1, i.round());
    setPixel(x1, y0, i.round());
    setPixel(x1, y1, i.round());

    final bool f = 2 * err + dy >= 0;
    if (f) {
      /* x step, remember condition */
      if (x0 >= x1) {
        break;
      }
      i = ed * (err + dx);
      if (i < 256) {
        setPixel(x0, y0 + 1, i.round());
        setPixel(x0, y1 - 1, i.round());
        setPixel(x1, y0 + 1, i.round());
        setPixel(x1, y1 - 1, i.round());
      } /* do error increment later since values are still needed */
    }
    if (2 * err <= dx) {
      /* y step */
      i = ed * (dy - err);
      if (i < 256) {
        setPixel(x0 + 1, y0, i.round());
        setPixel(x1 - 1, y0, i.round());
        setPixel(x0 + 1, y1, i.round());
        setPixel(x1 - 1, y1, i.round());
      }
      y0++;
      y1--;
      err += dy += a;
    }
    if (f) {
      x0++;
      x1--;
      err -= dx -= b1;
    } /* x error increment */
  }
  if (--x0 == x1++) {
    /* too early stop of flat ellipses */
    while (y0 - y1 < b) {
      i = 255 * 4 * (err + dx).abs() / b1; /* -> finish tip of ellipse */
      setPixel(x0, ++y0, i.round());
      setPixel(x1, y0, i.round());
      setPixel(x0, --y1, i.round());
      setPixel(x1, y1, i.round());
      err += dy += a;
    }
  }
}
