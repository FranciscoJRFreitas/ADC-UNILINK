import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class MyMap extends StatefulWidget {
  final String userId;

  MyMap({required this.userId});

  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  final loc.Location location = loc.Location();
  late GoogleMapController _controller;
  late DatabaseReference _locationRef =
      FirebaseDatabase.instance.ref().child('location');
  GoogleMapController? mapController; //contrller for Google map
  StreamSubscription<DatabaseEvent>? _locationSubscription;
  List<DataSnapshot> _locationSnapshots = [];
  var latitude;
  var longitude;

  PolylinePoints polylinePoints = PolylinePoints();

  String googleAPiKey = "AIzaSyCae89QI1f9Tf_lrvsyEcKwyO2bg8ot06g";

  Set<Polygon> campusPolygon = Set();
  Set<Marker> edMarkers = Set();
  Set<Marker> restMarkers = Set();
  Set<Marker> parkMarkers = Set();
  Set<Marker> portMarkers = Set();
  Set<Marker> servMarkers = Set();
  Map<PolylineId, Polyline> polylines = {}; //polylines to show direction

  double distance = 0.0;

  List<String> dropdownItems = [
    'Campus',
    'Buildings',
    'Restauration',
    'Parking',
    'Gates',
    'Services'
  ];
  String selectedDropdownItem = 'Campus';

  String _mapStyle = '';

  @override
  void initState() {
    super.initState();
    _loadMarkersFromJson();
    rootBundle.loadString('assets/json/map_style.json').then((string) {
      _mapStyle = string;
    });
    if (widget.userId == "") {
      _requestPermission();
      _getLocation();
      _listenerLocation();
      _listenLocation();
    }
  }

  getDirections(double lat, double long) async {
    List<LatLng> polylineCoordinates = [];
    //List<Marker> markerList = markers.toList();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey,
      PointLatLng(latitude, longitude),
      PointLatLng(lat, long),
      travelMode: TravelMode.walking,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }

    //add to the list of poly line coordinates
    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Color.fromARGB(255, 9, 19, 202),
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: _locationRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: CircularProgressIndicator());
          }
          if (widget.userId != "") {
            final data =
                snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;

            latitude = data?[widget.userId]?['latitude'];
            longitude = data?[widget.userId]?['longitude'];

            if (latitude == null || longitude == null) {
              return Center(child: Text('Location not found'));
            }
          }
          // Build the dropdown widget
          Widget dropdownWidget = Container(
            alignment: Alignment.bottomCenter,
            child: DropdownButton<String>(
              value: selectedDropdownItem,
              dropdownColor: Colors.transparent,
              items: dropdownItems.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedDropdownItem = newValue!;
                });
              },
            ),
          );

          // This is where we'll add the dropdown
          return Stack(
            children: <Widget>[
              GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  controller.setMapStyle(_mapStyle);
                },
                zoomGesturesEnabled: true,
                initialCameraPosition: CameraPosition(
                  target: LatLng(38.660999, -9.205094),
                  zoom: 17.0,
                ),
                polygons: selectedDropdownItem == "Campus" ? campusPolygon : {},
                markers: selectedDropdownItem == "Buildings"
                    ? edMarkers
                    : selectedDropdownItem == "Restauration"
                        ? restMarkers
                        : selectedDropdownItem == "Parking"
                            ? parkMarkers
                            : selectedDropdownItem == "Gates"
                                ? portMarkers
                                : selectedDropdownItem == "Services"
                                    ? servMarkers
                                    : Set(),
                polylines: Set<Polyline>.of(polylines.values),
                mapType: MapType.normal,
                /*onMapCreated: (controller) {
                  setState(() {
                    mapController = controller;
                  });
                },*/
              ),
              Positioned(
                top: 10.0,
                left: 10.0,
                child: dropdownWidget,
              ),
            ],
          );
        },
      ),
    );
  }

  _getLocation() async {
    try {
      final loc.LocationData _locationResult = await location.getLocation();
      final DatabaseReference locationRef =
          FirebaseDatabase.instance.ref("location").child(widget.userId);
      locationRef.child("latitude").set(_locationResult.latitude);
      locationRef.child("longitude").set(_locationResult.longitude);
    } catch (e) {
      print(e);
    }
  }

  void _listenerLocation() {
    _locationSubscription ??= _locationRef.onChildAdded.listen(
      (DatabaseEvent event) {
        if (event.snapshot.value != null) {
          setState(() {
            // Assuming _locationSnapshots is a List<DatabaseReference>
            _locationSnapshots.add(event.snapshot);
          });
        }
      },
    );
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

  Future<void> _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print('Permission granted');
    } else if (status.isDenied) {
      _requestPermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  void _loadMarkersFromJson() async {
    String campusJson =
        await rootBundle.loadString('assets/json/map/Campus_de_Caparica.json');
    String buildingsJson =
        await rootBundle.loadString('assets/json/map/Edificios.json');
    String eatingSpacesJson =
        await rootBundle.loadString('assets/json/map/Espacos_de_refeicao.json');
    String parkingLotsJson = await rootBundle
        .loadString('assets/json/map/Parques_de_estacionamento.json');
    String gatesJson =
        await rootBundle.loadString('assets/json/map/Portarias.json');
    String servicesJson =
        await rootBundle.loadString('assets/json/map/Servicos.json');

    List<dynamic> campusData = jsonDecode(campusJson)['features'];
    List<dynamic> buildingsData = jsonDecode(buildingsJson)['features'];
    List<dynamic> eatingSpacesData = jsonDecode(eatingSpacesJson)['features'];
    List<dynamic> parkingLotsData = jsonDecode(parkingLotsJson)['features'];
    List<dynamic> gatesData = jsonDecode(gatesJson)['features'];
    List<dynamic> servicesData = jsonDecode(servicesJson)['features'];


    List<LatLng> polygonPoints = [];
    for (var coordinates in campusData[0]['geometry']['coordinates'][0]) {
      double latitude = coordinates[1];
      double longitude = coordinates[0];
      polygonPoints.add(LatLng(latitude, longitude));
    }

    Polygon polygon = Polygon(
      polygonId: PolygonId('campus_polygon'),
      points: polygonPoints,
      strokeColor: Colors.blue,
      fillColor: Colors.blue.withOpacity(0.2),
      strokeWidth: 2,
    );

    campusPolygon.add(polygon);

    for (var feature in buildingsData) {
      String name = feature['properties']['Name'];
      List<dynamic> coordinates = feature['geometry']['coordinates'];
      LatLng latLng = LatLng(coordinates[1], coordinates[0]);

      edMarkers.add(
        Marker(
          markerId: MarkerId(name),
          position: latLng,
          //icon: BitmapDescriptor.fromAssetImage(configuration, assetName),
          //onTap: getDirections(),
          infoWindow: InfoWindow(
            title: name,
            snippet: feature['properties']['description'] ?? '',
          ),
        ),
      );
    }

    for (var feature in eatingSpacesData) {
      String name = feature['properties']['Name'];
      List<dynamic> coordinates = feature['geometry']['coordinates'];
      LatLng latLng = LatLng(coordinates[1], coordinates[0]);

      restMarkers.add(
        Marker(
          markerId: MarkerId(name),
          position: latLng,
          infoWindow: InfoWindow(
            title: name,
          ),
        ),
      );
    }

    for (var feature in parkingLotsData) {
      String name = feature['properties']['Name'];
      List<dynamic> coordinates = feature['geometry']['coordinates'];
      LatLng latLng = LatLng(coordinates[1], coordinates[0]);

      parkMarkers.add(
        Marker(
          markerId: MarkerId(name),
          position: latLng,
          infoWindow: InfoWindow(
            title: name,
          ),
        ),
      );
    }

    for (var feature in gatesData) {
      String name = feature['properties']['Name'];
      List<dynamic> coordinates = feature['geometry']['coordinates'];
      LatLng latLng = LatLng(coordinates[1], coordinates[0]);

      portMarkers.add(
        Marker(
          markerId: MarkerId(name),
          position: latLng,
          infoWindow: InfoWindow(
            title: name,
          ),
        ),
      );
    }

    for (var feature in servicesData) {
      String name = feature['properties']['Name'];
      List<dynamic> coordinates = feature['geometry']['coordinates'];
      LatLng latLng = LatLng(coordinates[1], coordinates[0]);

      servMarkers.add(
        Marker(
          markerId: MarkerId(name),
          position: latLng,
          infoWindow: InfoWindow(
            title: name,
          ),
        ),
      );
    }

    setState(() {});
  }
}
