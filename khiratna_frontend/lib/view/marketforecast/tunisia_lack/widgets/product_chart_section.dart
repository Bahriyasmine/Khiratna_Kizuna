import 'package:flutter/material.dart';
import 'package:khiratna_frontend/core/constants/app_colors.dart';
import 'package:khiratna_frontend/core/widgets/app_card.dart';
import 'package:khiratna_frontend/core/widgets/app_dropdown.dart';
import 'package:khiratna_frontend/viewmodel/marketforecast/tunisia_lack_viewmodel.dart';
import 'package:provider/provider.dart';

import 'forecast_chart.dart';

class ProductChartSection extends StatelessWidget {
  const ProductChartSection({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TunisiaLackViewModel>();
    final series = vm.series;

    Widget chart;
    if (vm.isChartLoading) {
      chart = Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      );
    } else if (vm.chartError != null) {
      chart = Center(
        child: Text(
          vm.chartError!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      );
    } else if (series == null) {
      chart = Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      );
    } else {
      chart = ForecastChart(series: series);
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppDropdown(
            label: 'See one product year by year',
            value: vm.selectedProduct,
            items: vm.products.map((p) => p.name).toList(),
            onChanged: vm.selectProduct,
          ),
          const SizedBox(height: 20),
          if (series != null && vm.chartError == null)
            Center(
              child: Text(
                '${series.product}: real until ${series.lastRealYear}, '
                'forecast (dashed) to ${series.years.last}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LegendDot(color: kConsumptionColor, label: 'Consumption (t)'),
              SizedBox(width: 20),
              LegendDot(color: kProductionColor, label: 'Production (t)'),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(height: 280, child: chart),
        ],
      ),
    );
  }
}