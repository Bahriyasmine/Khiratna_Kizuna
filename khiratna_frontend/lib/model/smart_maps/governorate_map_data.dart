import 'package:flutter/foundation.dart';

class SoilShare {
  final double percent; // 0..100
  final String name;
  final String description;

  const SoilShare({
    required this.percent,
    required this.name,
    this.description = '',
  });
}

class GovernorateSoilData {
  final String governorate;

  final double salinity;
  final double ph;
  final double organicCarbon;
  final double nitrogen;

  final List<String> mainSoils;

  final double? areaKm2;
  final double? saltyAreaPct;
  final double? sodicAreaPct;
  final double? lime;
  final double? waterStoredMm;
  final String? salinityNote;
  final String? phNote;
  final String? limeNote;
  final List<SoilShare> soilShares;

  GovernorateSoilData({
    required this.governorate,
    required this.salinity,
    required this.ph,
    required this.organicCarbon,
    required this.nitrogen,
    required this.mainSoils,
    this.areaKm2,
    this.saltyAreaPct,
    this.sodicAreaPct,
    this.lime,
    this.waterStoredMm,
    this.salinityNote,
    this.phNote,
    this.limeNote,
    this.soilShares = const [],
  });

  factory GovernorateSoilData.empty(String name) => GovernorateSoilData(
        governorate: name,
        salinity: 0,
        ph: 0,
        organicCarbon: 0,
        nitrogen: 0,
        mainSoils: const [],
      );

  bool get hasNoData =>
      salinity == 0 && ph == 0 && organicCarbon == 0 && nitrogen == 0;

  // Labels: use the backend's when present, otherwise a rough local guess
  String get salinityLabel => salinityNote ?? _salinityClass(salinity);
  String get phLabel => phNote ?? _phClass(ph);
  String? get limeLabel =>
      limeNote ?? (lime == null ? null : _limeClass(lime!));

  static String _salinityClass(double ec) {
    if (ec < 2) return 'not salty';
    if (ec < 4) return 'slightly salty';
    if (ec < 8) return 'moderately salty';
    if (ec < 16) return 'strongly salty';
    return 'very strongly salty';
  }

  static String _phClass(double ph) {
    if (ph < 5.5) return 'acidic';
    if (ph < 6.5) return 'slightly acidic';
    if (ph < 7.4) return 'neutral';
    if (ph < 7.8) return 'slightly alkaline';
    if (ph < 8.4) return 'moderately alkaline';
    return 'strongly alkaline';
  }

  static String _limeClass(double gPerKg) {
    if (gPerKg < 30) return 'slightly limey';
    if (gPerKg < 150) return 'moderately limey';
    return 'strongly limey';
  }

  factory GovernorateSoilData.fromJson(
    Map<String, dynamic> json, {
    required String fallbackName,
  }) {
    // ---- flatten the whole response (any depth) ----
    // Nested keys are joined: {"salt": {"value": 1}} -> "saltvalue"
    // and the bare child key is also kept: "value".
    final flat = <String, dynamic>{};

    void walk(Map m, String prefix) {
      m.forEach((k, v) {
        final key = _norm(k.toString());
        if (v is Map) {
          walk(v, '$prefix$key');
        } else {
          flat.putIfAbsent('$prefix$key', () => v);
          if (prefix.isNotEmpty) flat.putIfAbsent(key, () => v);
        }
      });
    }

    walk(json, '');
    debugPrint('SOIL REGION flat keys: ${flat.keys.toList()}');

    bool has(String key, List<String> tokens) =>
        tokens.any((t) => key.contains(t));

    // First entry whose key matches the rules
    dynamic pick({
      List<String> exact = const [],
      List<String> startsWith = const [],
      List<String> any = const [],
      List<String> all = const [],
      List<String> none = const [],
    }) {
      for (final e in flat.entries) {
        final k = e.key;
        if (e.value == null) continue;
        if (none.isNotEmpty && has(k, none)) continue;

        if (exact.contains(k)) return e.value;
        if (startsWith.any((s) => k.startsWith(s))) {
          if (none.isEmpty || !has(k, none)) return e.value;
        }
        if (any.isNotEmpty && has(k, any)) {
          if (all.isEmpty || all.every(k.contains)) return e.value;
        }
      }
      return null;
    }

    double? asNumber(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) {
        final cleaned = v.replaceAll(',', '.').replaceAll(RegExp(r'[^0-9.\-]'), '');
        return double.tryParse(cleaned);
      }
      return null;
    }

    String? asText(dynamic v) {
      final s = v?.toString().trim();
      return (s == null || s.isEmpty) ? null : s;
    }

    const noteWords = ['class', 'label', 'note', 'category', 'text', 'desc', 'level', 'rating'];
    const areaWords = ['area', 'pct', 'percent', 'share', 'fraction', 'ratio'];

    // ---- numbers ----
    final saltyPct = asNumber(pick(
      any: ['salt', 'salin', 'saline', 'solonchak'],
      all: [],
      none: [...noteWords, 'dsm', 'ds', 'ec', 'typical', 'mean', 'avg', 'sodic'],
    ));
    final sodicPct = asNumber(pick(
      any: ['sodic', 'sodicity', 'esp'],
      none: [...noteWords, 'typical', 'mean', 'avg'],
    ));

    // Percent rows must really be percentages of area, so prefer keys with an area word
    final saltyArea = asNumber(pick(
          any: ['salt', 'salin', 'saline'],
          all: [],
          none: [...noteWords, 'typical', 'mean', 'avg', 'sodic', 'dsm', 'ec'],
        )) ??
        saltyPct;

    final salinity = asNumber(pick(
          exact: ['ec', 'salinity', 'soilsalinity', 'typicalsalt', 'salt'],
          startsWith: ['ec'],
          any: ['salt', 'salin', 'conduct'],
          none: [...noteWords, ...areaWords, 'sodic'],
        )) ??
        0;

    final ph = asNumber(pick(
          exact: ['ph', 'soilph', 'typicalph'],
          startsWith: ['ph'],
          any: ['typicalph'],
          none: noteWords,
        )) ??
        0;

    final organic = asNumber(pick(
          exact: ['organiccarbon', 'oc', 'soc'],
          startsWith: ['organiccarbon', 'oc', 'soc'],
          any: ['organiccarbon', 'organic'],
          none: noteWords,
        )) ??
        0;

    final nitrogen = asNumber(pick(
          exact: ['nitrogen', 'totalnitrogen', 'n'],
          any: ['nitrogen'],
          none: noteWords,
        )) ??
        0;

    final lime = asNumber(pick(
      exact: ['lime', 'caco3', 'limecontent'],
      any: ['lime', 'caco3', 'calcium'],
      none: noteWords,
    ));

    final water = asNumber(pick(
      any: ['water', 'awc', 'whc', 'available', 'holding'],
      none: noteWords,
    ));

    final area = asNumber(pick(
      exact: ['areakm2', 'area', 'landarea', 'areasqkm', 'surface', 'km2'],
      any: ['km2', 'landarea', 'areakm'],
      none: ['salt', 'salin', 'sodic', 'pct', 'percent', 'share'],
    ));

    // ---- notes ----
    final salinityNote = asText(pick(
      any: ['salt', 'salin'],
      all: [],
      none: ['value', 'dsm', 'area', 'pct', 'percent', 'sodic', 'ec'],
    ));
    final phNote = asText(pick(any: ['phclass', 'phlabel', 'phnote', 'phlevel', 'phcategory']));
    final limeNote = asText(pick(
      any: ['limeclass', 'limelabel', 'limenote', 'limelevel', 'caco3class', 'caco3label'],
    ));

    // Only keep a note when it is text, not a number
    String? onlyText(String? s) => (s == null || asNumber(s) != null && s.length < 8) ? null : s;

    // ---- soils ----
    final shares = <SoilShare>[];
    final names = <String>[];

    dynamic rawSoils;
    for (final e in json.entries) {
      final k = _norm(e.key);
      if (e.value is List && (k.contains('soil') || k.contains('wrb') || k.contains('rsg'))) {
        rawSoils = e.value;
        break;
      }
    }

    if (rawSoils is List) {
      for (final e in rawSoils) {
        if (e is Map) {
          final m = {for (final en in e.entries) _norm(en.key.toString()): en.value};
          final name = (m['name'] ?? m['soil'] ?? m['type'] ?? m['group'] ?? m['wrb'] ?? m['rsg'] ?? '').toString();
          if (name.isEmpty) continue;
          final pct = m['percent'] ?? m['pct'] ?? m['share'] ?? m['percentage'] ?? m['area'] ?? m['areapct'];
          shares.add(SoilShare(
            percent: asNumber(pct) ?? 0,
            name: name,
            description: (m['description'] ?? m['desc'] ?? m['meaning'] ?? '').toString(),
          ));
          names.add(name);
        } else if (e != null) {
          names.add(e.toString());
        }
      }
    } else if (flat['mainsoils'] is String) {
      names.addAll((flat['mainsoils'] as String).split(',').map((e) => e.trim()));
    }

    // Percentages sent as fractions (0.43) -> 43
    if (shares.isNotEmpty && shares.every((s) => s.percent <= 1)) {
      final scaled = [
        for (final s in shares)
          SoilShare(percent: s.percent * 100, name: s.name, description: s.description),
      ];
      shares
        ..clear()
        ..addAll(scaled);
    }

    final nameValue = asText(pick(exact: ['governorate', 'region', 'name', 'gouvernorat']));

    return GovernorateSoilData(
      governorate: nameValue ?? fallbackName,
      salinity: salinity,
      ph: ph,
      organicCarbon: organic,
      nitrogen: nitrogen,
      mainSoils: names,
      soilShares: shares,
      areaKm2: area,
      saltyAreaPct: saltyArea,
      sodicAreaPct: sodicPct,
      lime: lime,
      waterStoredMm: water,
      salinityNote: onlyText(salinityNote),
      phNote: onlyText(phNote),
      limeNote: onlyText(limeNote),
    );
  }

  static String _norm(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
}