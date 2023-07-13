import 'package:google_maps_flutter/google_maps_flutter.dart';

LatLng parseCoordinates(String coordinates) {
  // Parse the coordinates string and return a LatLng object
  // This is just a placeholder, replace it with your actual logic
  double latitude = 0.0;
  double longitude = 0.0;
  // Split the coordinates string and convert to double values
  List<String> coords = coordinates.split(",");
  if (coords.length == 2) {
    latitude = double.tryParse(coords[0]) ?? 0.0;
    longitude = double.tryParse(coords[1]) ?? 0.0;
  }
  return LatLng(latitude, longitude);
}