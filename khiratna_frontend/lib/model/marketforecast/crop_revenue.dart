import 'market_product.dart';

class CropRevenue {
  final String id;
  final String name;
  final int revenuePerHa; // TND per hectare (sales, not profit)
  final double dinarsPerM3;
  final bool marketFull;
  final String yieldNote; // not empty = yield was corrected
  final PlantingStatus plantingStatus;

  const CropRevenue({
    this.id = '',
    required this.name,
    required this.revenuePerHa,
    required this.dinarsPerM3,
    required this.marketFull,
    this.yieldNote = '',
    this.plantingStatus = PlantingStatus.unknown,
  });

  /// Only products with revenue AND water data can be shown.
  static bool canBuild(MarketProduct p) =>
      p.revenueTndPerHa != null && p.tndPerM3Water != null;

  factory CropRevenue.fromProduct(MarketProduct p) {
    return CropRevenue(
      id: p.id,
      name: p.name,
      revenuePerHa: p.revenueTndPerHa!.round(),
      dinarsPerM3: p.tndPerM3Water!,
      marketFull: p.marketFull,
      yieldNote: p.yieldNote,
      plantingStatus: p.plantingStatus,
    );
  }
}

/// What the "crop revenue" screen needs from one /farm/market call.
class CropRevenueResult {
  final List<CropRevenue> plantNow; // open field or tree, best TND/m³ first
  final List<CropRevenue> greenhouseOnly;
  final List<String> notInSeason; // names
  final List<String> frostRisk; // names

  const CropRevenueResult({
    required this.plantNow,
    required this.greenhouseOnly,
    required this.notInSeason,
    required this.frostRisk,
  });
}