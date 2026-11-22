import 'package:flutter/material.dart';

class WhyChooseDesktopSection extends StatelessWidget {
  const WhyChooseDesktopSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      child: Column(
        children: [
          const Text(
            "Why Choose Khiratna?",
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            "Empowering Tunisian agriculture through artificial intelligence, data analytics and sustainability.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 40),

          Row(
            children: const [
              Expanded(
                child: _DesktopFeatureCard(
                  icon: Icons.water_drop,
                  title: "Water Optimization",
                  description:
                      "Reduce irrigation waste using rainfall forecasts and crop water requirements.",
                ),
              ),

              SizedBox(width: 20),

              Expanded(
                child: _DesktopFeatureCard(
                  icon: Icons.agriculture,
                  title: "Smart Crop Selection",
                  description:
                      "Identify the most suitable crops based on soil, climate and national demand.",
                ),
              ),

              SizedBox(width: 20),

              Expanded(
                child: _DesktopFeatureCard(
                  icon: Icons.solar_power,
                  title: "Solar Intelligence",
                  description:
                      "Estimate photovoltaic sizing and optimize pumping schedules.",
                ),
              ),

              SizedBox(width: 20),

              Expanded(
                child: _DesktopFeatureCard(
                  icon: Icons.trending_up,
                  title: "Profitability Analysis",
                  description:
                      "Evaluate financial performance and investment return scenarios.",
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _DesktopFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _DesktopFeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor:
                Colors.green.withOpacity(.12),
            child: Icon(
              icon,
              color: const Color(0xFF2E7D32),
              size: 28,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            description,
            style: TextStyle(
              color: Colors.grey.shade600,
              height: 1.6,
              fontSize: 15,
            ),
          ),

          const Spacer(),

          const Row(
            children: [
              Text(
                "Learn more",
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.arrow_forward,
                size: 18,
                color: Color(0xFF2E7D32),
              ),
            ],
          )
        ],
      ),
    );
  }
}