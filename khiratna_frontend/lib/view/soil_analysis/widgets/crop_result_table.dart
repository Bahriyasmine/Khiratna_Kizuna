import 'package:flutter/material.dart';
import 'package:khiratna_frontend/model/soil_analysis/crop_recommendation.dart';


class CropResultTable extends StatelessWidget {
  final List<CropRecommendation> crops;

  const CropResultTable({super.key, required this.crops});

  @override
  Widget build(BuildContext context) {
    if (crops.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Center(child: Text('No analysis yet.')),
        ),
      );
    }

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Crop')),
              DataColumn(label: Text('Suitability')),
              DataColumn(label: Text('Season')),
              DataColumn(label: Text('Water Need')),
            ],
            rows: crops
                .map(
                  (crop) => DataRow(cells: [
                    DataCell(Text(crop.cropName)),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 80,
                            child: LinearProgressIndicator(
                              value: (crop.suitability / 100).clamp(0.0, 1.0),
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${crop.suitability.toStringAsFixed(1)}%'),
                        ],
                      ),
                    ),
                    DataCell(Text(crop.season)),
                    DataCell(Text(crop.waterRequirement)),
                  ]),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}