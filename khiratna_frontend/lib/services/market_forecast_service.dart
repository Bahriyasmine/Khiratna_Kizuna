import 'package:dio/dio.dart';
import 'package:khiratna_frontend/core/network/api_client.dart';
import 'package:khiratna_frontend/model/marketforecast/crop_revenue.dart';
import 'package:khiratna_frontend/model/marketforecast/market_backtest.dart';
import 'package:khiratna_frontend/model/marketforecast/market_product.dart';
import 'package:khiratna_frontend/model/marketforecast/product_forecast.dart';
import 'package:khiratna_frontend/model/marketforecast/product_series.dart';

class MarketForecastService {
  static const governorates = [
    'Ariana', 'Beja', 'Ben Arous', 'Bizerte', 'Gabes', 'Gafsa', 'Jendouba',
    'Kairouan', 'Kasserine', 'Kebili', 'Kef', 'Mahdia', 'Manouba', 'Medenine',
    'Monastir', 'Nabeul', 'Sfax', 'Sidi Bouzid', 'Siliana', 'Sousse',
    'Tataouine', 'Tozeur', 'Tunis', 'Zaghouan',
  ];

  static const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  final Options _long = Options(receiveTimeout: const Duration(seconds: 60));

  /// Readable message from a failed request (backend 400s carry a message).
  static String errorText(Object e, String fallback) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        final m = data['message'];
        return m is List ? m.join('\n') : m.toString();
      }
    }
    return fallback;
  }

  Future<MarketOverview> _overview(String region, int month) async {
    final res = await ApiClient.dio.get(
      '/farm/market',
      queryParameters: {'region': region, 'month': month},
      options: _long,
    );
    return MarketOverview.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  // ───────── Service 1: what Tunisia will lack ─────────

  // The "lacks" list is national. The endpoint still needs a region and a
  // month, so any valid pair works.
  Future<List<ProductForecast>> getLackForecast() async {
    final o = await _overview('Tunis', DateTime.now().month);
    return o.lacks.map(ProductForecast.fromProduct).toList();
  }

  /// [productId] is the API id (e.g. "tomato"), not the display name.
  Future<ProductSeries> getProductSeries(String productId) async {
    final res = await ApiClient.dio.get(
      '/farm/market/history',
      queryParameters: {'product': productId},
    );
    return ProductSeries.fromHistory(
      Map<String, dynamic>.from(res.data as Map),
    );
  }

  Future<MarketBacktest> getBacktest() async {
    final res = await ApiClient.dio.get('/farm/market/backtest');
    return MarketBacktest.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  // ───────── Service 2: revenue per crop ─────────

  Future<CropRevenueResult> getCropRevenue({
    required String governorate,
    required String month, // month name, converted to 1..12 here
  }) async {
    final m = months.indexOf(month) + 1;
    if (m < 1) throw ArgumentError('Unknown month: $month');

    final o = await _overview(governorate, m);

    List<CropRevenue> build(List<MarketProduct> list) => list
        .where(CropRevenue.canBuild)
        .map(CropRevenue.fromProduct)
        .toList();

    return CropRevenueResult(
      plantNow: build(o.perWater),
      greenhouseOnly: build(o.protectedOnly),
      notInSeason: o.notInSeason.map(o.nameOf).toList(),
      frostRisk: o.frostRisk.map(o.nameOf).toList(),
    );
  }
}