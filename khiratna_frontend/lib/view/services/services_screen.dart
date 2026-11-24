import 'package:flutter/material.dart';

import 'mobile/services_mobile_view.dart';
import 'web/services_desktop_view.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // true when opened with Navigator.push (e.g. from the hero button)
    final isPushed = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF8),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return constraints.maxWidth >= 900
              ? const ServicesDesktopView()
              : const ServicesMobileView();
        },
      ),
    );
  }
}