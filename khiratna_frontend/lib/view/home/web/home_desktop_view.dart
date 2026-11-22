import 'package:flutter/material.dart';
import 'package:khiratna_frontend/view/home/widgets/cta_desktop_section.dart';
import 'package:khiratna_frontend/view/home/widgets/desktopHero.dart';
import 'package:khiratna_frontend/view/home/widgets/desktopServices.dart';
import 'package:khiratna_frontend/view/home/widgets/desktopStats.dart';
import 'package:khiratna_frontend/view/home/widgets/why_choose_desktop_section.dart';

class HomeDesktopView extends StatelessWidget {
  const HomeDesktopView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1600,
          ),
          child: Column(
            children: const [
              DesktopHero(),

              SizedBox(height: 50),

              StatsDesktopSection(),

              SizedBox(height: 70),

              ServicesDesktopSection(),

              SizedBox(height: 70),

              WhyChooseDesktopSection(),

              SizedBox(height: 70),

              CtaDesktopSection(),

              SizedBox(height: 70),
            ],
          ),
        ),
      ),
    );
  }
}