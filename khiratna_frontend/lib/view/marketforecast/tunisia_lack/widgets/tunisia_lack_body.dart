import 'package:flutter/material.dart';
import 'package:khiratna_frontend/core/constants/app_colors.dart';
import 'package:khiratna_frontend/core/widgets/error_retry.dart';
import 'package:khiratna_frontend/viewmodel/marketforecast/tunisia_lack_viewmodel.dart';
import 'package:provider/provider.dart';

import 'forecast_reliability_note.dart';
import 'product_chart_section.dart';
import 'shortage_list.dart';
import 'show_forecast_button.dart';

class TunisiaLackBody extends StatelessWidget {
  const TunisiaLackBody({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TunisiaLackViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShowForecastButton(
          isLoading: vm.isLoading,
          hasLoaded: vm.hasLoaded,
          onPressed: vm.showForecast,
        ),
        const SizedBox(height: 24),
        if (vm.isLoading)
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            ),
          )
        else if (vm.errorMessage != null)
          ErrorRetry(message: vm.errorMessage!, onRetry: vm.showForecast)
        else if (vm.hasLoaded) ...[
          ShortageList(products: vm.products),
          const SizedBox(height: 24),
          const ProductChartSection(),
          if (vm.backtest != null) ...[
            const SizedBox(height: 24),
            ForecastReliabilityNote(backtest: vm.backtest!),
          ],
        ],
      ],
    );
  }
}