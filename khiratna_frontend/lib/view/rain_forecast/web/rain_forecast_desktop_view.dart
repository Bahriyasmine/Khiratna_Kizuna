import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khiratna_frontend/viewmodel/rain_forecast_viewmodel.dart';
import '../widgets/ai_insight_card.dart';
import '../widgets/forecast_chart.dart';
import '../widgets/forecast_form.dart';
import '../widgets/forecast_kpi_card.dart';

class RainForecastDesktopView extends StatelessWidget {
  final RainForecastViewModel vm;

  const RainForecastDesktopView({
    super.key,
    required this.vm,
  });

  String _month(String ym) =>
      DateFormat('MMM yyyy').format(DateTime.parse('$ym-01'));

  @override
  Widget build(BuildContext context) {
    final f = vm.forecast;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            "Rainfall Forecast & Crop Water Needs",
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "Predict rainfall levels, estimate irrigation requirements and generate AI-powered recommendations.",
            style: TextStyle(
              color: Colors.black54,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 30),

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: ForecastForm(vm: vm),
              ),

              const SizedBox(width: 24),

              Expanded(
                child: Column(
                  children: [
                    ForecastKpiCard(
                      value: f == null
                          ? "--"
                          : f.total.rainMm
                              .toStringAsFixed(1),
                      label: "Rainfall (mm)",
                      icon: Icons.cloud,
                    ),

                    const SizedBox(height: 16),

                    ForecastKpiCard(
                      value: f == null
                          ? "--"
                          : f.total.waterToAddMm
                              .toStringAsFixed(1),
                      label:
                          "Water Required (mm)",
                      icon: Icons.water_drop,
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (vm.error != null) ...[
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius:
                    BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.red.shade200,
                ),
              ),
              child: Text(
                vm.error!,
                style: TextStyle(
                  color: Colors.red.shade800,
                ),
              ),
            ),
          ],

          if (f != null) ...[
            const SizedBox(height: 40),

            ForecastChart(months: f.months),

            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: ForecastKpiCard(
                    value: f.total.rainMm
                        .toStringAsFixed(1),
                    label: "Total Rainfall",
                    icon: Icons.cloud,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: ForecastKpiCard(
                    value: f.total.cropNeedMm
                        .toStringAsFixed(1),
                    label: "Crop Need (ETc)",
                    icon: Icons.grass,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: ForecastKpiCard(
                    value: f.total.waterToAddMm
                        .toStringAsFixed(1),
                    label: "Water To Add",
                    icon: Icons.water_drop,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: ForecastKpiCard(
                    value: f.total
                        .waterToAddM3PerHa
                        .toStringAsFixed(0),
                    label: "m³ / hectare",
                    icon: Icons.opacity,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            AiInsightCard(
              forecast: f,
              cropName: vm.cropName,
            ),

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(.04),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: DataTable(
                columns: const [
                  DataColumn(
                    label: Text("Month"),
                  ),
                  DataColumn(
                    label: Text("Rainfall"),
                  ),
                  DataColumn(
                    label: Text("Useful Rain"),
                  ),
                  DataColumn(
                    label: Text("Crop Need"),
                  ),
                  DataColumn(
                    label: Text("Water To Add"),
                  ),
                ],
                rows: f.months.map((m) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(_month(m.month)),
                      ),
                      DataCell(
                        Text(m.rainMm
                            .toStringAsFixed(1)),
                      ),
                      DataCell(
                        Text(m.usefulRainMm
                            .toStringAsFixed(1)),
                      ),
                      DataCell(
                        Text(m.cropNeedMm
                            .toStringAsFixed(1)),
                      ),
                      DataCell(
                        Text(m.waterToAddMm
                            .toStringAsFixed(1)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}