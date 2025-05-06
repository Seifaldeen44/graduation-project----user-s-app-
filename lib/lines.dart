import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'models/place_model.dart';
import 'utils/location_service.dart';

class Lines extends StatefulWidget {
  const Lines({super.key});

  @override
  _LinesState createState() => _LinesState();
}

class _LinesState extends State<Lines> {
  int _selectedIndex = 0;
  GoogleMapController? googleMapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  late LocationService locationService;
  late CameraPosition initialCameraPosition;
  bool isCameraMoving = false;
  bool shouldRecenter = false;
  BitmapDescriptor? vehicleIcon;
  String selectedLine = '';

  @override
  void initState() {
    super.initState();
    initialCameraPosition = const CameraPosition(
        zoom: 17, target: LatLng(31.187084851056554, 29.928110526889437));
    locationService = LocationService();
    _loadIcons();
    updateMyLocation();
  }

  @override
  void dispose() {
    googleMapController?.dispose();
    super.dispose();
  }

  Future<void> _loadIcons() async {
    vehicleIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)), 'images/car_icon.png');
  }

  Future<void> _loadMarkersFromFirestore(String line) async {
    FirebaseFirestore.instance
        .collection('tram_lines')
        .doc(line)
        .collection('stations')
        .orderBy('order')
        .snapshots()
        .listen((snapshot) {
      Set<Marker> stationMarkers = {};
      List<LatLng> lineCoordinates = [];

      for (var doc in snapshot.docs) {
        var data = doc.data();
        if (data.containsKey('location') && data['location'] is GeoPoint) {
          var location = data['location'] as GeoPoint;
          LatLng stationPosition = LatLng(location.latitude, location.longitude);
          lineCoordinates.add(stationPosition);

          stationMarkers.add(
            Marker(
              markerId: MarkerId('station_${doc.id}'),
              position: stationPosition,
              infoWindow: InfoWindow(title: data['name']),
              onTap: () {
                googleMapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(stationPosition, 17),
                );
              },
            ),
          );
        }
      }

      if (lineCoordinates.isNotEmpty) {
        final polyline = Polyline(
          polylineId: PolylineId(line),
          color: Colors.blue,
          width: 4,
          points: lineCoordinates,
        );

        setState(() {
          _markers.removeWhere((m) => m.markerId.value.startsWith('station_'));
          _markers.addAll(stationMarkers);
          _polylines.clear();
          _polylines.add(polyline);
        });
      }
    });
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, 'Phoneauth');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error signing out: $e")),
      );
    }
  }

  void updateMyLocation() async {
    try {
      await locationService.checkAndRequestLocationService();
      var hasPermission =
      await locationService.checkAndRequestLocationPermission();
      if (hasPermission) {
        locationService.getRealTimeLocationData((locationData) {
          if (locationData.latitude != null && locationData.longitude != null) {
            if (shouldRecenter && !isCameraMoving) {
              googleMapController?.animateCamera(
                CameraUpdate.newLatLng(
                    LatLng(locationData.latitude!, locationData.longitude!)),
              );
              shouldRecenter = false;
            }
          }
        });
      } else {
        print("Permission not granted");
      }
    } catch (e) {
      print("Error updating location: $e");
    }
  }

  void listenForVehicleUpdates(String line) {
    FirebaseFirestore.instance
        .collection('vehicles')
        .doc(line)
        .collection('vehicles')
        .snapshots()
        .listen((snapshot) {
      Set<Marker> vehicleMarkers = {};
      for (var doc in snapshot.docs) {
        var data = doc.data();
        if (data.containsKey('latitude') &&
            data.containsKey('longitude') &&
            data.containsKey('active') &&
            data['active'] == true) {
          vehicleMarkers.add(
            Marker(
              markerId: MarkerId('vehicle_${doc.id}'),
              position: LatLng(data['latitude'], data['longitude']),
              icon: vehicleIcon ??
                  BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              infoWindow: InfoWindow(title: "Vehicle ${doc.id}"),
              onTap: () {
                googleMapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(
                      LatLng(data['latitude'], data['longitude']), 17),
                );
              },
            ),
          );
        }
      }

      setState(() {
        _markers.removeWhere((m) => m.markerId.value.startsWith('vehicle_'));
        _markers.addAll(vehicleMarkers);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tramify Lines"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => signOut(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedLine = 'line1';
                        listenForVehicleUpdates(selectedLine);
                        _loadMarkersFromFirestore(selectedLine);
                      });
                    },
                    child: Text('Line 1'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedLine = 'line2';
                        listenForVehicleUpdates(selectedLine);
                        _loadMarkersFromFirestore(selectedLine);
                      });
                    },
                    child: Text('Line 2'),
                  ),
                ],
              ),
              Expanded(
                child: GoogleMap(
                  zoomControlsEnabled: false,
                  myLocationEnabled: true, // ✅ Show built-in blue dot
                  myLocationButtonEnabled: false,
                  onMapCreated: (controller) {
                    googleMapController = controller;
                  },
                  onCameraMove: (_) {
                    isCameraMoving = true;
                  },
                  onCameraIdle: () {
                    isCameraMoving = false;
                  },
                  initialCameraPosition: initialCameraPosition,
                  markers: _markers,
                  polylines: _polylines,
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 80,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                shouldRecenter = true;
                updateMyLocation();
              },
              child: Icon(Icons.gps_fixed),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (val) {
          setState(() {
            _selectedIndex = val;
          });
        },
        currentIndex: _selectedIndex,
        backgroundColor: Color.fromARGB(255, 145, 129, 216),
        selectedFontSize: 18,
        unselectedFontSize: 14,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        items: [
          BottomNavigationBarItem(
              icon: IconButton(
                icon: Icon(Icons.home),
                color: Colors.black,
                onPressed: () {
                  Navigator.pushReplacementNamed(context, 'Home');
                },
              ),
              label: "Home"),
          BottomNavigationBarItem(
              icon: IconButton(
                icon: Icon(Icons.directions_bus),
                color: Colors.white,
                onPressed: () {
                  Navigator.pushReplacementNamed(context, 'Lines');
                },
              ),
              label: "Lines"),
          BottomNavigationBarItem(
              icon: IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '');
                },
              ),
              label: "Settings")
        ],
      ),
    );
  }
}
