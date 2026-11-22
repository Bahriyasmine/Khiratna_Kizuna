import 'package:flutter/material.dart';

class MarketHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const MarketHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(subtitle, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}