import 'package:dio/dio.dart';
import 'package:khiratna_frontend/core/network/api_client.dart';
import 'package:khiratna_frontend/model/water_forecast.dart';

class WaterService {
  final Options _long = Options(receiveTimeout: const Duration(seconds: 60));

  Future<RainfallOptions> getOptions() async {
    final res = await ApiClient.dio.get('/farm/rainfall/options');
    return RainfallOptions.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<WaterForecast> getForecast({
    required String region,
    required String crop, // crop id, not display name
    required String start, // YYYY-MM
    required String end, // YYYY-MM
  }) async {
    final res = await ApiClient.dio.get(
      '/farm/water',
      queryParameters: {'region': region, 'crop': crop, 'start': start, 'end': end},
      options: _long,
    );
    return WaterForecast.fromJson(Map<String, dynamic>.from(res.data as Map));
  }
}