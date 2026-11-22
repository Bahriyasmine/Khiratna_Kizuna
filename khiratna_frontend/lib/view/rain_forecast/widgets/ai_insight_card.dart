import 'package:flutter/material.dart';
import 'package:khiratna_frontend/model/water_forecast.dart';

class AiInsightCard extends StatelessWidget {
  final WaterForecast forecast;
  final String cropName;

  const AiInsightCard({
    super.key,
    required this.forecast,
    required this.cropName,
  });

  @override
  Widget build(BuildContext context) {
    final coverage = forecast.coveragePercent;
    final peak = forecast.peakMonth;
    final t = forecast.total;

    final predictedMonths = forecast.months
        .where((m) => !m.rainObserved)
        .length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF166534),
            Color(0xFF22C55E),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.smart_toy,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Text(
                "AI Insight",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            "Between ${forecast.start} and ${forecast.end} in ${forecast.region}, "
            "useful rainfall is expected to cover approximately "
            "${coverage.toStringAsFixed(0)}% of the water demand of $cropName.",
            style: const TextStyle(
              color: Colors.white,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            "Estimated irrigation requirement: "
            "${t.waterToAddMm.toStringAsFixed(1)} mm "
            "(${t.waterToAddM3PerHa.toStringAsFixed(0)} m³/ha).",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),

          if (peak != null &&
              peak.waterToAddMm > 0) ...[
            const SizedBox(height: 8),

            Text(
              "Peak irrigation month: ${peak.month} "
              "(${peak.waterToAddM3PerHa.toStringAsFixed(0)} m³/ha).",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],

          if (predictedMonths > 0) ...[
            const SizedBox(height: 12),

            Text(
              "$predictedMonths of ${forecast.months.length} months use predicted rainfall, "
              "so treat those figures as estimates.",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}