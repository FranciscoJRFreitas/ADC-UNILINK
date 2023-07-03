import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:flutter/services.dart';
import '../../data/cache_factory_provider.dart';
import 'dart:math';

class MyMap extends StatefulWidget {
  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  final loc.Location location = loc.Location();
  late loc.LocationData currentLocation;
  GoogleMapController? mapController; //contrller for Google map
  var latitude;
  var longitude;
  var isDirections = false;
  bool isSattelite = true;
  bool isFirst = true;
  var center = LatLng(38.660999, -9.205094);

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

  String _mapStyle = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initializeAsync());
    rootBundle.loadString('assets/json/map_style.json').then((string) {
      _mapStyle = string;
    });

    _getLocation();

    _loadMarkersFromJson();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initializeAsync() async {
    bool isDarkTheme = await cacheFactory.get('settings', 'theme') == 'Dark';
    rootBundle
        .loadString(isDarkTheme
            ? 'assets/json/map_style_dark.json'
            : 'assets/json/map_style_.json')
        .then((string) {
      setState(() {
        _mapStyle = string;
      });
    });
  }

  getDirections(double? lat, double? long) async {
    print("$currentLocation.latitude" + " " + "$currentLocation.longitude");
    print(distance);
    if (lat != null && long != null && isDirections) {
      List<LatLng> polylineCoordinates = [];

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPiKey,
        PointLatLng(
          currentLocation.latitude ?? 0.0,
          currentLocation.longitude ?? 0.0,
        ),
        PointLatLng(lat, long),
        travelMode: distance >= 0.75 ? TravelMode.driving : TravelMode.walking,
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

  double calculateDistance(double? lat, double? long) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((center.latitude - lat!) * p) / 2 +
        cos(lat * p) *
            cos(center.latitude * p) *
            (1 - cos((center.longitude - long!) * p)) /
            2;
    return 12742 * asin(sqrt(a));
  }

  addPolyLine(
      double destLat, double destLong, List<LatLng> polylineCoordinates) async {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Color.fromARGB(255, 9, 19, 202),
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
    setState(() {});
    await Future.delayed(Duration(seconds: 2));
    getDirections(
        destLat, destLong); // Call getDirections when polyline is added
  }

  List<String> selectedDropdownItems = [];

  Set<Marker> markers = Set();

  void updateMarkers() {
    print(selectedDropdownItems);
    // Update the markers set based on the selectedDropdownItems
    markers.clear();

    if (selectedDropdownItems.contains("Buildings")) {
      markers.addAll(edMarkers);
    }
    if (selectedDropdownItems.contains('Restauration')) {
      markers.addAll(restMarkers);
    }
    if (selectedDropdownItems.contains('Parking')) {
      markers.addAll(parkMarkers);
    }
    if (selectedDropdownItems.contains('Gates')) {
      markers.addAll(portMarkers);
    }
    if (selectedDropdownItems.contains('Services')) {
      markers.addAll(servMarkers);
    }
    print(markers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (BuildContext context) {
          return Stack(
            children: [
              GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  controller.setMapStyle(_mapStyle);
                },
                zoomGesturesEnabled: true,
                initialCameraPosition: CameraPosition(
                  target: center,
                  zoom: 17.0,
                ),
                polygons: selectedDropdownItems.contains("Campus")
                    ? campusPolygon
                    : {},
                markers: markers,
                polylines: Set<Polyline>.of(polylines.values),
                mapType: isSattelite ? MapType.satellite : MapType.normal,
              ),
              Positioned(
                top: 10.0,
                left: 10.0,
                child: Container(
                  alignment: Alignment.topRight,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            builder: (BuildContext context, setState) {
                              return AlertDialog(
                                title: Text('Select Options'),
                                backgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                content: MultiSelectDropdownDialog(
                                  dropdownItems: dropdownItems,
                                  selectedItems: selectedDropdownItems,
                                  onChanged: (List<String> newSelectedItems) {
                                    setState(() {
                                      selectedDropdownItems = newSelectedItems;
                                    });
                                    updateMarkers();
                                  },
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Done'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                    child: Text('Open Dropdown'),
                  ),
                ),
              ),
              Positioned(
                top: 10.0,
                right: 10.0,
                child: Switch(
                  value: isSattelite,
                  onChanged: (value) {
                    setState(() {
                      isSattelite = value;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: Duration(milliseconds: 750),
                        content: Text(
                          isSattelite
                              ? 'Switched to Satellite mode'
                              : 'Switched to Normal mode',
                        ),
                      ),
                    );
                  },
                  activeTrackColor:
                      Theme.of(context).primaryColor.withOpacity(0.5),
                  activeColor: Theme.of(context).primaryColor,
                ),
              ),
              Positioned(
                bottom: 20.0,
                right: 20.0,
                child: Visibility(
                  visible: isDirections,
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
        if (mounted) {
          // Location permission not granted, handle accordingly
          return;
        }
      }
    }

    // Start listening for location updates
    location.onLocationChanged.listen((loc.LocationData _locationResult) {
      if (mounted) {
        setState(() {
          currentLocation = _locationResult;
          if (isFirst) {
            isFirst = false;
            distance = calculateDistance(
                currentLocation.latitude, currentLocation.longitude);
          }
        });
      }
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
          //icon: BitmapDescriptor.fromAssetImage(configuration, assetName),
          //onTap: getDirections(),
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

class MultiSelectDropdownDialog extends StatefulWidget {
  final List<String> dropdownItems;
  final List<String> selectedItems;
  final ValueChanged<List<String>> onChanged;

  MultiSelectDropdownDialog({
    required this.dropdownItems,
    required this.selectedItems,
    required this.onChanged,
  });

  @override
  _MultiSelectDropdownDialogState createState() =>
      _MultiSelectDropdownDialogState();
}

class _MultiSelectDropdownDialogState extends State<MultiSelectDropdownDialog> {
  List<String> selectedItems = [];

  @override
  void initState() {
    selectedItems.addAll(widget.selectedItems);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: widget.dropdownItems.map((String item) {
          return CheckboxListTile(
            title: Text(item),
            value: selectedItems.contains(item),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  selectedItems.add(item);
                  print(item);
                } else {
                  selectedItems.remove(item);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    widget.onChanged(selectedItems);
    super.dispose();
  }
}
