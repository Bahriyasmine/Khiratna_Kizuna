import 'package:flutter/material.dart';
import 'package:khiratna_frontend/viewmodel/soil_analysis_viewmodel.dart';

import 'mobile/soil_analysis_mobile_view.dart';
import 'web/soil_analysis_web_view.dart';

class SoilAnalysisScreen extends StatefulWidget {
  const SoilAnalysisScreen({super.key});

  @override
  State<SoilAnalysisScreen> createState() => _SoilAnalysisScreenState();
}

class _SoilAnalysisScreenState extends State<SoilAnalysisScreen> {
  final vm = SoilAnalysisViewModel();

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF8),
      appBar: AppBar(
        title: const Text('Crop & Soil Suitability'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListenableBuilder(
        listenable: vm,
        builder: (context, _) {
          if (isWeb) {
            return SoilAnalysisWebView(
              nitrogenController: vm.nitrogenController,
              phosphorusController: vm.phosphorusController,
              potassiumController: vm.potassiumController,
              temperatureController: vm.temperatureController,
              humidityController: vm.humidityController,
              phController: vm.phController,
              rainfallController: vm.rainfallController,
              results: vm.recommendations,
              warnings: vm.warnings,
              modelAccuracy: vm.modelAccuracy,
              loading: vm.loading,
              error: vm.error,
              onAnalyze: vm.analyze,
            );
          }
          return SoilAnalysisMobileView(
            nitrogenController: vm.nitrogenController,
            phosphorusController: vm.phosphorusController,
            potassiumController: vm.potassiumController,
            temperatureController: vm.temperatureController,
            humidityController: vm.humidityController,
            phController: vm.phController,
            rainfallController: vm.rainfallController,
            results: vm.recommendations,
            warnings: vm.warnings,
            modelAccuracy: vm.modelAccuracy,
            loading: vm.loading,
            error: vm.error,
            onAnalyze: vm.analyze,
          );
        },
      ),
    );
  }
}