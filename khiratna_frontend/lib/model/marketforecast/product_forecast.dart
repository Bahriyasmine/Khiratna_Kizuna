import 'market_product.dart';

class ProductForecast {
  final String id; // used to load the history chart
  final String name;
  final int sufficiency2024;
  final int sufficiency2027;
  final int missingTonnes; // forecast missing tonnes for 2027

  const ProductForecast({
    this.id = '',
    required this.name,
    required this.sufficiency2024,
    required this.sufficiency2027,
    required this.missingTonnes,
  });

  bool get isWorsening => sufficiency2027 < sufficiency2024;

  factory ProductForecast.fromProduct(MarketProduct p) {
    return ProductForecast(
      id: p.id,
      name: p.name,
      sufficiency2024: (p.selfSufficiency2024 ?? 0).round(),
      sufficiency2027: (p.selfSufficiency2027 ?? 0).round(),
      missingTonnes: p.missing2027T.round(),
    );
  }
}