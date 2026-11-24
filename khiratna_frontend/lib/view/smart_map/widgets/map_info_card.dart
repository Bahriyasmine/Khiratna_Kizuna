import 'package:flutter/material.dart';

class SoilInfoCard extends StatelessWidget {
  final String title;
  final String description;
  final String importance;

  const SoilInfoCard({
    super.key,
    required this.title,
    required this.description,
    required this.importance,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8),

            Text(description),

            SizedBox(height: 8),

            Text(
              "Why it matters: $importance",
            ),
          ],
        ),
      ),
    );
  }
}