import 'package:flutter/material.dart';

import 'section_title.dart';

class WhyChooseSection extends StatelessWidget {
  const WhyChooseSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SectionTitle("Why Choose Khiratna?"),

          const SizedBox(height: 22),

          LayoutBuilder(
            builder: (context, c) {
              final w = (c.maxWidth - 12) / 2;

              const items = [
                _Feature(
                  Icons.water_drop,
                  "Optimisation Hydrique",
                  "Calculez les besoins en eau de chaque culture, mois par mois.",
                  Colors.blue,
                ),
                _Feature(
                  Icons.agriculture,
                  "Cultures Intelligentes",
                  "Trouvez les cultures adaptées à votre sol et votre climat.",
                  Color(0xFF2E7D32),
                ),
                _Feature(
                  Icons.solar_power,
                  "Énergie Solaire",
                  "Estimez le potentiel solaire de votre exploitation.",
                  Colors.orange,
                ),
                _Feature(
                  Icons.trending_up,
                  "Rentabilité",
                  "Comparez les revenus par hectare et par m³ d'eau.",
                  Colors.teal,
                ),
              ];

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final f in items)
                    SizedBox(width: w, child: _FeatureCard(f)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String text;
  final Color color;

  const _Feature(this.icon, this.title, this.text, this.color);
}

class _FeatureCard extends StatelessWidget {
  final _Feature f;

  const _FeatureCard(this.f);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 190),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: f.color.withValues(alpha: .15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: f.color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(f.icon, color: f.color, size: 24),
          ),
          const SizedBox(height: 14),
          Text(
            f.title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            f.text,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}