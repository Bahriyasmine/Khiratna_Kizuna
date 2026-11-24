import 'package:flutter/material.dart';
import 'package:khiratna_frontend/view/aichatbot/chatbot_screen.dart' show ChatbotScreen;
import 'package:khiratna_frontend/view/marketforecast/market_forecast_screen.dart';
import 'package:khiratna_frontend/view/rain_forecast/rain_forecast_screen.dart';
import 'package:khiratna_frontend/view/smart_map/smart_maps_screen.dart';
import 'package:khiratna_frontend/view/soil_analysis/soil_analysis_screen.dart';

import '../widgets/service_item_card.dart';

class ServicesMobileView extends StatelessWidget {
  const ServicesMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          const Text(
            "Our Services",
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "Explore Khiratna's intelligent agricultural tools.",
            style: TextStyle(
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 30),

          ServiceItemCard(
            icon: Icons.cloud,
            title: "Rain Forecast",
            subtitle:
                "Predict rainfall and irrigation requirements.",
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

          const SizedBox(height: 16),

          ServiceItemCard(
            icon: Icons.grass,
            title: "Smart Maps",
            subtitle:
                "Explore Tunisia's agricultural potential..",
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

          const SizedBox(height: 16),

          ServiceItemCard(
            icon: Icons.grass,
            title: "Soil Analysis",
            subtitle:
                "Find the best crops for your land.",
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

          const SizedBox(height: 16),

          ServiceItemCard(
            icon: Icons.smart_toy,
            title: "AI Assistant",
            subtitle:
                "Agricultural and energy guidance.",
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

          const SizedBox(height: 16),

          ServiceItemCard(
            icon: Icons.query_stats,
            title: "Market Forecasting",
            subtitle:
                "Discover future market opportunities.",
            onTap: ()
              {
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
    );
  }
}