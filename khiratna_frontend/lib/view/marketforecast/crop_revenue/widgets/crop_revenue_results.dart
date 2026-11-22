import 'package:flutter/material.dart';
import 'package:khiratna_frontend/core/constants/app_colors.dart';
import 'package:khiratna_frontend/core/utils/number_format.dart';
import 'package:khiratna_frontend/core/widgets/app_card.dart';
import 'package:khiratna_frontend/core/widgets/error_retry.dart';
import 'package:khiratna_frontend/model/marketforecast/crop_revenue.dart';
import 'package:khiratna_frontend/viewmodel/marketforecast/crop_revenue_viewmodel.dart';
import 'package:provider/provider.dart';

import 'market_full_chip.dart';
import 'planting_status_chip.dart';

class CropRevenueResults extends StatelessWidget {
  const CropRevenueResults({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CropRevenueViewModel>();

    if (vm.isLoading) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
      );
    }

    if (vm.errorMessage != null) {
      return ErrorRetry(message: vm.errorMessage!, onRetry: vm.calculate);
    }

    if (!vm.hasCalculated) {
      return AppCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.eco_outlined, size: 36, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'Choose your governorate and planting month, then tap Calculate.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    final nothing = vm.results.isEmpty &&
        vm.greenhouseOnly.isEmpty &&
        vm.frostRisk.isEmpty &&
        vm.notInSeason.isEmpty;

    if (nothing) {
      return const Center(child: Text('No results for this selection.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (vm.results.isNotEmpty)
          _ResultsTable(results: vm.results)
        else
          const _InfoBox(
            'No crop can be planted in the open field or as a tree in '
            'this month for this governorate.',
          ),

        if (vm.greenhouseOnly.isNotEmpty) ...[
          const SizedBox(height: 24),
          const _SectionTitle('Only under a greenhouse or tunnel this month'),
          const SizedBox(height: 10),
          _ResultsTable(results: vm.greenhouseOnly),
        ],

        if (vm.frostRisk.isNotEmpty) ...[
          const SizedBox(height: 24),
          _NameChips(
            title: 'Frost risk this month in your governorate',
            names: vm.frostRisk,
          ),
        ],

        if (vm.notInSeason.isNotEmpty) ...[
          const SizedBox(height: 24),
          _NameChips(
            title: 'Not a planting month here',
            names: vm.notInSeason,
          ),
        ],

        const SizedBox(height: 16),
        Text(
          'Prices and yields are national (FAOSTAT). Your governorate and '
          'planting month only change the water each crop needs. '
          'Revenue means sales (yield × price), not profit.',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String text;
  const _InfoBox(this.text);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Text(text, style: TextStyle(color: Colors.grey.shade700)),
    );
  }
}

class _NameChips extends StatelessWidget {
  final String title;
  final List<String> names;
  const _NameChips({required this.title, required this.names});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final n in names)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(n, style: const TextStyle(fontSize: 12)),
              ),
          ],
        ),
      ],
    );
  }
}

class _ResultsTable extends StatelessWidget {
  final List<CropRevenue> results;
  const _ResultsTable({required this.results});

  @override
  Widget build(BuildContext context) {
    const head = TextStyle(fontWeight: FontWeight.w700, fontSize: 13);

    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Container(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: const Row(
                children: [
                  Expanded(flex: 4, child: Text('Product', style: head)),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Revenue per hectare',
                      textAlign: TextAlign.right,
                      style: head,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Dinars per m³ of water',
                      textAlign: TextAlign.right,
                      style: head,
                    ),
                  ),
                ],
              ),
            ),
            for (var i = 0; i < results.length; i++) ...[
              _Row(crop: results[i]),
              if (i != results.length - 1)
                Divider(height: 1, color: Colors.grey.shade200),
            ],
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final CropRevenue crop;
  const _Row({required this.crop});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      crop.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    PlantingStatusChip(status: crop.plantingStatus),
                    if (crop.marketFull) const MarketFullChip(),
                  ],
                ),
                if (crop.yieldNote.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    crop.yieldNote,
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '${formatNumber(crop.revenuePerHa)} TND',
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: crop.dinarsPerM3.toStringAsFixed(2),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(text: ' TND'),
                ],
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}