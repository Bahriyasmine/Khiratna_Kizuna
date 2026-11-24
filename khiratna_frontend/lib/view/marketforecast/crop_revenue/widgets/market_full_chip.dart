import 'package:flutter/material.dart';

class MarketFullChip extends StatelessWidget {
  const MarketFullChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Text(
        'market already full',
        style: TextStyle(fontSize: 10, color: Colors.orange.shade900),
      ),
    );
  }
}