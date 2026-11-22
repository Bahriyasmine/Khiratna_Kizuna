import 'package:flutter/material.dart';
import 'mobile/home_mobile_view.dart';
import 'web/home_desktop_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth >= 700
          ? const HomeDesktopView()
          : const HomeMobileView(),
    );
  }
}