import 'package:flutter/material.dart';

class SoilHeader extends StatelessWidget {
  const SoilHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Soil Parameters',
          style: TextStyle(
            fontSize: 24,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        SizedBox(height: 8),

        Text(
          'Enter the soil characteristics below to receive crop recommendations.',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}