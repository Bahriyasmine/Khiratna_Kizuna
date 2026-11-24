import 'package:flutter/material.dart';
import '../widgets/market_header.dart';
import '../widgets/service_cards.dart';

class MarketForecastMobileView extends StatelessWidget {
  const MarketForecastMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: const [
          MarketHeader(
            title: 'Market Forecast',
            subtitle:
                'Choose a service to explore the Tunisian agricultural market.',
          ),
          SizedBox(height: 24),
          ServiceCards(horizontal: false),
        ],
      ),
    );
  }
}