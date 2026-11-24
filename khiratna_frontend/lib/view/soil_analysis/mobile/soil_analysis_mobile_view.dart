import 'package:flutter/material.dart';

import '../../../model/soil_analysis/crop_recommendation.dart';
import '../widgets/soil_input_form.dart';
import '../widgets/soil_results_section.dart';

class SoilAnalysisMobileView extends StatelessWidget {
  final TextEditingController nitrogenController;
  final TextEditingController phosphorusController;
  final TextEditingController potassiumController;
  final TextEditingController temperatureController;
  final TextEditingController humidityController;
  final TextEditingController phController;
  final TextEditingController rainfallController;
  final List<CropRecommendation> results;
  final List<String> warnings;
  final double modelAccuracy;
  final bool loading;
  final String? error;
  final VoidCallback onAnalyze;

  const SoilAnalysisMobileView({
    super.key,
    required this.nitrogenController,
    required this.phosphorusController,
    required this.potassiumController,
    required this.temperatureController,
    required this.humidityController,
    required this.phController,
    required this.rainfallController,
    required this.results,
    required this.warnings,
    required this.modelAccuracy,
    required this.loading,
    this.error,
    required this.onAnalyze,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SoilInputForm(
            nitrogenController: nitrogenController,
            phosphorusController: phosphorusController,
            potassiumController: potassiumController,
            temperatureController: temperatureController,
            humidityController: humidityController,
            phController: phController,
            rainfallController: rainfallController,
            loading: loading,
            onAnalyze: onAnalyze,
          ),
          const SizedBox(height: 16),
          SoilResultsSection(
            results: results,
            warnings: warnings,
            modelAccuracy: modelAccuracy,
            error: error,
          ),
        ],
      ),
    );
  }
}