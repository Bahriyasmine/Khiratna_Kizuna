import 'package:flutter/material.dart';
import 'package:khiratna_frontend/core/constants/app_colors.dart';
import 'package:khiratna_frontend/core/utils/number_format.dart';
import 'package:khiratna_frontend/core/widgets/app_card.dart';
import 'package:khiratna_frontend/model/marketforecast/product_forecast.dart';

const _red = Color(0xFFD32F2F);

class ShortageList extends StatelessWidget {
  final List<ProductForecast> products;
  const ShortageList({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) =>
          c.maxWidth >= 600 ? _Table(products) : _Cards(products),
    );
  }
}

class _Sufficiency extends StatelessWidget {
  final ProductForecast p;
  const _Sufficiency(this.p);

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '${p.sufficiency2024} % → '),
          TextSpan(
            text: '${p.sufficiency2027} %',
            style: TextStyle(
              color: p.isWorsening ? _red : null,
              fontWeight: p.isWorsening ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _Table extends StatelessWidget {
  final List<ProductForecast> products;
  const _Table(this.products);

  @override
  Widget build(BuildContext context) {
    const head = TextStyle(fontWeight: FontWeight.w700, fontSize: 14);

    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Container(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: const Row(
                children: [
                  Expanded(flex: 2, child: Text('Product', style: head)),
                  Expanded(
                    flex: 3,
                    child: Text('Self-sufficiency 2024 → 2027', style: head),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Missing in 2027',
                      textAlign: TextAlign.right,
                      style: head,
                    ),
                  ),
                ],
              ),
            ),
            for (var i = 0; i < products.length; i++) ...[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        products[i].name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Expanded(flex: 3, child: _Sufficiency(products[i])),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${formatNumber(products[i].missingTonnes)} t',
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              if (i != products.length - 1)
                Divider(height: 1, color: Colors.grey.shade200),
            ],
          ],
        ),
      ),
    );
  }
}

class _Cards extends StatelessWidget {
  final List<ProductForecast> products;
  const _Cards(this.products);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final p in products)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              radius: 20,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Stat(
                        label: 'Self-sufficiency 2024 → 2027',
                        child: _Sufficiency(p),
                      ),
                      _Stat(
                        label: 'Missing in 2027',
                        alignEnd: true,
                        child: Text('${formatNumber(p.missingTonnes)} t'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final Widget child;
  final bool alignEnd;

  const _Stat({
    required this.label,
    required this.child,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}