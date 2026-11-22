class BacktestError {
  final double modelErrorPercent;
  final double naiveErrorPercent;

  const BacktestError({
    required this.modelErrorPercent,
    required this.naiveErrorPercent,
  });

  factory BacktestError.fromJson(Map<String, dynamic> j) => BacktestError(
        modelErrorPercent: (j['model_error_percent'] as num).toDouble(),
        naiveErrorPercent: (j['naive_error_percent'] as num).toDouble(),
      );
}

class MarketBacktest {
  final BacktestError production;
  final BacktestError consumption;

  const MarketBacktest({required this.production, required this.consumption});

  factory MarketBacktest.fromJson(Map<String, dynamic> j) {
    final m = Map<String, dynamic>.from(j['median_error_percent'] as Map);
    return MarketBacktest(
      production: BacktestError.fromJson(
          Map<String, dynamic>.from(m['production'] as Map)),
      consumption: BacktestError.fromJson(
          Map<String, dynamic>.from(m['consumption'] as Map)),
    );
  }
}