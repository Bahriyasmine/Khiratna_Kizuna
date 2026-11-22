import 'package:flutter/material.dart';
import 'package:khiratna_frontend/core/constants/app_colors.dart';
import 'package:khiratna_frontend/core/widgets/app_card.dart';
import 'package:khiratna_frontend/core/widgets/app_dropdown.dart';
import 'package:khiratna_frontend/viewmodel/marketforecast/crop_revenue_viewmodel.dart';
import 'package:provider/provider.dart';

class CropRevenueForm extends StatelessWidget {
  const CropRevenueForm({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CropRevenueViewModel>();

    return AppCard(
      child: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth >= 560;

          final governorate = AppDropdown(
            label: 'My governorate',
            value: vm.governorate,
            items: vm.governorates,
            onChanged: vm.setGovernorate,
          );

          final month = AppDropdown(
            label: 'Planting month',
            value: vm.month,
            items: vm.months,
            onChanged: vm.setMonth,
          );

          final button = SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: vm.canCalculate ? vm.calculate : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: vm.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Calculate',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
            ),
          );

          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: governorate),
                const SizedBox(width: 16),
                Expanded(child: month),
                const SizedBox(width: 16),
                SizedBox(width: 180, child: button),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              governorate,
              const SizedBox(height: 16),
              month,
              const SizedBox(height: 20),
              button,
            ],
          );
        },
      ),
    );
  }
}