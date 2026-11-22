import 'package:flutter/material.dart';
import 'package:khiratna_frontend/core/constants/app_colors.dart';

class ShowForecastButton extends StatelessWidget {
  final bool isLoading;
  final bool hasLoaded;
  final VoidCallback onPressed;

  const ShowForecastButton({
    super.key,
    required this.isLoading,
    required this.hasLoaded,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: Icon(hasLoaded ? Icons.refresh : Icons.trending_up_rounded),
      label: Text(hasLoaded ? 'Refresh forecast' : 'Show the 2027 forecast'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade300,
        elevation: 0,
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    );

    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth < 600) {
          return SizedBox(width: double.infinity, child: button);
        }
        return Align(alignment: Alignment.centerLeft, child: button);
      },
    );
  }
}