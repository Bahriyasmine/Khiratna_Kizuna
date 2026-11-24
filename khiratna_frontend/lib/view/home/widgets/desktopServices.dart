import 'package:flutter/material.dart';

class ServicesDesktopSection extends StatelessWidget {
  const ServicesDesktopSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      child: Column(
        children: [
          const Text(
            "Our Services",
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            "Comprehensive AI-powered solutions designed to support agricultural decision-making from planning to profitability.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 40),

          /// FIRST ROW
          Row(
            children: const [
              Expanded(
                child: DesktopServiceCard(
                  icon: Icons.cloud,
                  title: "Rain Forecast",
                  description:
                      "Advanced rainfall predictions and irrigation planning recommendations.",
                ),
              ),

              SizedBox(width: 20),

              Expanded(
                child: DesktopServiceCard(
                  icon: Icons.grass,
                  title: "Soil Analysis",
                  description:
                      "Land suitability assessment and crop compatibility insights.",
                ),
              ),

              SizedBox(width: 20),

              Expanded(
                child: DesktopServiceCard(
                  icon: Icons.map,
                  title: "Smart Maps",
                  description:
                      "Interactive agricultural mapping and spatial intelligence tools.",
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// SECOND ROW
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: const [
              SizedBox(
                width: 420,
                child: DesktopServiceCard(
                  icon: Icons.smart_toy,
                  title: "AI Assistant",
                  description:
                      "Personalized agricultural guidance and intelligent recommendations.",
                ),
              ),

              SizedBox(width: 20),

              SizedBox(
                width: 420,
                child: DesktopServiceCard(
                  icon: Icons.query_stats,
                  title: "Market Forecasting",
                  description:
                      "Predict market demand, identify profitable crops and support food security strategies.",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DesktopServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const DesktopServiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 250,
        ),
        height: 270,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(28),
          border: Border.all(
            color:
                Colors.green.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                0.05,
              ),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(
                  0xFF2E7D32,
                ).withOpacity(.08),
                borderRadius:
                    BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color:
                    const Color(0xFF2E7D32),
                size: 34,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
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
                  "Explore",
                  style: TextStyle(
                    color: Color(
                      0xFF2E7D32,
                    ),
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                SizedBox(width: 8),

                Icon(
                  Icons.arrow_forward,
                  color:
                      Color(0xFF2E7D32),
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}