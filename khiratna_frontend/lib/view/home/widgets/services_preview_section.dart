import 'package:flutter/material.dart';

import 'section_title.dart';
import 'service_card.dart';

class ServicesPreviewSection extends StatelessWidget {
  // Optional navigation hooks, e.g. onRain: () => Navigator.push(...)
  final VoidCallback? onRain;
  final VoidCallback? onSoil;
  final VoidCallback? onMaps;
  final VoidCallback? onAssistant;
  final VoidCallback? onMarket;

  const ServicesPreviewSection({
    super.key,
    this.onRain,
    this.onSoil,
    this.onMaps,
    this.onAssistant,
    this.onMarket,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      ServiceCard(
        icon: Icons.cloud,
        title: "Rain Forecast",
        subtitle: "Rainfall and irrigation needs for your crop.",
        color: Colors.blue,
        onTap: onRain,
      ),
      ServiceCard(
        icon: Icons.grass,
        title: "Soil Analysis",
        subtitle: "Which crops suit your soil and climate.",
        color: Colors.green,
        onTap: onSoil,
      ),
      ServiceCard(
        icon: Icons.map,
        title: "Smart Maps",
        subtitle: "Soil data by region on an interactive map.",
        color: Colors.orange,
        onTap: onMaps,
      ),
      ServiceCard(
        icon: Icons.smart_toy,
        title: "AI Assistant",
        subtitle: "Ask questions about your farm.",
        color: Colors.purple,
        onTap: onAssistant,
      ),
      ServiceCard(
        icon: Icons.show_chart,
        title: "Market Forecasting",
        subtitle: "What Tunisia lacks and which crop earns most.",
        color: Colors.teal,
        onTap: onMarket,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SectionTitle("Our Services"),

          const SizedBox(height: 22),

          for (var i = 0; i < cards.length; i++) ...[
            cards[i],
            if (i != cards.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}