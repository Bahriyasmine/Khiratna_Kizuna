import 'package:flutter/material.dart';
import 'package:khiratna_frontend/model/marketforecast/market_product.dart';

class PlantingStatusChip extends StatelessWidget {
  final PlantingStatus status;
  const PlantingStatusChip({super.key, required this.status});

  (Color, Color) get _colors {
    switch (status) {
      case PlantingStatus.openField:
        return (const Color(0xFF2E7D32), const Color(0xFFE8F5E9));
      case PlantingStatus.tree:
        return (const Color(0xFF00695C), const Color(0xFFE0F2F1));
      case PlantingStatus.greenhouse:
        return (const Color(0xFF1565C0), const Color(0xFFE3F2FD));
      case PlantingStatus.frostRisk:
        return (const Color(0xFF0277BD), const Color(0xFFE1F5FE));
      case PlantingStatus.notInSeason:
      case PlantingStatus.noData:
      case PlantingStatus.unknown:
        return (Colors.grey.shade700, Colors.grey.shade200);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (status == PlantingStatus.unknown) return const SizedBox.shrink();

    final (fg, bg) = _colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.35)),
      ),
      child: Text(
        status.label,
        style: TextStyle(fontSize: 10, color: fg),
      ),
    );
  }
}