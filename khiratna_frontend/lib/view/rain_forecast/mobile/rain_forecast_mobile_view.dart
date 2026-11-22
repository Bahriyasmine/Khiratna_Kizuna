import 'package:flutter/material.dart';
import 'package:khiratna_frontend/view/rain_forecast/widgets/forecast_form.dart';
import 'package:khiratna_frontend/viewmodel/rain_forecast_viewmodel.dart';
import '../widgets/ai_insight_card.dart';
import '../widgets/forecast_chart.dart';
import '../widgets/forecast_kpi_card.dart';

class RainForecastMobileView
    extends StatelessWidget {
  final RainForecastViewModel vm;

  const RainForecastMobileView({
    super.key,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    final f = vm.forecast;

    return SingleChildScrollView(
      padding:
          const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            "Rain Forecast",
            style: TextStyle(
              fontSize: 34,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "Forecast rainfall and crop irrigation needs.",
          ),

          const SizedBox(height: 24),

          ForecastForm(vm: vm),

          if (vm.error != null) ...[
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius:
                    BorderRadius.circular(
                        16),
                border: Border.all(
                  color:
                      Colors.red.shade200,
                ),
              ),
              child: Text(
                vm.error!,
                style: TextStyle(
                  color:
                      Colors.red.shade800,
                ),
              ),
            ),
          ],

          if (f != null) ...[
            const SizedBox(height: 25),

            ForecastChart(
                months: f.months),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child:
                      ForecastKpiCard(
                    value: f.total.rainMm
                        .toStringAsFixed(1),
                    label:
                        "Rainfall mm",
                    icon:
                        Icons.cloud,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child:
                      ForecastKpiCard(
                    value: f.total
                        .waterToAddMm
                        .toStringAsFixed(1),
                    label:
                        "Water mm",
                    icon: Icons
                        .water_drop,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            AiInsightCard(
              forecast: f,
              cropName: vm.cropName,
            ),
          ],
        ],
      ),
    );
  }
}