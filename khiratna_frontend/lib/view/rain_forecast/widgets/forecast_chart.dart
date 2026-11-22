import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:khiratna_frontend/model/water_forecast.dart';

class ForecastChart extends StatelessWidget {
  final List<WaterMonth> months;

  const ForecastChart({
    super.key,
    required this.months,
  });

  static const _blue = Color(0xFF1E88E5);
  static const _green = Color(0xFF2E9E4F);
  static const _red = Color(0xFFD64F66);

  static const _rainDash = [6, 4];
  static const _etcDash = [2, 4];

  List<FlSpot> _spots(
    double Function(WaterMonth) f, {
    int from = 0,
    int? to,
  }) {
    final end = to ?? months.length;

    return [
      for (var i = from; i < end; i++)
        FlSpot(i.toDouble(), f(months[i])),
    ];
  }

  LineChartBarData _bar({
    required Color color,
    required List<FlSpot> spots,
    List<int>? dash,
    bool hollowDots = false,
    int hollowFromIndex = 0,
    bool fill = false,
  }) {
    return LineChartBarData(
      isCurved: false,
      color: color,
      barWidth: 3,
      dashArray: dash,
      spots: spots,
      dotData: FlDotData(
        show: true,
        getDotPainter:
            (spot, percent, bar, index) {
          final hollow =
              hollowDots &&
                  index >= hollowFromIndex;

          return FlDotCirclePainter(
            radius: 4,
            color: hollow
                ? Colors.white
                : color,
            strokeColor: color,
            strokeWidth: 2,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: fill,
        color: color.withOpacity(.08),
      ),
    );
  }

  /// Blue line: solid while real, dashed once forecast.
  List<LineChartBarData> _rainBars() {
    final k = months.indexWhere(
      (m) => !m.rainObserved,
    );

    // all real
    if (k == -1) {
      return [
        _bar(
          color: _blue,
          spots: _spots((m) => m.rainMm),
          fill: true,
        ),
      ];
    }

    // all forecast
    if (k == 0) {
      return [
        _bar(
          color: _blue,
          spots: _spots((m) => m.rainMm),
          dash: _rainDash,
          hollowDots: true,
          fill: true,
        ),
      ];
    }

    // real, then forecast (joined at the last real point)
    return [
      _bar(
        color: _blue,
        spots: _spots(
          (m) => m.rainMm,
          to: k,
        ),
        fill: true,
      ),
      _bar(
        color: _blue,
        spots: _spots(
          (m) => m.rainMm,
          from: k - 1,
        ),
        dash: _rainDash,
        hollowDots: true,
        hollowFromIndex: 1,
        fill: true,
      ),
    ];
  }

  List<LineTooltipItem?> _tooltip(
    List<LineBarSpot> touched,
  ) {
    if (touched.isEmpty) return [];

    final i = touched.first.x.toInt();

    if (i < 0 || i >= months.length) {
      return List.filled(
        touched.length,
        null,
      );
    }

    final m = months[i];

    const style = TextStyle(
      color: Colors.white,
      fontSize: 12,
      height: 1.5,
    );

    final item = LineTooltipItem(
      m.month,
      style.copyWith(
        fontWeight: FontWeight.bold,
      ),
      children: [
        TextSpan(
          text:
              "\nRain: ${m.rainMm.toStringAsFixed(1)} mm "
              "(${m.rainObserved ? "observed" : "forecast"})",
          style: style.copyWith(
            color: const Color(0xFF90CAF9),
          ),
        ),
        TextSpan(
          text:
              "\nCrop ETc: ${m.cropNeedMm.toStringAsFixed(1)} mm",
          style: style.copyWith(
            color: const Color(0xFF81C784),
          ),
        ),
        TextSpan(
          text:
              "\nWater to add: ${m.waterToAddMm.toStringAsFixed(1)} mm",
          style: style.copyWith(
            color: const Color(0xFFF48FB1),
          ),
        ),
      ],
    );

    // one tooltip for the month, hide duplicates
    return [
      for (var n = 0; n < touched.length; n++)
        n == 0 ? item : null,
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (months.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxVal = months
        .map(
          (m) => math.max(
            m.rainMm,
            math.max(
              m.cropNeedMm,
              m.waterToAddMm,
            ),
          ),
        )
        .reduce(math.max);

    final maxY = math.max(
      10.0,
      ((maxVal * 1.15) / 10).ceil() * 10.0,
    );

    final step =
        (months.length / 8).ceil().clamp(1, 12);

    return Container(
      height: 460,
      padding: const EdgeInsets.fromLTRB(
        16,
        20,
        24,
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Rainfall vs Crop Water Requirement (ETc)",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 20,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: const [
              _LegendItem(
                color: _blue,
                mixed: true,
                label:
                    "Rainfall (mm) — real, then forecast",
              ),
              _LegendItem(
                color: _green,
                dash: [2, 4],
                label:
                    "Crop ETc (monthly need in mm)",
              ),
              _LegendItem(
                color: _red,
                label:
                    "Water to add (ETc − useful rain)",
              ),
            ],
          ),

          const SizedBox(height: 16),

          Expanded(
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY,
                minX: 0,
                maxX: months.length == 1
                    ? 1
                    : (months.length - 1)
                        .toDouble(),

                gridData: const FlGridData(
                  show: true,
                  drawVerticalLine: false,
                ),

                borderData: FlBorderData(
                  show: false,
                ),

                lineTouchData: LineTouchData(
                  touchTooltipData:
                      LineTouchTooltipData(
                    getTooltipItems: _tooltip,
                  ),
                ),

                titlesData: FlTitlesData(
                  rightTitles:
                      const AxisTitles(),
                  topTitles:
                      const AxisTitles(),

                  leftTitles: const AxisTitles(
                    axisNameWidget: Text(
                      "Millimeters (mm)",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    axisNameSize: 24,
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                    ),
                  ),

                  bottomTitles: AxisTitles(
                    axisNameWidget: const Text(
                      "Month",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    axisNameSize: 28,
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 28,
                      getTitlesWidget:
                          (value, meta) {
                        final i = value.toInt();

                        if (value !=
                                i.toDouble() ||
                            i < 0 ||
                            i >= months.length ||
                            i % step != 0) {
                          return const SizedBox();
                        }

                        return Padding(
                          padding:
                              const EdgeInsets
                                  .only(top: 8),
                          child: Text(
                            months[i].month,
                            style:
                                const TextStyle(
                              fontSize: 11,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                lineBarsData: [
                  /// Rainfall (blue): solid real, dashed forecast
                  ..._rainBars(),

                  /// Crop ETc (green, dotted)
                  _bar(
                    color: _green,
                    spots: _spots(
                      (m) => m.cropNeedMm,
                    ),
                    dash: _etcDash,
                  ),

                  /// Water to add (red, solid)
                  _bar(
                    color: _red,
                    spots: _spots(
                      (m) => m.waterToAddMm,
                    ),
                    fill: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Legend entry that draws the real line style.
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final List<double>? dash;
  final bool mixed;

  const _LegendItem({
    required this.color,
    required this.label,
    this.dash,
    this.mixed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: const Size(38, 14),
          painter: _LegendLinePainter(
            color: color,
            dash: dash,
            mixed: mixed,
          ),
        ),

        const SizedBox(width: 6),

        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

class _LegendLinePainter
    extends CustomPainter {
  final Color color;
  final List<double>? dash;
  final bool mixed;

  _LegendLinePainter({
    required this.color,
    required this.dash,
    required this.mixed,
  });

  void _line(
    Canvas canvas,
    double x0,
    double x1,
    double y,
    Paint p,
    List<double>? pattern,
  ) {
    if (pattern == null) {
      canvas.drawLine(
        Offset(x0, y),
        Offset(x1, y),
        p,
      );
      return;
    }

    var x = x0;
    var i = 0;

    while (x < x1) {
      final len = pattern[i % 2];
      final nx = math.min(x + len, x1);

      if (i % 2 == 0) {
        canvas.drawLine(
          Offset(x, y),
          Offset(nx, y),
          p,
        );
      }

      x = nx;
      i++;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;

    final line = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.butt;

    if (mixed) {
      // solid (real) then dashed (forecast)
      _line(
        canvas,
        0,
        size.width / 2,
        y,
        line,
        null,
      );
      _line(
        canvas,
        size.width / 2,
        size.width,
        y,
        line,
        const [5, 3],
      );
    } else {
      _line(
        canvas,
        0,
        size.width,
        y,
        line,
        dash,
      );
    }

    // dot in the middle, like the chart points
    canvas.drawCircle(
      Offset(size.width / 2, y),
      3.5,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(size.width / 2, y),
      3.5,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(
    covariant _LegendLinePainter old,
  ) {
    return old.color != color ||
        old.dash != dash ||
        old.mixed != mixed;
  }
}