import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapResultPage extends StatelessWidget {
  final double lat;
  final double lng;
  final String name;

  MapResultPage({required this.lat, required this.lng, required this.name});

  @override
  Widget build(BuildContext context) {
    CameraPosition initialPosition = CameraPosition(
      target: LatLng(lat, lng),
      zoom: 14,
    );

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: GoogleMap(
        initialCameraPosition: initialPosition,
        markers: {
          Marker(
            markerId: MarkerId("selected"),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: name),
          ),
        },
      ),
    );
  }
}
