import 'package:flutter/material.dart';

import '../widgets/cta_section.dart';
import '../widgets/hero_section.dart';
import '../widgets/services_preview_section.dart';
import '../widgets/stats_section.dart';
import '../widgets/why_choose_section.dart';

class HomeMobileView extends StatelessWidget {
  const HomeMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xffF7FAF7), Colors.white],
        ),
      ),
      child: const SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              HeroSection(),
              SizedBox(height: 36),
              StatsSection(),
              SizedBox(height: 36),
              WhyChooseSection(),
              SizedBox(height: 36),
              ServicesPreviewSection(),
              SizedBox(height: 36),
              CtaSection(),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}