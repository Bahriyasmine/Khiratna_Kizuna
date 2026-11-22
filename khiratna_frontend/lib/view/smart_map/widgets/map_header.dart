import 'package:flutter/material.dart';

class SoilHeader extends StatelessWidget {
  const SoilHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Smart Maps',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 8),

        Text(
          'Explore agricultural insights across Tunisia.',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}