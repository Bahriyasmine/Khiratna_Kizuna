import 'package:flutter/material.dart';
import 'package:khiratna_frontend/viewmodel/rain_forecast_viewmodel.dart';
import 'mobile/rain_forecast_mobile_view.dart';
import 'web/rain_forecast_desktop_view.dart';

class RainForecastScreen extends StatefulWidget {
  const RainForecastScreen({super.key});

  @override
  State<RainForecastScreen> createState() => _RainForecastScreenState();
}

class _RainForecastScreenState extends State<RainForecastScreen> {
  final vm = RainForecastViewModel();

  @override
  void initState() {
    super.initState();
    vm.loadOptions();
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF8),
      appBar: AppBar(
        title: const Text('Rain Forecast'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return ListenableBuilder(
            listenable: vm,
            builder: (context, _) => constraints.maxWidth >= 900
                ? RainForecastDesktopView(vm: vm)
                : RainForecastMobileView(vm: vm),
          );
        },
      ),
    );
  }
}