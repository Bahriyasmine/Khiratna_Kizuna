import 'package:flutter/material.dart';
import 'package:khiratna_frontend/model/soil_analysis/crop_recommendation.dart';

import 'crop_result_table.dart';

class SoilResultsSection extends StatelessWidget {
  final List<CropRecommendation> results;
  final List<String> warnings;
  final double modelAccuracy;
  final String? error;

  const SoilResultsSection({
    super.key,
    required this.results,
    required this.warnings,
    required this.modelAccuracy,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(error!, style: const TextStyle(color: Colors.red)),
          ),
        if (warnings.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              border: Border.all(color: Colors.orange.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final w in warnings)
                  Text('⚠ $w', style: TextStyle(color: Colors.orange.shade900)),
              ],
            ),
          ),
        CropResultTable(crops: results),
        if (modelAccuracy > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Model accuracy: ${(modelAccuracy * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
      ],
    );
  }
}