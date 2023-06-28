import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyMap extends StatefulWidget {
  final String userId;

  MyMap(this.userId);

  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  final loc.Location location = loc.Location();
  late GoogleMapController _controller;
  late DatabaseReference _locationRef;
  bool _added = false;
  final List<Marker> _markers = []; // List to store department markers

  List<LatLng> polylineCoordinates = []; // Set to store the route polyline

  @override
  void initState() {
    super.initState();
    _locationRef = FirebaseDatabase.instance.ref().child('location');
    _listenLocation();
    _loadMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text("Map"),
        backgroundColor: Color.fromARGB(255, 8, 52, 88),
      ),
      body: StreamBuilder(
        stream: _locationRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (_added) {
            myMap(snapshot);
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;

          final latitude = data?[widget.userId]?['latitude'];
          final longitude = data?[widget.userId]?['longitude'];

          if (latitude == null || longitude == null) {
            return Center(child: Text('Location not found'));
          }

          return GoogleMap(
            mapType: MapType.normal,
            markers: Set<Marker>.of([..._markers]),
            polylines: {
              Polyline(
                polylineId: PolylineId("route"),
                points: polylineCoordinates,
                width: 6,
              )
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(latitude, longitude),
              zoom: 14.47,
            ),
            onMapCreated: (GoogleMapController controller) async {
              setState(() {
                _controller = controller;
                _added = true;
              });
            },
          );
        },
      ),
    );
  }

  Future<void> myMap(AsyncSnapshot<DatabaseEvent> snapshot) async {
    final data = snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;

    final latitude = data?[widget.userId]?['latitude'];
    final longitude = data?[widget.userId]?['longitude'];

    if (latitude != null && longitude != null) {
      await _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(latitude, longitude), zoom: 14.47),
        ),
      );
    }
  }

  void _listenLocation() {
    _locationRef.onChildAdded.listen(
      (event) {
        print('Location Event: $event');
      },
      onError: (error) {
        print('Location Error: $error');
      },
    );
  }

  void _loadMarkers() {
    // Add markers for FCT NOVA departments
    _markers.add(
      Marker(
        markerId: MarkerId('dept1'),
        position: LatLng(38.660181, -9.202550),
        infoWindow: InfoWindow(
          title: 'Department 1',
          snippet: 'Description of Department 1',
        ),
        // Optional: Set a custom icon for the marker
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      ),
    );
    _markers.add(
      Marker(
        markerId: MarkerId('dept2'),
        position: LatLng(38.661052, -9.202260),
        infoWindow: InfoWindow(
          title: 'Department 2',
          snippet: 'Description of Department 2',
        ),
        // Optional: Set a custom icon for the marker
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      ),
    );

    // Set the state to update the map with the new markers
    setState(() {});
    getPolyPoints();
    // Draw route between markers
  }

  void getPolyPoints() async {
    PolylinePoints points = PolylinePoints();
    PolylineResult result = await points.getRouteBetweenCoordinates(
        "YAIzaSyCae89QI1f9Tf_lrvsyEcKwyO2bg8ot06g",
        PointLatLng(
            _markers[0].position.latitude, _markers[0].position.longitude),
        PointLatLng(
            _markers[1].position.latitude, _markers[1].position.longitude));
    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) =>
            polylineCoordinates.add(LatLng(point.latitude, point.longitude)),
      );
      setState(() {});
    }
  }
}
