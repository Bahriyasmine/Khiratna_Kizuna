import 'package:flutter/material.dart';
import 'package:khiratna_frontend/model/smart_maps/governorate_map_data.dart';

import '../widgets/clicked_location_card.dart';
import '../widgets/map_filter_bar.dart';
import '../widgets/map_header.dart';
import '../widgets/map_info_card.dart';
import '../widgets/map_legend.dart';
import '../widgets/map_map_widget.dart';
import '../widgets/map_statistics_card.dart';

class SoilAnalysisWebView extends StatelessWidget {
  final String selectedParameter;
  final String selectedGovernorate;

  final GovernorateSoilData selectedData;

  final double? clickedLat;
  final double? clickedLng;

  final Function(String) onParameterChanged;
  final Function(String) onGovernorateChanged;

  final Function({required double latitude, required double longitude})
  onMapClick;

  const SoilAnalysisWebView({
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
    final governorates = ["Zaghouan", "Sfax"];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SoilHeader(),

          const SizedBox(height: 24),

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

          const SizedBox(height: 24),

          const SoilInfoCard(
            title: "Soil Salinity",
            description: "Measures soil quality and crop suitability.",
            importance: "Useful for improving agricultural decisions.",
          ),

          const SizedBox(height: 24),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// LEFT SIDE
                Expanded(
                  flex: 7,
                  child: SoilMapWidget(
                    selectedGovernorate: selectedGovernorate,
                    onMapClick: (latitude, longitude) {
                      onMapClick(latitude: latitude, longitude: longitude);
                    },
                  ),
                ),

                const SizedBox(width: 20),

                /// RIGHT SIDE
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SoilStatisticsCard(data: selectedData),

                        const SizedBox(height: 20),

                        ClickedLocationCard(
                          latitude: clickedLat,
                          longitude: clickedLng,
                        ),

                        const SizedBox(height: 20),

                        const SoilLegend(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
