import 'package:flutter/material.dart';
import 'package:khiratna_frontend/core/widgets/premium_service_card.dart';
import 'package:khiratna_frontend/services/service_pricing.dart';
import 'package:khiratna_frontend/view/aichatbot/chatbot_screen.dart'
    show ChatbotScreen;
import 'package:khiratna_frontend/view/marketforecast/market_forecast_screen.dart';
import 'package:khiratna_frontend/view/rain_forecast/rain_forecast_screen.dart';
import 'package:khiratna_frontend/view/services/widgets/service_item_card.dart';
import 'package:khiratna_frontend/view/smart_map/smart_maps_screen.dart';
import 'package:khiratna_frontend/view/soil_analysis/soil_analysis_screen.dart';
import '../paywall_screen.dart';

class ServicesMobileView extends StatelessWidget {
  const ServicesMobileView({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            style: TextStyle(color: Colors.black54),
          ),

          const SizedBox(height: 30),

          // ───────── Premium: Rain Forecast ─────────
          PremiumServiceCard(
            icon: Icons.cloud,
            title: "Rain Forecast",
            subtitle: "Predict rainfall and irrigation requirements.",
            priceTnd: ServicePricing.rainForecast.amountTnd,
            onTap: () => _open(
              context,
              PaywallScreen(
                icon: Icons.cloud,
                title: "Rain Forecast",
                description:
                    "Know how much water your crop needs, month by month.",
                features: const [
                  "Rainfall forecast for all 24 governorates",
                  "Irrigation needs per crop, in mm and m³ per hectare",
                  "Monthly chart and detailed table",
                  "AI insight on how much rain covers your crop",
                ],
                priceTnd: ServicePricing.rainForecast.amountTnd,
                period: ServicePricing.rainForecast.period,
                serviceBuilder: (_) => const RainForecastScreen(),
              ),
            ),
          ),

          const SizedBox(height: 16),

          ServiceItemCard(
            icon: Icons.grass,
            title: "Smart Maps",
            subtitle: "Explore Tunisia's agricultural potential..",
            onTap: () => _open(context, const SmartMapsScreen()),
          ),

          const SizedBox(height: 16),

          ServiceItemCard(
            icon: Icons.grass,
            title: "Soil Analysis",
            subtitle: "Find the best crops for your land.",
            onTap: () => _open(context, const SoilAnalysisScreen()),
          ),

          const SizedBox(height: 16),

          // ───────── Premium: AI Assistant ─────────
          PremiumServiceCard(
            icon: Icons.smart_toy,
            title: "AI Assistant",
            subtitle: "Agricultural and energy guidance.",
            priceTnd: ServicePricing.aiAssistant.amountTnd,
            onTap: () => _open(
              context,
              PaywallScreen(
                icon: Icons.smart_toy,
                title: "AI Assistant",
                description:
                    "Ask questions about your farm and get clear answers.",
                features: const [
                  "Agricultural and energy guidance",
                  "Answers tailored to Tunisian farming",
                  "Available any time of the day",
                ],
                priceTnd: ServicePricing.aiAssistant.amountTnd,
                period: ServicePricing.aiAssistant.period,
                serviceBuilder: (_) => const ChatbotScreen(),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ───────── Premium: Market Forecasting ─────────
          PremiumServiceCard(
            icon: Icons.query_stats,
            title: "Market Forecasting",
            subtitle: "Discover future market opportunities.",
            priceTnd: ServicePricing.marketForecast.amountTnd,
            onTap: () => _open(
              context,
              PaywallScreen(
                icon: Icons.query_stats,
                title: "Market Forecasting",
                description:
                    "See what Tunisia will lack and which crop earns the most.",
                features: const [
                  "National shortage forecast up to 2027",
                  "Revenue per hectare and per m³ of water",
                  "Planting advice for your governorate and month",
                  "Year-by-year production and consumption charts",
                ],
                priceTnd: ServicePricing.marketForecast.amountTnd,
                period: ServicePricing.marketForecast.period,
                serviceBuilder: (_) => const MarketForecastScreen(),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}