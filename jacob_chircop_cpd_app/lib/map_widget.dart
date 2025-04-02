import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapWidget extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double zoom;

  const MapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    this.zoom = 17.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(latitude, longitude),
          initialZoom: zoom,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.carfinderapp',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(latitude, longitude),
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
