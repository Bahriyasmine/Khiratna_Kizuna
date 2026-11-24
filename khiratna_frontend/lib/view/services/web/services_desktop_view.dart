import 'package:flutter/material.dart';
import 'package:khiratna_frontend/view/aichatbot/chatbot_screen.dart';
import 'package:khiratna_frontend/view/marketforecast/market_forecast_screen.dart';
import 'package:khiratna_frontend/view/rain_forecast/rain_forecast_screen.dart';
import 'package:khiratna_frontend/view/smart_map/smart_maps_screen.dart';
import 'package:khiratna_frontend/view/soil_analysis/soil_analysis_screen.dart';

import '../widgets/service_item_card.dart';

class ServicesDesktopView extends StatelessWidget {
  const ServicesDesktopView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: 40,
        vertical: 40,
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(60),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF0D3B24),
                  Color(0xFF2E7D32),
                ],
              ),
            ),
            child: const Column(
              children: [
                Text(
                  "Our Services",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Discover Khiratna's intelligent agricultural tools designed to support farmers, investors and policymakers.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 50),

          GridView.count(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 2.6,
            children: [
              ServiceItemCard(
                icon: Icons.cloud,
                title: "Rain Forecast",
                subtitle:
                    "Predict rainfall and irrigation needs.",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const RainForecastScreen(),
                    ),
                  );
                },
              ),

              ServiceItemCard(
                icon: Icons.grass,
                title: "Smart Maps",
                subtitle:
                    "Explore agricultural data visually.",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const SmartMapsScreen(),
                    ),
                  );
                },
              ),

              ServiceItemCard(
                icon: Icons.grass,
                title: "Soil Analysis",
                subtitle:
                    "Evaluate soil and choose crops.",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const SoilAnalysisScreen(),
                    ),
                  );
                },
              ),

              ServiceItemCard(
                icon: Icons.smart_toy,
                title: "AI Assistant",
                subtitle:
                    "Ask intelligent agricultural questions.",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const ChatbotScreen(),
                    ),
                  );
                },
              ),

              ServiceItemCard(
                icon: Icons.query_stats,
                title: "Market Forecasting",
                subtitle:
                    "Identify profitable future crops.",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const MarketForecastScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}