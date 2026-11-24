import 'package:flutter/material.dart';

import 'mobile/market_forecast_mobile_view.dart';
import 'web/market_forecast_web_view.dart';

class MarketForecastScreen extends StatelessWidget {
  const MarketForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Forecast'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: isWeb
          ? const MarketForecastWebView()
          : const MarketForecastMobileView(),
    );
  }
}