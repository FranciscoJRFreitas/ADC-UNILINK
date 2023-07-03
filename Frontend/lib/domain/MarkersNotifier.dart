import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkersNotifier with ChangeNotifier {
  Set<Marker> _markers = {};

  Set<Marker> get markers => _markers;

  void updateMarkers(Set<Marker> newMarkers) {
    _markers = newMarkers;
    notifyListeners();
  }
}
