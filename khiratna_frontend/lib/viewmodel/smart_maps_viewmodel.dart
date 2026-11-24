import 'package:flutter/foundation.dart';
import 'package:khiratna_frontend/model/smart_maps/governorate_border.dart';
import 'package:khiratna_frontend/model/smart_maps/governorate_map_data.dart';
import 'package:khiratna_frontend/model/smart_maps/soil_option.dart';
import 'package:khiratna_frontend/services/soil_map_service.dart';
import 'package:latlong2/latlong.dart';

class SmartMapsViewModel extends ChangeNotifier {
  final SoilMapService _service = SoilMapService();

  // Fallback used until (or unless) /soil/options answers
  static const _defaultParameters = [
    SoilOption('Soil Salinity', 'Soil Salinity'),
    SoilOption('Soil Sodicity', 'Soil Sodicity'),
    SoilOption('Soil pH', 'Soil pH'),
  ];

  String selectedParameter = 'Soil Salinity';
  String selectedGovernorate = 'Zaghouan';

  double? clickedLat;
  double? clickedLng;

  List<SoilOption> parameters = _defaultParameters;
  List<String> governorates = [];

  List<GovernorateBorder> borders = [];
  bool isLoadingBorders = true;

  GovernorateSoilData? regionData;
  bool isLoadingRegion = false;
  String? errorMessage;

  bool _disposed = false;

  SmartMapsViewModel() {
    _init();
  }

  Future<void> _init() async {
    await Future.wait([
      _loadBorders(),
      _loadOptions(),
      loadRegion(selectedGovernorate),
    ]);
    _probeMap();
  }

  // ───────── Options ─────────

  Future<void> _loadOptions() async {
    try {
      final data = await _service.getOptions();
      debugPrint('SOIL OPTIONS: $data');

      final parsed = _parseOptions(data);

      if (parsed.parameters.isNotEmpty) {
        parameters = parsed.parameters;
        if (!parameters.any((p) => p.value == selectedParameter)) {
          selectedParameter = parameters.first.value;
        }
      }
      if (parsed.governorates.isNotEmpty) {
        governorates = parsed.governorates;
      }

      debugPrint('PARSED parameters: '
          '${parameters.map((p) => p.label).join(', ')}');
      debugPrint('PARSED governorates: ${governorates.length}');
    } catch (e) {
      debugPrint('Soil options error: $e');
    } finally {
      notifyListeners();
    }
  }

  ({List<SoilOption> parameters, List<String> governorates}) _parseOptions(
    dynamic data,
  ) {
    var params = <SoilOption>[];
    var govs = <String>[];

    if (data is Map) {
      data.forEach((key, value) {
        if (value is! List) return;
        final k = key.toString().toLowerCase();
        final isParam = k.contains('param') ||
            k.contains('layer') ||
            k.contains('variable') ||
            k.contains('indicator') ||
            k.contains('propert');
        final isGov =
            k.contains('gov') || k.contains('region') || k.contains('gouv');

        if (isParam) {
          params = _toOptions(value);
        } else if (isGov) {
          govs = _toOptions(value).map((o) => o.label).toList();
        }
      });
    }

    return (parameters: params, governorates: govs);
  }

  List<SoilOption> _toOptions(List list) {
    final result = <SoilOption>[];
    for (final e in list) {
      String? label;
      if (e is String) {
        label = e;
      } else if (e is Map) {
        final v = e['label'] ?? e['name'] ?? e['title'] ?? e['id'];
        label = v?.toString();
      }
      if (label != null && label.isNotEmpty) {
        result.add(SoilOption(label, label));
      }
    }
    return result;
  }

  // ───────── Borders ─────────

  Future<void> _loadBorders() async {
    try {
      final data = await _service.getBorders();
      borders = GovernorateBorder.listFromGeoJson(data);
      debugPrint('SOIL BORDERS: ${borders.length} governorates -> '
          '${borders.map((b) => b.name).join(', ')}');
    } catch (e) {
      debugPrint('Soil borders error: $e');
      errorMessage = 'Could not load the map borders.';
    } finally {
      isLoadingBorders = false;
      notifyListeners();
    }
  }

  // ───────── Region stats ─────────

  Future<void> loadRegion(String name) async {
    isLoadingRegion = true;
    notifyListeners();

    try {
      final json = await _service.getRegion(name);
      // ignore the answer if the user already picked another governorate
      if (name != selectedGovernorate) return;
      regionData = GovernorateSoilData.fromJson(json, fallbackName: name);
      debugPrint('SOIL REGION ($name): $json');
    } catch (e) {
      debugPrint('Soil region error: $e');
      if (name == selectedGovernorate) regionData = null;
    } finally {
      if (name == selectedGovernorate) isLoadingRegion = false;
      notifyListeners();
    }
  }

  // ───────── User actions ─────────

  void setParameter(String value) {
    selectedParameter = value;
    notifyListeners();
  }

  Future<void> setGovernorate(String name) {
    selectedGovernorate = name;
    notifyListeners();
    return loadRegion(name);
  }

  Future<void> onMapClick(double lat, double lng) async {
    clickedLat = lat;
    clickedLng = lng;

    final point = LatLng(lat, lng);
    for (final b in borders) {
      if (b.contains(point)) {
        await setGovernorate(b.name);
        return;
      }
    }
    notifyListeners();
  }

  // TEMPORARY: prints the shape of /soil/map so we can colour the map next
  Future<void> _probeMap() async {
    try {
      final map = await _service.getMap();
      final text = map.toString();
      debugPrint('SOIL MAP type: ${map.runtimeType}');
      if (map is Map) debugPrint('SOIL MAP keys: ${map.keys.toList()}');
      debugPrint('SOIL MAP start: '
          '${text.substring(0, text.length > 600 ? 600 : text.length)}');
    } catch (e) {
      debugPrint('Soil map error: $e');
    }
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}