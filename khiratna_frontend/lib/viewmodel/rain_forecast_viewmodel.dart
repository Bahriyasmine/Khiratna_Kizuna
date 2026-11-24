import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khiratna_frontend/model/water_forecast.dart';
import '../../services/water_service.dart';

class RainForecastViewModel extends ChangeNotifier {
  final _service = WaterService();

  RainfallOptions? options;
  bool optionsLoading = false;
  String? optionsError;

  String? region;
  String? cropId;
  DateTime start = DateTime(2026, 2);
  DateTime end = DateTime(2026, 6);

  WaterForecast? forecast;
  bool loading = false;
  String? error;

  static String _ym(DateTime d) => DateFormat('yyyy-MM').format(d);

  String get cropName {
    final c = options?.crops.where((c) => c.id == cropId);
    return (c == null || c.isEmpty) ? (cropId ?? '') : c.first.name;
  }

  DateTime _clamp(DateTime d) {
    final o = options;
    if (o == null) return d;
    if (d.isBefore(o.firstDate)) return o.firstDate;
    if (d.isAfter(o.lastDate)) return DateTime(o.lastDate.year, o.lastDate.month);
    return d;
  }

  String _message(Object e, String fallback) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        final m = data['message'];
        return m is List ? m.join('\n') : m.toString();
      }
      return 'Could not reach the server.';
    }
    return fallback;
  }

  Future<void> loadOptions() async {
    optionsLoading = true;
    optionsError = null;
    notifyListeners();
    try {
      final o = await _service.getOptions();
      options = o;
      region = o.regions.contains('Kasserine')
          ? 'Kasserine'
          : (o.regions.isNotEmpty ? o.regions.first : null);
      cropId = o.crops.isNotEmpty ? o.crops.first.id : null;
      start = _clamp(start);
      end = _clamp(end);
    } catch (e) {
      optionsError = _message(e, 'Could not load regions and crops.');
    } finally {
      optionsLoading = false;
      notifyListeners();
    }
  }

  void setRegion(String v) {
    region = v;
    notifyListeners();
  }

  void setCrop(String v) {
    cropId = v;
    notifyListeners();
  }

  void setStart(DateTime d) {
    start = DateTime(d.year, d.month);
    if (end.isBefore(start)) end = start;
    notifyListeners();
  }

  void setEnd(DateTime d) {
    end = DateTime(d.year, d.month);
    if (end.isBefore(start)) start = end;
    notifyListeners();
  }

  Future<void> generate() async {
    if (region == null || cropId == null) {
      error = 'Please choose a region and a crop.';
      notifyListeners();
      return;
    }
    loading = true;
    error = null;
    notifyListeners();
    try {
      forecast = await _service.getForecast(
        region: region!,
        crop: cropId!,
        start: _ym(start),
        end: _ym(end),
      );
    } catch (e) {
      error = _message(e, 'Unexpected error. Please try again.');
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}