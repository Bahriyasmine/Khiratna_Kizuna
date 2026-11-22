import 'package:flutter/material.dart';
import 'package:khiratna_frontend/view/services/services_screen.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback? onExplore;
  final void Function(String serviceName, int priceTnd)? onPremiumSelect;

  const HeroSection({
    super.key,
    this.onExplore,
    this.onPremiumSelect,
  });

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: .18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'KHIRATNA Premium',
                  style: TextStyle(
                    fontSize: 22,
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
                const SizedBox(height: 16),
                ...services.map(
                  (item) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F9F5),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFD1FAE5)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D3B24).withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            item.icon,
                            color: const Color(0xFF0D3B24),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: Color(0xFF0D3B24),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.subtitle,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${item.priceTnd} TND',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              height: 32,
                              child: ElevatedButton(
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
                                    horizontal: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Choose',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D3B24), Color(0xFF2E7D32)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D3B24).withValues(alpha: .25),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // decorative circles
            Positioned(
              top: -50,
              right: -40,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: .06),
                ),
              ),
            ),
            Positioned(
              bottom: -70,
              left: -50,
              child: Container(
                width: 210,
                height: 210,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF22C55E).withValues(alpha: .12),
                ),
              ),
            ),
            Positioned(
              top: 72,
              right: 24,
              child: Icon(
                Icons.eco_rounded,
                size: 64,
                color: Colors.white.withValues(alpha: .14),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .15),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  "AI-Powered Agriculture",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => _openPremiumSheet(context),
                        icon: const Icon(
                          Icons.workspace_premium,
                          size: 16,
                          color: Color(0xFF0D3B24),
                        ),
                        label: const Text(
                          "Premium",
                          style: TextStyle(
                            color: Color(0xFF0D3B24),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFBBF7D0),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  const Text(
                    "KHIRATNA",
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Smart farming for Tunisia",
                    style: TextStyle(
                      color: Color(0xFFBBF7D0),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    "Helping farmers optimize crops, irrigation, rainfall planning and solar energy through Artificial Intelligence.",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .85),
                      height: 1.7,
                    ),
                  ),

                  const SizedBox(height: 22),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _chip(Icons.cloud_outlined, "Rain"),
                      _chip(Icons.grass, "Soil"),
                      _chip(Icons.show_chart, "Market"),
                    ],
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed:
                          onExplore ??
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ServicesScreen(),
                            ),
                          ),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text(
                        "Explore Services",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0D3B24),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}