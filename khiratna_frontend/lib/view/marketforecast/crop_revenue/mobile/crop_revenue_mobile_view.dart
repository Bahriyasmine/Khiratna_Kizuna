import 'package:flutter/material.dart';
import 'package:khiratna_frontend/view/marketforecast/widgets/market_header.dart';
import '../widgets/crop_revenue_body.dart';

class CropRevenueMobileView extends StatelessWidget {
  const CropRevenueMobileView({super.key});

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
              title: 'Which crop earns the most for my water?',
              subtitle:
                  'Pick your governorate and planting month to compare crops by revenue per m³ of water.',
            ),
            SizedBox(height: 24),
            CropRevenueBody(),
          ],
        ),
      ),
    );
  }
}