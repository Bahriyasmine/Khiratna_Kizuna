import 'package:flutter/material.dart';
import 'package:khiratna_frontend/viewmodel/marketforecast/crop_revenue_viewmodel.dart';
import 'package:provider/provider.dart';

import 'mobile/crop_revenue_mobile_view.dart';
import 'web/crop_revenue_web_view.dart';

class CropRevenueScreen extends StatelessWidget {
  const CropRevenueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 900;

    return ChangeNotifierProvider(
      create: (_) => CropRevenueViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crop Revenue'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        body: isWeb ? const CropRevenueWebView() : const CropRevenueMobileView(),
      ),
    );
  }
}