class ProductSeries {
  final String product;
  final List<int> years;
  final List<double> consumption;
  final List<double> production;
  final int lastRealYear;

  const ProductSeries({
    required this.product,
    required this.years,
    required this.consumption,
    required this.production,
    required this.lastRealYear,
  });

  int get lastRealIndex {
    final i = years.indexOf(lastRealYear);
    return i < 0 ? years.length - 1 : i;
  }

  /// Builds from GET /farm/market/history -> { product, years: [MarketYear] }
  factory ProductSeries.fromHistory(Map<String, dynamic> json) {
    final rows = (json['years'] as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList()
      ..sort((a, b) => (a['year'] as num).compareTo(b['year'] as num));

    final years = rows.map((r) => (r['year'] as num).toInt()).toList();

    var lastReal = years.isEmpty ? 0 : years.last;
    for (final r in rows) {
      if (r['source'] == 'observed') lastReal = (r['year'] as num).toInt();
    }

    return ProductSeries(
      product: rows.isNotEmpty
          ? (rows.first['name'] ?? json['product']).toString()
          : json['product'].toString(),
      years: years,
      consumption: rows
          .map((r) => (r['consumption'] as num?)?.toDouble() ?? 0)
          .toList(),
      production: rows
          .map((r) => (r['production'] as num?)?.toDouble() ?? 0)
          .toList(),
      lastRealYear: lastReal,
    );
  }
}