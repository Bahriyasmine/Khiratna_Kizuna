import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:khiratna_frontend/model/marketforecast/product_series.dart';

const kConsumptionColor = Color(0xFFD32F2F);
const kProductionColor = Color(0xFF2E7D32);

class LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const LegendDot({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class ForecastChart extends StatelessWidget {
  final ProductSeries series;
  const ForecastChart({super.key, required this.series});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.infinite, painter: _ChartPainter(series));
  }
}

class _ChartPainter extends CustomPainter {
  final ProductSeries s;
  _ChartPainter(this.s);

  @override
  void paint(Canvas canvas, Size size) {
    const left = 46.0, right = 14.0, top = 10.0, bottom = 26.0;
    final w = size.width - left - right;
    final h = size.height - top - bottom;
    final n = s.years.length;
    if (n < 2 || w <= 0 || h <= 0) return;

    var maxVal = [...s.consumption, ...s.production].reduce(math.max);
    if (maxVal <= 0) maxVal = 1;
    final step = _niceStep(maxVal / 4);
    final ticks = (maxVal / step).ceil();
    final maxY = step * ticks;

    double x(int i) => left + w * i / (n - 1);
    double y(double v) => top + h * (1 - v / maxY);

    final grid = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;
    for (var t = 0; t <= ticks; t++) {
      final v = step * t;
      canvas.drawLine(Offset(left, y(v)), Offset(left + w, y(v)), grid);
      _label(canvas, _fmt(v), Offset(left - 6, y(v)), alignRight: true);
    }

    for (var i = 0; i < n; i += 3) {
      _label(canvas, '${s.years[i]}', Offset(x(i), top + h + 6), center: true);
    }

    _drawSeries(canvas, s.consumption, kConsumptionColor, x, y);
    _drawSeries(canvas, s.production, kProductionColor, x, y);
  }

  void _drawSeries(
    Canvas canvas,
    List<double> v,
    Color color,
    double Function(int) x,
    double Function(double) y,
  ) {
    final real = s.lastRealIndex;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // solid = real data
    final solid = Path()..moveTo(x(0), y(v[0]));
    for (var i = 1; i <= real; i++) {
      solid.lineTo(x(i), y(v[i]));
    }
    canvas.drawPath(solid, paint);

    // dashed = forecast
    if (real < v.length - 1) {
      final dashed = Path()..moveTo(x(real), y(v[real]));
      for (var i = real + 1; i < v.length; i++) {
        dashed.lineTo(x(i), y(v[i]));
      }
      _drawDashed(canvas, dashed, paint);
    }

    final dot = Paint()..color = color;
    for (var i = 0; i < v.length; i++) {
      canvas.drawCircle(Offset(x(i), y(v[i])), 2.5, dot);
    }
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    for (final m in path.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, math.min(d + 6, m.length)), paint);
        d += 11;
      }
    }
  }

  void _label(
    Canvas canvas,
    String text,
    Offset at, {
    bool alignRight = false,
    bool center = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final Offset o;
    if (alignRight) {
      o = Offset(at.dx - tp.width, at.dy - tp.height / 2);
    } else if (center) {
      o = Offset(at.dx - tp.width / 2, at.dy);
    } else {
      o = at;
    }
    tp.paint(canvas, o);
  }

  double _niceStep(double raw) {
    final mag = math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
    final n = raw / mag;
    final nice = n <= 1 ? 1 : n <= 2 ? 2 : n <= 5 ? 5 : 10;
    return nice * mag;
  }

  String _fmt(double v) {
    if (v >= 1e6) {
      final m = v / 1e6;
      return '${m == m.roundToDouble() ? m.round() : m.toStringAsFixed(1)}M';
    }
    if (v >= 1e3) {
      final k = v / 1e3;
      return '${k == k.roundToDouble() ? k.round() : k.toStringAsFixed(1)}K';
    }
    return v.round().toString();
  }

  @override
  bool shouldRepaint(_ChartPainter old) => old.s != s;
}