import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class DesktopHero extends StatelessWidget {
  final void Function(String serviceName, int priceTnd)? onPremiumSelect;

  const DesktopHero({
    super.key,
    this.onPremiumSelect,
  });

  void _openPremiumSheet(BuildContext context) {
    final services = [
      (
        icon: Icons.cloud_done_outlined,
        title: 'Rain Forecast Service',
        subtitle: 'Hyper-local rainfall alerts & irrigation timing',
        priceTnd: 15,
      ),
      (
        icon: Icons.smart_toy_outlined,
        title: 'AI Assistant',
        subtitle: '24/7 crop diagnostics, soil advice & solar tips',
        priceTnd: 25,
      ),
      (
        icon: Icons.trending_up,
        title: 'Market Forecasting',
        subtitle: 'Wholesale price trends & harvest timing insights',
        priceTnd: 20,
      ),
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Text(
                    'KHIRATNA Premium',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0D3B24),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select a service (prices in Tunisian Dinars / month)',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ...services.map(
                    (item) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F9F5),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFD1FAE5)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D3B24)
                                  .withValues(alpha: .1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              item.icon,
                              color: const Color(0xFF0D3B24),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Color(0xFF0D3B24),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.subtitle,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${item.priceTnd} TND',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(sheetContext);
                                  if (onPremiumSelect != null) {
                                    onPremiumSelect!(item.title, item.priceTnd);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${item.title} (${item.priceTnd} TND/mo) selected',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0D3B24),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Choose'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 520,
        autoPlay: true,
        viewportFraction: 1,
        autoPlayInterval: const Duration(seconds: 5),
      ),
      items: [
        _slide(
          context: context,
          title: "KHIRATNA",
          subtitle: "AI-Powered Agriculture",
          description:
              "Helping Tunisian farmers make smarter crop, water and energy decisions.",
          icon: Icons.energy_savings_leaf,
        ),
        _slide(
          context: context,
          title: "98% Accuracy",
          subtitle: "Forecast Validation",
          description:
              "Validated through historical climate and agricultural backtesting.",
          icon: Icons.analytics,
        ),
        _slide(
          context: context,
          title: "4 Smart Services",
          subtitle: "Built For Farmers",
          description:
              "Rain Forecasting, Soil Analysis, Smart Maps and AI Recommendations.",
          icon: Icons.agriculture,
        ),
      ],
    );
  }

  Widget _slide({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.symmetric(
        horizontal: 80,
        vertical: 48,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0D3B24),
            Color(0xFF2E7D32),
          ],
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: TextButton.icon(
              onPressed: () => _openPremiumSheet(context),
              icon: const Icon(
                Icons.workspace_premium,
                size: 18,
                color: Color(0xFF0D3B24),
              ),
              label: const Text(
                "Premium",
                style: TextStyle(
                  color: Color(0xFF0D3B24),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFBBF7D0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 72,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.7,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Icon(
                  icon,
                  color: Colors.white24,
                  size: 260,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}