import 'package:dio/dio.dart';
import 'package:khiratna_frontend/core/network/api_client.dart';

class SoilMapService {
  // Borders and map are big payloads, so allow more time
  final Options _long = Options(receiveTimeout: const Duration(seconds: 60));

  Future<dynamic> getOptions() async {
    final res = await ApiClient.dio.get('/farm/soil/options');
    return res.data;
  }

  Future<dynamic> getBorders() async {
    final res = await ApiClient.dio.get('/farm/soil/borders', options: _long);
    return res.data;
  }

  Future<dynamic> getMap() async {
    final res = await ApiClient.dio.get('/farm/soil/map', options: _long);
    return res.data;
  }

  Future<Map<String, dynamic>> getRegion(String name) async {
    final res = await ApiClient.dio.get(
      '/farm/soil/region',
      queryParameters: {'name': name},
    );
    return Map<String, dynamic>.from(res.data as Map);
  }
}