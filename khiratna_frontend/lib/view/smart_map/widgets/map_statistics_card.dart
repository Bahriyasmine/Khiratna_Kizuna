import 'package:flutter/material.dart';
import 'package:khiratna_frontend/core/utils/number_format.dart';
import 'package:khiratna_frontend/model/smart_maps/governorate_map_data.dart';

const _green = Color(0xFF0F9D58);
const _darkGreen = Color(0xFF1B4332);

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
    String? val(double? v, String unit, {int decimals = 2}) =>
        (v == null || v == 0) ? null : '${_n(v, decimals: decimals)} $unit';

    final rows = <_RowData>[
      _RowData(
        icon: Icons.grain_rounded,
        label: 'Area with salty soil',
        value: data.saltyAreaPct == null
            ? null
            : '${_n(data.saltyAreaPct!, decimals: 1)} %',
        progress: data.saltyAreaPct == null ? null : data.saltyAreaPct! / 100,
      ),
      _RowData(
        icon: Icons.layers_outlined,
        label: 'Area with sodic soil',
        value: data.sodicAreaPct == null
            ? null
            : '${_n(data.sodicAreaPct!, decimals: 1)} %',
        progress: data.sodicAreaPct == null ? null : data.sodicAreaPct! / 100,
      ),
      _RowData(
        icon: Icons.science_outlined,
        label: 'Typical salt',
        value: val(data.salinity, 'dS/m'),
        note: data.salinity == 0 ? null : data.salinityLabel,
      ),
      _RowData(
        icon: Icons.bubble_chart_rounded,
        label: 'Typical pH',
        value: data.ph == 0 ? null : _n(data.ph),
        note: data.ph == 0 ? null : data.phLabel,
      ),
      _RowData(
        icon: Icons.landscape_outlined,
        label: 'Typical lime',
        value: val(data.lime, 'g/kg'),
        note: data.lime == null ? null : data.limeLabel,
      ),
      _RowData(
        icon: Icons.eco_outlined,
        label: 'Typical organic carbon',
        value: val(data.organicCarbon, 'g/kg'),
      ),
      _RowData(
        icon: Icons.grass_rounded,
        label: 'Typical nitrogen',
        value: val(data.nitrogen, 'g/kg'),
      ),
      _RowData(
        icon: Icons.water_drop_outlined,
        label: 'Water stored for roots',
        value: (data.waterStoredMm == null || data.waterStoredMm == 0)
            ? null
            : '${_n(data.waterStoredMm!, decimals: 0)} mm of water per metre of soil',
      ),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(data: data),
          _MainSoils(data: data),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  _StatRow(row: rows[i]),
                  if (i != rows.length - 1)
                    Divider(height: 1, color: Colors.grey.shade200),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Header ─────────────────────────

class _Header extends StatelessWidget {
  final GovernorateSoilData data;
  const _Header({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: _green.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _green,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.landscape_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.governorate,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _darkGreen,
                  ),
                ),
                if (data.areaKm2 != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '${formatNumber(data.areaKm2!)} km² of land',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
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

// ───────────────────────── Main soils ─────────────────────────

class _MainSoils extends StatelessWidget {
  final GovernorateSoilData data;
  const _MainSoils({required this.data});

  String _describe(String name, String fromBackend) {
    if (fromBackend.isNotEmpty) return fromBackend;
    return _soilDescriptions[name.toLowerCase()] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final hasShares = data.soilShares.isNotEmpty;

    final items = hasShares
        ? [
            for (final s in data.soilShares)
              _SoilLine(
                percent: '${s.percent.round()}%',
                name: s.name,
                description: _describe(s.name, s.description),
              ),
          ]
        : [
            for (final name in data.mainSoils)
              _SoilLine(
                percent: null,
                name: name,
                description: _describe(name, ''),
              ),
          ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Main soils',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            Text(
              'No soil types available yet.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            )
          else
            for (var i = 0; i < items.length; i++) ...[
              items[i],
              if (i != items.length - 1) const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _SoilLine extends StatelessWidget {
  final String? percent;
  final String name;
  final String description;

  const _SoilLine({
    required this.percent,
    required this.name,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (percent != null)
          Container(
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: 4),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              percent!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: _green,
              ),
            ),
          )
        else
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 7, left: 4, right: 4),
            decoration:
                const BoxDecoration(color: _green, shape: BoxShape.circle),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: const TextStyle(
                fontSize: 14,
                height: 1.45,
                color: Colors.black87,
              ),
              children: [
                TextSpan(
                  text: name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if (description.isNotEmpty)
                  TextSpan(
                    text: ' — $description',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── Stat rows ─────────────────────────

class _RowData {
  final IconData icon;
  final String label;
  final String? value; // null -> shown as "—"
  final String? note;
  final double? progress; // 0..1, draws a thin bar

  const _RowData({
    required this.icon,
    required this.label,
    required this.value,
    this.note,
    this.progress,
  });
}

class _StatRow extends StatelessWidget {
  final _RowData row;
  const _StatRow({required this.row});

  @override
  Widget build(BuildContext context) {
    final hasValue = row.value != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(row.icon, color: _green, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(row.label, style: const TextStyle(fontSize: 15)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    hasValue ? row.value! : '—',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: hasValue ? Colors.black87 : Colors.grey.shade400,
                    ),
                  ),
                ),
                if (row.progress != null) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: row.progress!.clamp(0.0, 1.0),
                      minHeight: 5,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation(_green),
                    ),
                  ),
                ],
                if (row.note != null && row.note!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    row.note!,
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}