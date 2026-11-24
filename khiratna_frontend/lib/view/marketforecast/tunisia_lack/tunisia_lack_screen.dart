import 'package:flutter/material.dart';
import 'package:khiratna_frontend/viewmodel/marketforecast/tunisia_lack_viewmodel.dart';
import 'package:provider/provider.dart';

import 'mobile/tunisia_lack_mobile_view.dart';
import 'web/tunisia_lack_web_view.dart';

class TunisiaLackScreen extends StatelessWidget {
  const TunisiaLackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 900;

    return ChangeNotifierProvider(
      create: (_) => TunisiaLackViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tunisian Market Forecast'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        body: isWeb ? const TunisiaLackWebView() : const TunisiaLackMobileView(),
      ),
    );
  }
}