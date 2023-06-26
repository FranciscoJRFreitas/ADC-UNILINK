import 'package:flutter/material.dart';
import '../domain/LocationData.dart';
import '../widgets/map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  final Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  int _highlightedIndex = 0;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    setState(() {
      markers[MarkerId('marker_1')] = Marker(
          markerId: MarkerId('marker_1'),
          position: LatLng(38.6609951, -9.2084419));
      markers[MarkerId('marker_2')] = Marker(
          markerId: MarkerId('marker_2'),
          position: LatLng(38.661005, -9.204426));
      // Add more markers here
    });
  }

  void _highlightMarker(int index) {
    MarkerId markerId = MarkerId(
        'marker_${index + 1}'); // Adjust this line to match your marker naming convention

    setState(() {
      Marker? oldMarker = markers[markerId];

      markers[markerId] = oldMarker!.copyWith(
        iconParam: BitmapDescriptor.defaultMarkerWithHue(
          index == _highlightedIndex
              ? BitmapDescriptor.hueRed
              : BitmapDescriptor.hueBlue, // Change the colors as per your need
        ),
      );

      _highlightedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: markers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                      'Location ${index + 1}'), // Adjust this line to match your requirement
                  onTap: () => _highlightMarker(index),
                );
              },
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              markers: Set<Marker>.of(markers.values),
              initialCameraPosition: CameraPosition(
                target: const LatLng(38.6609951, -9.2084419),
                zoom: 11.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
