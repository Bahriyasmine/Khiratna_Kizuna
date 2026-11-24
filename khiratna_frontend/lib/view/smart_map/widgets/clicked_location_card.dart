import 'package:flutter/material.dart';

class ClickedLocationCard extends StatelessWidget {
  final double? latitude;
  final double? longitude;

  const ClickedLocationCard({
    super.key,
    this.latitude,
    this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: latitude == null
            ? const Text(
                'Click on the map to inspect a location',
              )
            : Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Clicked Location',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Latitude: ${latitude!.toStringAsFixed(4)}',
                  ),

                  Text(
                    'Longitude: ${longitude!.toStringAsFixed(4)}',
                  ),
                ],
              ),
      ),
    );
  }
}