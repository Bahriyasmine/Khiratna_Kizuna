import 'package:flutter/material.dart';

class SoilLegend extends StatelessWidget {
  const SoilLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ("Low", Colors.green),
      ("Moderate", Colors.orange),
      ("High", Colors.red),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Legend",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 12),

            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: item.$2,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(item.$1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}