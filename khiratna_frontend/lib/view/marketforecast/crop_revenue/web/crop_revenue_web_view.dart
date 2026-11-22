import 'package:flutter/material.dart';
import 'package:khiratna_frontend/view/marketforecast/widgets/market_header.dart';
import '../widgets/crop_revenue_body.dart';

class CropRevenueWebView extends StatelessWidget {
  const CropRevenueWebView({super.key});

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
                title: 'Which crop earns the most for my water?',
                subtitle:
                    'Pick your governorate and planting month to compare crops by revenue per m³ of water.',
              ),
              SizedBox(height: 28),
              CropRevenueBody(),
            ],
          ),
        ),
      ),
    );
  }
}