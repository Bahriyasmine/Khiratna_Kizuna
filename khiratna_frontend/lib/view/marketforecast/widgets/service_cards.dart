import 'package:flutter/material.dart';
import 'package:khiratna_frontend/core/constants/app_colors.dart';
import 'package:khiratna_frontend/core/widgets/app_card.dart';
import 'package:khiratna_frontend/view/marketforecast/crop_revenue/crop_revenue_screen.dart';
import 'package:khiratna_frontend/view/marketforecast/tunisia_lack/tunisia_lack_screen.dart';

class ServiceCards extends StatelessWidget {
  final bool horizontal;
  const ServiceCards({super.key, required this.horizontal});

  @override
  Widget build(BuildContext context) {
    final lack = _ServiceCard(
      icon: Icons.trending_down_rounded,
      title: 'What will Tunisia lack?',
      description:
          'National forecast of the products Tunisia will be missing in 2027, based on FAO statistics.',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TunisiaLackScreen()),
      ),
    );

    final revenue = _ServiceCard(
      icon: Icons.water_drop_outlined,
      title: 'Which crop earns the most?',
      description:
          'Compare crops by the dinars they earn per m³ of water, for your governorate and planting month.',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CropRevenueScreen()),
      ),
    );

    if (horizontal) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: lack),
            const SizedBox(width: 20),
            Expanded(child: revenue),
          ],
        ),
      );
    }

    return Column(children: [lack, const SizedBox(height: 16), revenue]);
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 26),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                'Open',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.primaryGreen,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}