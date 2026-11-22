import 'package:flutter/material.dart';
import 'package:khiratna_frontend/view/marketforecast/widgets/market_header.dart';
import '../widgets/tunisia_lack_body.dart';

class TunisiaLackMobileView extends StatelessWidget {
  const TunisiaLackMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarketHeader(
              title: 'What will Tunisia lack in 2027?',
              subtitle:
                  'National FAO statistics: the same answer for every governorate. No input needed.',
            ),
            SizedBox(height: 24),
            TunisiaLackBody(),
          ],
        ),
      ),
    );
  }
}