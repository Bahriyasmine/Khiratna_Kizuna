double? _n(dynamic v) => v == null ? null : (v as num).toDouble();

enum PlantingStatus {
  openField,
  tree,
  greenhouse,
  notInSeason,
  frostRisk,
  noData,
  unknown;

  static PlantingStatus parse(String? s) {
    switch (s) {
      case 'open_field':
        return PlantingStatus.openField;
      case 'tree':
        return PlantingStatus.tree;
      case 'protected':
        return PlantingStatus.greenhouse;
      case 'not_in_season':
        return PlantingStatus.notInSeason;
      case 'frost_risk':
        return PlantingStatus.frostRisk;
      case 'no_data':
        return PlantingStatus.noData;
      default:
        return PlantingStatus.unknown;
    }
  }

  String get label {
    switch (this) {
      case PlantingStatus.openField:
        return 'Open field';
      case PlantingStatus.tree:
        return 'Orchard / tree';
      case PlantingStatus.greenhouse:
        return 'Greenhouse only';
      case PlantingStatus.notInSeason:
        return 'Not in season';
      case PlantingStatus.frostRisk:
        return 'Frost risk';
      case PlantingStatus.noData:
        return 'No calendar data';
      case PlantingStatus.unknown:
        return 'Unknown';
    }
  }
}

class MarketProduct {
  final String id;
  final String name;
  final double? production2024T;
  final double? consumption2024T;
  final double? selfSufficiency2024;
  final double? selfSufficiency2027;
  final double missing2024T;
  final double missing2027T;
  final double? exports2024T;
  final double? farmPriceTndPerT;
  final int? priceYear;
  final double? priceChangePercentPerYear;
  final double? yieldTPerHa;
  final double? revenueTndPerHa;
  final double? importPriceUsdPerT;
  final double? waterM3PerHa;
  final double? tndPerM3Water;
  final bool tunisiaLacksIt;
  final bool marketFull;
  final String yieldNote;
  final PlantingStatus plantingStatus;

  const MarketProduct({
    required this.id,
    required this.name,
    this.production2024T,
    this.consumption2024T,
    this.selfSufficiency2024,
    this.selfSufficiency2027,
    required this.missing2024T,
    required this.missing2027T,
    this.exports2024T,
    this.farmPriceTndPerT,
    this.priceYear,
    this.priceChangePercentPerYear,
    this.yieldTPerHa,
    this.revenueTndPerHa,
    this.importPriceUsdPerT,
    this.waterM3PerHa,
    this.tndPerM3Water,
    required this.tunisiaLacksIt,
    required this.marketFull,
    required this.yieldNote,
    required this.plantingStatus,
  });

  factory MarketProduct.fromJson(Map<String, dynamic> j) {
    return MarketProduct(
      id: j['product'] as String,
      name: j['name'] as String,
      production2024T: _n(j['production_2024_t']),
      consumption2024T: _n(j['consumption_2024_t']),
      selfSufficiency2024: _n(j['self_sufficiency_2024']),
      selfSufficiency2027: _n(j['self_sufficiency_2027']),
      missing2024T: _n(j['missing_2024_t']) ?? 0,
      missing2027T: _n(j['missing_2027_t']) ?? 0,
      exports2024T: _n(j['exports_2024_t']),
      farmPriceTndPerT: _n(j['farm_price_tnd_per_t']),
      priceYear: (j['price_year'] as num?)?.toInt(),
      priceChangePercentPerYear: _n(j['price_change_percent_per_year']),
      yieldTPerHa: _n(j['yield_t_per_ha']),
      revenueTndPerHa: _n(j['revenue_tnd_per_ha']),
      importPriceUsdPerT: _n(j['import_price_usd_per_t']),
      waterM3PerHa: _n(j['water_m3_per_ha']),
      tndPerM3Water: _n(j['tnd_per_m3_water']),
      tunisiaLacksIt: j['tunisia_lacks_it'] == true,
      marketFull: j['market_full'] == true,
      yieldNote: (j['yield_note'] ?? '').toString(),
      plantingStatus: PlantingStatus.parse(j['planting_status'] as String?),
    );
  }
}

class MarketOverview {
  final String region;
  final int plantingMonth;
  final List<MarketProduct> lacks;
  final List<MarketProduct> earns;
  final List<MarketProduct> perWater;
  final List<MarketProduct> protectedOnly;
  final List<String> notInSeason; // product ids
  final List<String> frostRisk; // product ids
  final List<MarketProduct> products;

  const MarketOverview({
    required this.region,
    required this.plantingMonth,
    required this.lacks,
    required this.earns,
    required this.perWater,
    required this.protectedOnly,
    required this.notInSeason,
    required this.frostRisk,
    required this.products,
  });

  static List<MarketProduct> _list(dynamic v) => (v as List? ?? [])
      .map((e) => MarketProduct.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();

  static List<String> _ids(dynamic v) =>
      (v as List? ?? []).map((e) => e.toString()).toList();

  /// Product id -> display name, from the full product list.
  String nameOf(String id) {
    for (final p in products) {
      if (p.id == id) return p.name;
    }
    return id;
  }

  factory MarketOverview.fromJson(Map<String, dynamic> j) {
    return MarketOverview(
      region: j['region'] as String,
      plantingMonth: (j['planting_month'] as num).toInt(),
      lacks: _list(j['lacks']),
      earns: _list(j['earns']),
      perWater: _list(j['per_water']),
      protectedOnly: _list(j['protected_only']),
      notInSeason: _ids(j['not_in_season']),
      frostRisk: _ids(j['frost_risk']),
      products: _list(j['products']),
    );
  }
}