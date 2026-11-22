double _d(dynamic v) => (v as num).toDouble();

class RainfallCrop {
  final String id;
  final String name;
  final String type;

  RainfallCrop({required this.id, required this.name, required this.type});

  factory RainfallCrop.fromJson(Map<String, dynamic> j) => RainfallCrop(
        id: j['id'] as String,
        name: j['name'] as String,
        type: j['type'] as String,
      );
}

class RainfallOptions {
  final List<String> regions;
  final List<RainfallCrop> crops;
  final String first; // "2026-01"
  final String last; // "2027-12"

  RainfallOptions({
    required this.regions,
    required this.crops,
    required this.first,
    required this.last,
  });

  static DateTime _parse(String ym) {
    final p = ym.split('-');
    return DateTime(int.parse(p[0]), int.parse(p[1]));
  }

  DateTime get firstDate => _parse(first);

  // last day of the last month
  DateTime get lastDate {
    final d = _parse(last);
    return DateTime(d.year, d.month + 1, 0);
  }

  factory RainfallOptions.fromJson(Map<String, dynamic> j) => RainfallOptions(
        regions: (j['regions'] as List).map((e) => e.toString()).toList(),
        crops: (j['crops'] as List)
            .map((e) => RainfallCrop.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        first: j['months']['first'] as String,
        last: j['months']['last'] as String,
      );
}

class WaterMonth {
  final String month; // "2026-11"
  final double rainMm;
  final bool rainObserved; // false = forecast
  final double rainDryYearMm;
  final double rainWetYearMm;
  final double et0Mm;
  final bool et0Observed; // false = normal
  final double kc;
  final double cropNeedMm;
  final double usefulRainMm;
  final double waterToAddMm;
  final double waterToAddM3PerHa;

  WaterMonth({
    required this.month,
    required this.rainMm,
    required this.rainObserved,
    required this.rainDryYearMm,
    required this.rainWetYearMm,
    required this.et0Mm,
    required this.et0Observed,
    required this.kc,
    required this.cropNeedMm,
    required this.usefulRainMm,
    required this.waterToAddMm,
    required this.waterToAddM3PerHa,
  });

  factory WaterMonth.fromJson(Map<String, dynamic> j) => WaterMonth(
        month: j['month'] as String,
        rainMm: _d(j['rain_mm']),
        rainObserved: j['rain_source'] == 'observed',
        rainDryYearMm: _d(j['rain_dry_year_mm']),
        rainWetYearMm: _d(j['rain_wet_year_mm']),
        et0Mm: _d(j['et0_mm']),
        et0Observed: j['et0_source'] == 'observed',
        kc: _d(j['kc']),
        cropNeedMm: _d(j['crop_need_mm']),
        usefulRainMm: _d(j['useful_rain_mm']),
        waterToAddMm: _d(j['water_to_add_mm']),
        waterToAddM3PerHa: _d(j['water_to_add_m3_per_ha']),
      );
}

class WaterTotal {
  final double rainMm;
  final double cropNeedMm;
  final double waterToAddMm;
  final double waterToAddM3PerHa;

  WaterTotal({
    required this.rainMm,
    required this.cropNeedMm,
    required this.waterToAddMm,
    required this.waterToAddM3PerHa,
  });

  factory WaterTotal.fromJson(Map<String, dynamic> j) => WaterTotal(
        rainMm: _d(j['rain_mm']),
        cropNeedMm: _d(j['crop_need_mm']),
        waterToAddMm: _d(j['water_to_add_mm']),
        waterToAddM3PerHa: _d(j['water_to_add_m3_per_ha']),
      );
}

class WaterForecast {
  final String region;
  final String crop;
  final String start;
  final String end;
  final WaterTotal total;
  final List<WaterMonth> months;
  final String kcSource;

  WaterForecast({
    required this.region,
    required this.crop,
    required this.start,
    required this.end,
    required this.total,
    required this.months,
    required this.kcSource,
  });

  /// Share of the crop's water need covered by useful rain (0-100).
  double get coveragePercent {
    final need = months.fold<double>(0, (s, m) => s + m.cropNeedMm);
    if (need <= 0) return 0;
    final useful = months.fold<double>(0, (s, m) => s + m.usefulRainMm);
    return (useful / need * 100).clamp(0, 100);
  }

  /// Month needing the most irrigation.
  WaterMonth? get peakMonth {
    if (months.isEmpty) return null;
    return months.reduce((a, b) => b.waterToAddMm > a.waterToAddMm ? b : a);
  }

  factory WaterForecast.fromJson(Map<String, dynamic> j) => WaterForecast(
        region: j['region'] as String,
        crop: j['crop'] as String,
        start: j['start'] as String,
        end: j['end'] as String,
        total: WaterTotal.fromJson(Map<String, dynamic>.from(j['total'] as Map)),
        months: (j['months'] as List)
            .map((e) => WaterMonth.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        kcSource: (j['kc_source'] ?? '').toString(),
      );
}