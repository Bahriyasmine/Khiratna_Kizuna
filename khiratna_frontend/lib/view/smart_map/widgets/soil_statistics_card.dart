import 'package:flutter/material.dart';
import 'package:khiratna_frontend/core/utils/number_format.dart';
import 'package:khiratna_frontend/model/smart_maps/governorate_map_data.dart';

const _green = Color(0xFF0F9D58);

// Plain-language meaning of each soil group, used when the backend
// doesn't send a description. Edit the wording freely.
const _soilDescriptions = <String, String>{
  'calcisol': 'soil with a lot of lime; common in dry areas; good when irrigated',
  'solonchak': 'salty soil; most crops suffer',
  'arenosol': 'sandy soil; holds little water and food',
  'cambisol': 'young, fairly fertile soil; usually good for farming',
  'fluvisol': 'river-deposited soil; fertile and often well watered',
  'regosol': 'thin, weakly developed soil; low in organic matter',
  'vertisol': 'heavy clay soil; rich but hard to work when dry or wet',
  'leptosol': 'very shallow, stony soil; poor for crops',
  'luvisol': 'clay-rich soil; fertile when well managed',
  'gypsisol': 'soil with gypsum; dry areas; needs irrigation',
  'solonetz': 'sodium-rich soil; poor structure and drainage',
};

String _n(double v, {int decimals = 2}) {
  var s = v.toStringAsFixed(decimals);
  if (s.contains('.')) {
    s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
  return s;
}

class SoilStatisticsCard extends StatelessWidget {
  final GovernorateSoilData data;

  const SoilStatisticsCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final rows = <_RowData>[
      if (data.saltyAreaPct != null)
        _RowData('Area with salty soil', '${_n(data.saltyAreaPct!, decimals: 1)} %'),
      if (data.sodicAreaPct != null)
        _RowData('Area with sodic soil', '${_n(data.sodicAreaPct!, decimals: 1)} %'),
      _RowData('Typical salt', '${_n(data.salinity)} dS/m', data.salinityLabel),
      _RowData('Typical pH', _n(data.ph), data.phLabel),
      if (data.lime != null)
        _RowData('Typical lime', '${_n(data.lime!)} g/kg', data.limeLabel),
      _RowData('Typical organic carbon', '${_n(data.organicCarbon)} g/kg'),
      _RowData('Typical nitrogen', '${_n(data.nitrogen)} g/kg'),
      if (data.waterStoredMm != null)
        _RowData(
          'Water stored for roots',
          '${_n(data.waterStoredMm!, decimals: 0)} mm of water per metre of soil',
        ),
    ];

    return Card(
      color: Colors.white,
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(data: data),
            const SizedBox(height: 16),
            if (data.hasNoData)
              Text(
                'No soil data available for this governorate yet.',
                style: TextStyle(color: Colors.grey.shade600),
              )
            else ...[
              _MainSoils(data: data),
              const SizedBox(height: 12),
              for (var i = 0; i < rows.length; i++) ...[
                _StatRow(row: rows[i]),
                if (i != rows.length - 1)
                  Divider(height: 1, color: Colors.grey.shade200),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final GovernorateSoilData data;
  const _Header({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _green.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.landscape_rounded, color: _green, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: data.governorate,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B4332),
                  ),
                ),
                if (data.areaKm2 != null)
                  TextSpan(
                    text: '  (${formatNumber(data.areaKm2!)} km² of land)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MainSoils extends StatelessWidget {
  final GovernorateSoilData data;
  const _MainSoils({required this.data});

  @override
  Widget build(BuildContext context) {
    final hasShares = data.soilShares.isNotEmpty;
    if (!hasShares && data.mainSoils.isEmpty) return const SizedBox.shrink();

    const body = TextStyle(fontSize: 14, height: 1.5, color: Colors.black87);

    Widget line(String? percent, String name, String description) {
      return Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text.rich(
          TextSpan(
            style: body,
            children: [
              if (percent != null) TextSpan(text: '$percent '),
              TextSpan(
                text: name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              if (description.isNotEmpty) TextSpan(text: ' — $description'),
            ],
          ),
        ),
      );
    }

    String describe(String name, String fromBackend) {
      if (fromBackend.isNotEmpty) return fromBackend;
      return _soilDescriptions[name.toLowerCase()] ?? '';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Main soils:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        if (hasShares)
          for (final s in data.soilShares)
            line('${s.percent.round()}%', s.name, describe(s.name, s.description))
        else
          for (final name in data.mainSoils) line(null, name, describe(name, '')),
      ],
    );
  }
}

class _RowData {
  final String label;
  final String value;
  final String? note;
  const _RowData(this.label, this.value, [this.note]);
}

class _StatRow extends StatelessWidget {
  final _RowData row;
  const _StatRow({required this.row});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(row.label, style: const TextStyle(fontSize: 15)),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  row.value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (row.note != null && row.note!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      row.note!,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}