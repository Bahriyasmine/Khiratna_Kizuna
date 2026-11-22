import 'package:flutter/material.dart';
import 'package:khiratna_frontend/core/data/fake_map_data.dart';
import 'package:khiratna_frontend/model/smart_maps/governorate_map_data.dart';
import '../widgets/map_filter_bar.dart';
import '../widgets/map_header.dart';
import '../widgets/map_info_card.dart';
import '../widgets/map_legend.dart';
import '../widgets/map_map_widget.dart';
import '../widgets/map_statistics_card.dart';
import '../widgets/clicked_location_card.dart';

class SoilAnalysisMobileView extends StatelessWidget {
  final String selectedParameter;
  final String selectedGovernorate;

  final GovernorateSoilData selectedData;

  final double? clickedLat;
  final double? clickedLng;

  final Function(String) onParameterChanged;
  final Function(String) onGovernorateChanged;

  final Function({required double latitude, required double longitude})
  onMapClick;

  const SoilAnalysisMobileView({
    super.key,
    required this.selectedParameter,
    required this.selectedGovernorate,
    required this.selectedData,
    required this.clickedLat,
    required this.clickedLng,
    required this.onParameterChanged,
    required this.onGovernorateChanged,
    required this.onMapClick,
  });

  @override
  Widget build(BuildContext context) {
    final governorates = governorateData.map((e) => e.governorate).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SoilHeader(),

          const SizedBox(height: 20),

          SoilFilterBar(
            selectedParameter: selectedParameter,
            selectedGovernorate: selectedGovernorate,
            governorates: governorates,

            onParameterChanged: (value) {
              if (value != null) {
                onParameterChanged(value);
              }
            },

            onGovernorateChanged: (value) {
              if (value != null) {
                onGovernorateChanged(value);
              }
            },
          ),

          const SizedBox(height: 20),

          SoilInfoCard(
            title: selectedParameter,
            description:
                "Measures dissolved salts affecting crop productivity.",
            importance: "High salinity reduces water absorption by roots.",
          ),

          const SizedBox(height: 20),

          SoilMapWidget(
            selectedGovernorate: selectedGovernorate,
            onMapClick: (latitude, longitude) {
              onMapClick(latitude: latitude, longitude: longitude);
            },
          ),

          const SizedBox(height: 20),

          const SoilLegend(),

          const SizedBox(height: 20),

          SoilStatisticsCard(data: selectedData),

          const SizedBox(height: 20),

          ClickedLocationCard(latitude: clickedLat, longitude: clickedLng),
        ],
      ),
    );
  }
}
