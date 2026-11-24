import 'package:flutter/material.dart';
import 'crop_revenue_form.dart';
import 'crop_revenue_results.dart';

class CropRevenueBody extends StatelessWidget {
  const CropRevenueBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CropRevenueForm(),
        SizedBox(height: 24),
        CropRevenueResults(),
      ],
    );
  }
}