import 'package:flutter/material.dart';
import 'package:khiratna_frontend/view/marketforecast/widgets/market_header.dart';
import '../widgets/tunisia_lack_body.dart';

class TunisiaLackWebView extends StatelessWidget {
  const TunisiaLackWebView({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(40, 24, 40, 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MarketHeader(
                title: 'What will Tunisia lack in 2027?',
                subtitle:
                    'National FAO statistics: the same answer for every governorate. No input needed.',
              ),
              SizedBox(height: 28),
              TunisiaLackBody(),
            ],
          ),
        ),
      ),
    );
  }
}