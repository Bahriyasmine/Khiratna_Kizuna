import 'package:flutter/material.dart';
import 'package:khiratna_frontend/model/smart_maps/governorate_map_data.dart';
import 'package:khiratna_frontend/viewmodel/smart_maps_viewmodel.dart';
import 'package:provider/provider.dart';

import 'mobile/smart_map_mobile_view.dart';
import 'web/smart_map_web_view.dart';

class SmartMapsScreen extends StatelessWidget {
  const SmartMapsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SmartMapsViewModel(),
      child: const _SmartMapsLayout(),
    );
  }
}

class _SmartMapsLayout extends StatelessWidget {
  const _SmartMapsLayout();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SmartMapsViewModel>();
    final isWeb = MediaQuery.of(context).size.width > 900;

    final selectedData =
        vm.regionData ?? GovernorateSoilData.empty(vm.selectedGovernorate);

    void onMapClick({required double latitude, required double longitude}) {
      vm.onMapClick(latitude, longitude);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Maps'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: isWeb
          ? SoilAnalysisWebView(
              selectedParameter: vm.selectedParameter,
              selectedGovernorate: vm.selectedGovernorate,
              selectedData: selectedData,
              clickedLat: vm.clickedLat,
              clickedLng: vm.clickedLng,
              onParameterChanged: vm.setParameter,
              onGovernorateChanged: vm.setGovernorate,
              onMapClick: onMapClick,
            )
          : SoilAnalysisMobileView(
              selectedParameter: vm.selectedParameter,
              selectedGovernorate: vm.selectedGovernorate,
              selectedData: selectedData,
              clickedLat: vm.clickedLat,
              clickedLng: vm.clickedLng,
              onParameterChanged: vm.setParameter,
              onGovernorateChanged: vm.setGovernorate,
              onMapClick: onMapClick,
            ),
    );
  }
}