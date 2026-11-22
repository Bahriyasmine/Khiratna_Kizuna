import 'package:latlong2/latlong.dart';

class GovernorateBorder {
  final String name;
  final List<List<LatLng>> rings; // outer ring of each polygon

  const GovernorateBorder({required this.name, required this.rings});

  bool contains(LatLng p) => rings.any((r) => _inside(p, r));

  // Ray casting point-in-polygon
  static bool _inside(LatLng p, List<LatLng> ring) {
    var inside = false;
    for (var i = 0, j = ring.length - 1; i < ring.length; j = i++) {
      final a = ring[i], b = ring[j];
      final crosses = (a.latitude > p.latitude) != (b.latitude > p.latitude) &&
          p.longitude <
              (b.longitude - a.longitude) *
                      (p.latitude - a.latitude) /
                      (b.latitude - a.latitude) +
                  a.longitude;
      if (crosses) inside = !inside;
    }
    return inside;
  }

  static const _nameKeys = [
    'name', 'NAME', 'NAME_1', 'name_1', 'governorate', 'Governorate',
    'gouvernorat', 'region', 'shapeName', 'ADM1_EN', 'nom',
  ];

  static List<GovernorateBorder> listFromGeoJson(dynamic json) {
    // Accept the FeatureCollection directly, or wrapped in another object
    if (json is Map && json['features'] is! List) {
      for (final v in json.values) {
        if (v is Map && v['features'] is List) {
          json = v;
          break;
        }
      }
    }
    if (json is! Map || json['features'] is! List) return [];

    final result = <GovernorateBorder>[];

    for (final f in json['features'] as List) {
      if (f is! Map) continue;
      final geometry = f['geometry'];
      if (geometry is! Map) continue;

      final props = f['properties'] is Map ? f['properties'] as Map : {};
      String name = 'Unknown';
      for (final k in _nameKeys) {
        final v = props[k];
        if (v is String && v.isNotEmpty) {
          name = v;
          break;
        }
      }

      final rings = <List<LatLng>>[];
      final type = geometry['type'];
      final coords = geometry['coordinates'];

      if (type == 'Polygon' && coords is List && coords.isNotEmpty) {
        rings.add(_ring(coords[0]));
      } else if (type == 'MultiPolygon' && coords is List) {
        for (final poly in coords) {
          if (poly is List && poly.isNotEmpty) rings.add(_ring(poly[0]));
        }
      }

      if (rings.isNotEmpty) {
        result.add(GovernorateBorder(name: name, rings: rings));
      }
    }
    return result;
  }

  // GeoJSON order is [longitude, latitude]
  static List<LatLng> _ring(dynamic coords) => [
        for (final c in coords as List)
          LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()),
      ];
}