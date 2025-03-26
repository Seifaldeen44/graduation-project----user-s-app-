import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceModel {
  final int id;
  final String name;
  final LatLng latlong;

  PlaceModel({required this.id, required this.name, required this.latlong});
}

List<PlaceModel> places = [
  // PlaceModel(
  //     id: 1,
  //     name: "city square",
  //     latlong: LatLng(31.228049555645384, 29.942389378603192)),
  // PlaceModel(
  //     id: 1,
  //     name: "Golden jewel",
  //     latlong: LatLng(31.22923303819117, 29.941938767593744)),
  // PlaceModel(
  //     id: 1,
  //     name: "Fath allah",
  //     latlong: LatLng(31.228549555892034, 29.9434354400594))
];
