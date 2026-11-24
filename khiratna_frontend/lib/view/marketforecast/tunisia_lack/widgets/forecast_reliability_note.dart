import 'package:flutter/material.dart';
import 'package:khiratna_frontend/core/widgets/app_card.dart';
import 'package:khiratna_frontend/model/marketforecast/market_backtest.dart';

class ForecastReliabilityNote extends StatelessWidget {
  final MarketBacktest backtest;
  const ForecastReliabilityNote({super.key, required this.backtest});

  Widget _line(String label, BacktestError e) {
    final better = e.modelErrorPercent < e.naiveErrorPercent;

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text.rich(
        TextSpan(
          style: const TextStyle(fontSize: 13, height: 1.4),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(
              text: 'median error ${e.modelErrorPercent.toStringAsFixed(1)} % '
                  '(simple baseline ${e.naiveErrorPercent.toStringAsFixed(1)} %)'
                  '${better ? ', better than the baseline' : ''}',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How reliable is this forecast?',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            'Tested on past years the model had not seen:',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          _line('Production', backtest.production),
          _line('Consumption', backtest.consumption),
        ],
      ),
    );
  }
}