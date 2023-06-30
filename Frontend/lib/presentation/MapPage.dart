import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';

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
  GoogleMapController? mapController; //contrller for Google map
  PolylinePoints polylinePoints = PolylinePoints();

  String googleAPiKey = "AIzaSyCae89QI1f9Tf_lrvsyEcKwyO2bg8ot06g";

  Set<Marker> markers = Set(); //markers for google map
  Map<PolylineId, Polyline> polylines = {}; //polylines to show direction

  double distance = 0.0;

  List<LatLng> polylineCoordinates = []; // Set to store the route polyline

  @override
  void initState() {
    super.initState();
    _locationRef = FirebaseDatabase.instance.ref().child('location');
    _listenLocation();
    _loadMarkers();
    getDirections(); //fetch direction polylines from Google API
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  getDirections() async {
    List<LatLng> polylineCoordinates = [];
    List<Marker> markerList = markers.toList();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey,
      PointLatLng(
          markerList[0].position.latitude, markerList[0].position.longitude),
      PointLatLng(
          markerList[1].position.latitude, markerList[1].position.longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }

    //polulineCoordinates is the List of longitute and latidtude.
    double totalDistance = 0;
    for (var i = 0; i < polylineCoordinates.length - 1; i++) {
      totalDistance += calculateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude);
    }
    print(totalDistance);

    setState(() {
      distance = totalDistance;
    });

    //add to the list of poly line coordinates
    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.deepPurpleAccent,
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          "Map",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        backgroundColor: Theme.of(context).primaryColor,
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

          markers.add(
            Marker(
              markerId: MarkerId('dept1'),
              position: LatLng(latitude, longitude),
              infoWindow: InfoWindow(
                title: 'me',
                snippet: 'yo',
              ),
              // Optional: Set a custom icon for the marker
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueMagenta),
            ),
          );

          if (latitude == null || longitude == null) {
            return Center(child: Text('Location not found'));
          }

          return GoogleMap(
            zoomGesturesEnabled: true, //enable Zoom in, out on map
            initialCameraPosition: CameraPosition(
              //innital position in map
              target: LatLng(latitude, longitude), //initial position
              zoom: 14.0, //initial zoom level
            ),
            markers: markers, //markers to show on map
            polylines: Set<Polyline>.of(polylines.values), //polylines
            mapType: MapType.normal, //map type
            onMapCreated: (controller) {
              //method called when map is created
              setState(() {
                mapController = controller;
              });
              Positioned(
                  bottom: 200,
                  left: 50,
                  child: Container(
                      child: Card(
                    child: Container(
                        padding: EdgeInsets.all(20),
                        child: Text(
                            "Total Distance: " +
                                distance.toStringAsFixed(2) +
                                " KM",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold))),
                  )));
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
    markers.add(
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
    markers.add(
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
    setState(() {}); // Draw route between markers
  }
}
