import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:khiratna_frontend/viewmodel/smart_maps_viewmodel.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class SoilMapWidget extends StatefulWidget {
  final String selectedGovernorate;
  final void Function(double latitude, double longitude) onMapClick;

  const SoilMapWidget({
    super.key,
    required this.selectedGovernorate,
    required this.onMapClick,
  });

  @override
  State<SoilMapWidget> createState() => _SoilMapWidgetState();
}

class _SoilMapWidgetState extends State<SoilMapWidget> {
  final MapController _mapController = MapController();

  static const Map<String, LatLng> governorateLocations = {
    'Tunis': LatLng(36.8065, 10.1815),
    'Ariana': LatLng(36.8665, 10.1647),
    'Ben Arous': LatLng(36.7531, 10.2189),
    'Manouba': LatLng(36.8081, 10.0963),
    'Nabeul': LatLng(36.4561, 10.7376),
    'Zaghouan': LatLng(36.4029, 10.1429),
    'Bizerte': LatLng(37.2746, 9.8739),
    'Beja': LatLng(36.7256, 9.1817),
    'Jendouba': LatLng(36.5011, 8.7802),
    'Kef': LatLng(36.1742, 8.7049),
    'Siliana': LatLng(36.0849, 9.3708),
    'Sousse': LatLng(35.8256, 10.6084),
    'Monastir': LatLng(35.7643, 10.8113),
    'Mahdia': LatLng(35.5047, 11.0622),
    'Kairouan': LatLng(35.6781, 10.0963),
    'Kasserine': LatLng(35.1676, 8.8365),
    'Sidi Bouzid': LatLng(35.0382, 9.4849),
    'Sfax': LatLng(34.7406, 10.7603),
    'Gabes': LatLng(33.8815, 10.0982),
    'Medenine': LatLng(33.3549, 10.5055),
    'Tataouine': LatLng(32.9297, 10.4518),
    'Gafsa': LatLng(34.4311, 8.7757),
    'Tozeur': LatLng(33.9197, 8.1335),
    'Kebili': LatLng(33.7044, 8.9690),
  };

  String _norm(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');

  @override
  void didUpdateWidget(covariant SoilMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedGovernorate != widget.selectedGovernorate) {
      _zoomToSelectedGovernorate();
    }
  }

  void _zoomToSelectedGovernorate() {
    final location = governorateLocations[widget.selectedGovernorate];
    if (location == null) return;
    _mapController.move(location, 10.5);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SmartMapsViewModel>();
    final selectedLocation = governorateLocations[widget.selectedGovernorate];
    const green = Color(0xFF2E7D32);

    final polygons = <Polygon>[
      for (final b in vm.borders)
        for (final ring in b.rings)
          Polygon(
            points: ring,
            color: _norm(b.name) == _norm(widget.selectedGovernorate)
                ? green.withValues(alpha: 0.35)
                : null,
            borderColor: green.withValues(alpha: 0.6),
            borderStrokeWidth: 1.2,
          ),
    ];

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        height: 500,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: selectedLocation ?? const LatLng(34.0, 9.0),
                initialZoom: selectedLocation == null ? 6.5 : 10.5,
                minZoom: 5,
                maxZoom: 18,
                onTap: (tapPosition, point) {
                  widget.onMapClick(point.latitude, point.longitude);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.khiratna.khiratna_frontend',
                ),
                if (polygons.isNotEmpty) PolygonLayer(polygons: polygons),
                if (selectedLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: selectedLocation,
                        width: 48,
                        height: 48,
                        child: const Icon(
                          Icons.location_on,
                          size: 46,
                          color: green,
                        ),
                      ),
                    ],
                  ),
                RichAttributionWidget(
                  attributions: const [
                    TextSourceAttribution('OpenStreetMap contributors'),
                  ],
                ),
              ],
            ),
            if (vm.isLoadingBorders)
              const Positioned(
                top: 12,
                right: 12,
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}