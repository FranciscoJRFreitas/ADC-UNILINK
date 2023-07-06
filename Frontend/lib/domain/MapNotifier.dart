import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapNotifier extends ChangeNotifier {
  bool _isSatellite = false;

  // Add the marker sets here
  Set<Marker> _edMarkers = Set();
  Set<Marker> _restMarkers = Set();
  Set<Marker> _parkMarkers = Set();
  Set<Marker> _portMarkers = Set();
  Set<Marker> _servMarkers = Set();

  // Keep track of the selected items
  List<String> selectedDropdownItems = [];

  bool get isSatellite => _isSatellite;
  Set<Marker> get edMarkers => _edMarkers;
  Set<Marker> get restMarkers => _restMarkers;
  Set<Marker> get parkMarkers => _parkMarkers;
  Set<Marker> get portMarkers => _portMarkers;
  Set<Marker> get servMarkers => _servMarkers;

  void toggleSatellite() {
    _isSatellite = !_isSatellite;
    notifyListeners();
  }

  void updateEdMarkers(Set<Marker> newMarkers) {
    _edMarkers = newMarkers;
    notifyListeners();
  }

  void updateRestMarkers(Set<Marker> newMarkers) {
    _restMarkers = newMarkers;
    notifyListeners();
  }

  void updateParkMarkers(Set<Marker> newMarkers) {
    _parkMarkers = newMarkers;
    notifyListeners();
  }

  void updatePortMarkers(Set<Marker> newMarkers) {
    _portMarkers = newMarkers;
    notifyListeners();
  }

  void updateServMarkers(Set<Marker> newMarkers) {
    _servMarkers = newMarkers;
    notifyListeners();
  }

  Set<Marker> getMarkers() {
    Set<Marker> markers = Set();

    if (selectedDropdownItems.contains("Buildings")) {
      markers.addAll(_edMarkers);
    }
    if (selectedDropdownItems.contains('Restauration')) {
      markers.addAll(_restMarkers);
    }
    if (selectedDropdownItems.contains('Parking')) {
      markers.addAll(_parkMarkers);
    }
    if (selectedDropdownItems.contains('Gates')) {
      markers.addAll(_portMarkers);
    }
    if (selectedDropdownItems.contains('Services')) {
      markers.addAll(_servMarkers);
    }

    return markers;
  }

  void updateSelectedItems(List<String> newSelectedItems) {
    selectedDropdownItems = newSelectedItems;
    notifyListeners();
  }
}
