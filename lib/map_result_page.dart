import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';

class MapResultPage extends StatefulWidget {
  final double lat;
  final double lng;
  final String name;

  const MapResultPage({
    super.key,
    required this.lat,
    required this.lng,
    required this.name,
  });

  @override
  State<MapResultPage> createState() => _MapResultPageState();
}

class _MapResultPageState extends State<MapResultPage> {
  GoogleMapController? _controller;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng? _userLocation;
  LatLng? _nearestStation;
  String _nearestStationName = '';
  double? _nearestDistance;
  LatLng? _destinationLocation;
  String? _lineContainingUserStation;
  String? _lineContainingDestStation;

  @override
  void initState() {
    super.initState();
    _initMap();
  }

  Future<void> _initMap() async {
    _destinationLocation = LatLng(widget.lat, widget.lng);
    await _getUserLocation();
    await _loadStationsAndFindRoute();
  }

  Future<void> _getUserLocation() async {
    Location location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) serviceEnabled = await location.requestService();
    if (!serviceEnabled) return;

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    final locData = await location.getLocation();

    setState(() {
      _userLocation = LatLng(locData.latitude!, locData.longitude!);
      _markers.add(Marker(
        markerId: const MarkerId('user_location'),
        position: _userLocation!,
        infoWindow: const InfoWindow(title: 'Your Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
    });
  }

  Future<void> _loadStationsAndFindRoute() async {
    // Get all stations from both lines, ordered by their sequence
    final line1Stations = await FirebaseFirestore.instance
        .collection('tram_lines')
        .doc('line1')
        .collection('stations')
        .orderBy('order')
        .get();

    final line2Stations = await FirebaseFirestore.instance
        .collection('tram_lines')
        .doc('line2')
        .collection('stations')
        .orderBy('order')
        .get();

    // Convert to LatLng with additional info
    final line1 = line1Stations.docs.map((doc) {
      final geo = doc['location'] as GeoPoint;
      return {
        'latLng': LatLng(geo.latitude, geo.longitude),
        'name': doc['name'],
        'line': 'line1',
        'order': doc['order'],
      };
    }).toList();

    final line2 = line2Stations.docs.map((doc) {
      final geo = doc['location'] as GeoPoint;
      return {
        'latLng': LatLng(geo.latitude, geo.longitude),
        'name': doc['name'],
        'line': 'line2',
        'order': doc['order'],
      };
    }).toList();

    // Find nearest station to user
    final userNearest = _findNearestStation([...line1, ...line2], _userLocation!);

    // Find nearest station to destination
    final destNearest = _findNearestStation([...line1, ...line2], _destinationLocation!);

    if (userNearest != null && destNearest != null) {
      // Add markers
      _addStationMarkers(userNearest, destNearest);

      // Draw the route between them
      if (userNearest['line'] == destNearest['line']) {
        // Same line - draw the segment between them
        await _drawRouteOnSameLine(
            userNearest,
            destNearest,
            userNearest['line'] == 'line1' ? line1 : line2
        );
      } else {
        // Different lines - find intersection station and draw both segments
        await _drawRouteAcrossLines(userNearest, destNearest, line1, line2);
      }
    }
  }

  Map<String, dynamic>? _findNearestStation(List<Map<String, dynamic>> stations, LatLng point) {
    if (stations.isEmpty) return null;

    Map<String, dynamic>? nearest;
    double minDistance = double.infinity;

    for (final station in stations) {
      final distance = Geolocator.distanceBetween(
        point.latitude,
        point.longitude,
        station['latLng'].latitude,
        station['latLng'].longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearest = station;
      }
    }

    return nearest;
  }

  void _addStationMarkers(Map<String, dynamic> userNearest, Map<String, dynamic> destNearest) {
    setState(() {
      _nearestStation = userNearest['latLng'];
      _nearestStationName = userNearest['name'];
      _nearestDistance = Geolocator.distanceBetween(
        _userLocation!.latitude,
        _userLocation!.longitude,
        userNearest['latLng'].latitude,
        userNearest['latLng'].longitude,
      );

      // User's nearest station (green)
      _markers.add(Marker(
        markerId: MarkerId('user_station_${userNearest['name']}'),
        position: userNearest['latLng'],
        infoWindow: InfoWindow(
          title: 'Nearest Station: ${userNearest['name']}',
          snippet: 'Distance: ${_nearestDistance!.toStringAsFixed(1)} m',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));

      // Destination's nearest station (red)
      _markers.add(Marker(
        markerId: MarkerId('dest_station_${destNearest['name']}'),
        position: destNearest['latLng'],
        infoWindow: InfoWindow(title: 'Destination Station: ${destNearest['name']}'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));

      // Destination marker
      _markers.add(Marker(
        markerId: const MarkerId('destination'),
        position: _destinationLocation!,
        infoWindow: InfoWindow(title: widget.name),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ));
    });
  }

  Future<void> _drawRouteOnSameLine(
      Map<String, dynamic> startStation,
      Map<String, dynamic> endStation,
      List<Map<String, dynamic>> lineStations,
      ) async {
    final points = <LatLng>[];
    final startOrder = startStation['order'];
    final endOrder = endStation['order'];

    if (startOrder < endOrder) {
      // Forward direction
      for (final station in lineStations) {
        if (station['order'] >= startOrder && station['order'] <= endOrder) {
          points.add(station['latLng']);
        }
      }
    } else {
      // Reverse direction
      for (final station in lineStations.reversed) {
        if (station['order'] <= startOrder && station['order'] >= endOrder) {
          points.add(station['latLng']);
        }
      }
    }

    setState(() {
      _polylines.add(Polyline(
        polylineId: PolylineId('tram_route_${startStation['line']}'),
        color: Colors.blue,
        width: 5,
        points: points,
      ));
    });
  }

  Future<void> _drawRouteAcrossLines(
      Map<String, dynamic> startStation,
      Map<String, dynamic> endStation,
      List<Map<String, dynamic>> line1,
      List<Map<String, dynamic>> line2,
      ) async {
    // Find intersection station (assuming there's one common station between lines)
    final intersection = _findIntersectionStation(line1, line2);
    if (intersection == null) return;

    // Draw route from start station to intersection
    await _drawRouteOnSameLine(
      startStation,
      intersection,
      startStation['line'] == 'line1' ? line1 : line2,
    );

    // Draw route from intersection to end station
    await _drawRouteOnSameLine(
      intersection,
      endStation,
      endStation['line'] == 'line1' ? line1 : line2,
    );
  }

  Map<String, dynamic>? _findIntersectionStation(
      List<Map<String, dynamic>> line1,
      List<Map<String, dynamic>> line2,
      ) {
    for (final station1 in line1) {
      for (final station2 in line2) {
        if (station1['name'] == station2['name']) {
          return station1; // Return either one, they represent the same station
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    LatLng initialPos = _destinationLocation ?? LatLng(widget.lat, widget.lng);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              if (_nearestStation != null) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Route Information'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nearest station: $_nearestStationName'),
                        if (_nearestDistance != null)
                          Text('Distance to station: ${_nearestDistance!.toStringAsFixed(1)} m'),
                        Text('Destination: ${widget.name}'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        child: const Text('Close'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: initialPos, zoom: 14),
        onMapCreated: (controller) => _controller = controller,
        markers: _markers,
        polylines: _polylines,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}