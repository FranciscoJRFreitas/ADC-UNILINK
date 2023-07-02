import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';
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
  late loc.LocationData currentLocation;
  late DatabaseReference _locationRef =
      FirebaseDatabase.instance.ref().child('location');
  GoogleMapController? mapController; //contrller for Google map
  var latitude;
  var longitude;
  var isDirections = false;

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

    _getLocation();

    _loadMarkersFromJson();
  }

  getDirections(double? lat, double? long) async {
    print("$currentLocation.latitude" + " " + "$currentLocation.longitude");
    if (lat != null && long != null && isDirections) {
      List<LatLng> polylineCoordinates = [];

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPiKey,
        PointLatLng(
          currentLocation.latitude ?? 0.0,
          currentLocation.longitude ?? 0.0,
        ),
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

      if (isDirections) {
        addPolyLine(lat, long, polylineCoordinates);
      } else
        setState(() {
          polylines = {}; // Clear polylines to stop showing directions
        });
    } else
      setState(() {
        polylines = {}; // Clear polylines to stop showing directions
      });
  }

  addPolyLine(
      double destLat, double destLong, List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Color.fromARGB(255, 9, 19, 202),
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
    setState(() {});
    getDirections(
        destLat, destLong); // Call getDirections when polyline is added
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: _locationRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          Widget dropdownWidget = Container(
            alignment: Alignment.topRight,
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
                mapType: MapType.satellite,
              ),
              Positioned(
                top: 10.0,
                left: 10.0,
                child: dropdownWidget,
              ),
              if (isDirections)
                Positioned(
                  bottom: 20.0,
                  right: 20.0,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isDirections = false;
                        polylines =
                            {}; // Clear polylines to stop showing directions
                      });
                    },
                    child: Text('Stop giving directions'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  _getLocation() async {
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    // Check if location services are enabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        // Location services are disabled, handle accordingly
        return;
      }
    }

    // Check if location permission is granted
    permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        // Location permission not granted, handle accordingly
        return;
      }
    }

    // Start listening for location updates
    location.onLocationChanged.listen((loc.LocationData _locationResult) {
      setState(() {
        currentLocation = _locationResult;
      });
    });
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
          infoWindow: InfoWindow(
            title: name,
            snippet: feature['properties']['description'] ?? '',
            onTap: () async {
              if (isDirections) {
                setState(() {
                  isDirections = false;
                });
                await Future.delayed(Duration(seconds: 1));
              }
              isDirections = true;
              getDirections(latLng.latitude, latLng.longitude);
            },
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
            onTap: () async {
              if (isDirections) {
                setState(() {
                  isDirections = false;
                });
                await Future.delayed(Duration(seconds: 1));
              }
              isDirections = true;
              getDirections(latLng.latitude, latLng.longitude);
            },
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
            onTap: () async {
              if (isDirections) {
                setState(() {
                  isDirections = false;
                });
                await Future.delayed(Duration(seconds: 1));
              }
              isDirections = true;
              getDirections(latLng.latitude, latLng.longitude);
            },
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
            onTap: () async {
              if (isDirections) {
                setState(() {
                  isDirections = false;
                });
                await Future.delayed(Duration(seconds: 1));
              }
              isDirections = true;
              getDirections(latLng.latitude, latLng.longitude);
            },
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
            onTap: () async {
              if (isDirections) {
                setState(() {
                  isDirections = false;
                });
                await Future.delayed(Duration(seconds: 1));
              }
              isDirections = true;
              getDirections(latLng.latitude, latLng.longitude);
            },
          ),
        ),
      );
    }

    setState(() {});
  }
}
