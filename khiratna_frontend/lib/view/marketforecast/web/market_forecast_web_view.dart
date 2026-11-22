import 'package:flutter/material.dart';
import '../widgets/market_header.dart';
import '../widgets/service_cards.dart';

class MarketForecastWebView extends StatelessWidget {
  const MarketForecastWebView({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(40, 24, 40, 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MarketHeader(
                title: 'Market Forecast',
                subtitle:
                    'Choose a service to explore the Tunisian agricultural market.',
              ),
              SizedBox(height: 28),
              ServiceCards(horizontal: true),
            ],
          ),
        ),
      ),
    );
  }
}