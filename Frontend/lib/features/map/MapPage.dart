import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:flutter/services.dart';
import '../../data/cache_factory_provider.dart';
import 'dart:math';
import 'dart:ui' as ui;
import '../../../constants.dart';

class MyMap extends StatefulWidget {
  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  final loc.Location location = loc.Location();
  late loc.LocationData currentLocation;

  GoogleMapController? mapController;
  var latitude;
  var longitude;
  var isDirections = false;
  bool isSattelite = true;
  bool isFirst = true;
  var center = LatLng(38.660999, -9.205094);
  var cameraposition;
  var isLocked = false;
  var zoom = 17.0;
  var tilt = 30.0;

  PolylinePoints polylinePoints = PolylinePoints();

  String googleAPiKey = "AIzaSyCae89QI1f9Tf_lrvsyEcKwyO2bg8ot06g";

  Set<Polygon> campusPolygon = Set();
  Set<Marker> edMarkers = Set();
  Set<Marker> restMarkers = Set();
  Set<Marker> parkMarkers = Set();
  Set<Marker> portMarkers = Set();
  Set<Marker> servMarkers = Set();
  Map<PolylineId, Polyline> polylines = {};

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
    cameraposition = center;
    WidgetsBinding.instance.addPostFrameCallback((_) => initializeAsync());
    rootBundle.loadString('assets/json/map_style.json').then((string) {
      _mapStyle = string;
    });

    _getLocation();
    loadMarkersFromJson();
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

  void updateCurrentPositionMarker(loc.LocationData newLocation) async {
    final Uint8List gates = isDirections
        ? await getImages('assets/icon/movingLocation.png', 100)
        : await getImages('assets/icon/currentLocation.png', 100);
    setState(() {
      markers.removeWhere(
          (m) => m.markerId.value == 'currentPos'); // Remove the old marker

      // Add the updated marker
      markers.add(
        Marker(
          markerId: MarkerId('currentPos'),
          icon: BitmapDescriptor.fromBytes(gates),
          position:
              LatLng(newLocation.latitude ?? 0.0, newLocation.longitude ?? 0.0),
          infoWindow: InfoWindow(title: 'My Location'),
        ),
      );
    });
  }

  getDirections(double? lat, double? long) async {
    //print("$currentLocation.latitude" + " " + "$currentLocation.longitude");
    //print(distance);

    if (mapController != null && isLocked) {
      mapController!
          .moveCamera(CameraUpdate.newLatLngZoom(cameraposition, zoom));
    }
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
      cameraposition =
          LatLng(currentLocation.latitude ?? 0, currentLocation.longitude ?? 0);

      if (result.points.isNotEmpty) {
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      } else {
        print(result.errorMessage);
      }

      if (mapController != null && isLocked) {
        if (result.points.isNotEmpty && polylineCoordinates.length > 1) {
          var bearing =
              calculateBearing(polylineCoordinates[0], polylineCoordinates[1]);
          mapController!.moveCamera(CameraUpdate.newCameraPosition(
              CameraPosition(
                  target: cameraposition,
                  zoom: zoom,
                  bearing: bearing,
                  tilt: tilt)));
        } else {
          mapController!
              .moveCamera(CameraUpdate.newLatLngZoom(cameraposition, zoom));
        }
      }

      if (isDirections) {
        loc.LocationData locationData = loc.LocationData.fromMap({
          'latitude': polylineCoordinates.first.latitude,
          'longitude': polylineCoordinates.first.longitude,
        });
        updateCurrentPositionMarker(locationData);
        addPolyLine(lat, long, polylineCoordinates);
      } else
        setState(() {
          polylines = {};
        });
    } else
      setState(() {
        polylines = {};
      });
  }

  double calculateBearing(LatLng start, LatLng end) {
    double startLat = degreesToRadians(start.latitude);
    double startLong = degreesToRadians(start.longitude);
    double endLat = degreesToRadians(end.latitude);
    double endLong = degreesToRadians(end.longitude);

    double dLong = endLong - startLong;

    double dPhi =
        log(tan(endLat / 2.0 + pi / 4.0) / tan(startLat / 2.0 + pi / 4.0));

    if (dLong.abs() > pi) {
      if (dLong > 0.0) {
        dLong = -(2.0 * pi - dLong);
      } else {
        dLong = (2.0 * pi + dLong);
      }
    }

    return (radiansToDegrees(atan2(dLong, dPhi)) + 360.0) % 360.0;
  }

  double degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  double radiansToDegrees(double radians) {
    return radians * 180.0 / pi;
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
      color: Colors.lightBlue,
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
    setState(() {});
    await Future.delayed(Duration(seconds: 10)); //alterar os tempos
    getDirections(destLat, destLong);
  }

  List<String> selectedDropdownItems = [];

  Set<Marker> markers = Set();

  void updateMarkers() {
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
                  mapController =
                      controller; // Store the GoogleMapController instance
                },
                zoomGesturesEnabled: true,
                initialCameraPosition: CameraPosition(
                  target: cameraposition,
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
                    onPressed: () => showOptionsDialog2(context),
                    child: Text('Map Options'),
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
                          style: DefaultTextStyle.of(context)
                              .style
                              .copyWith(color: Colors.white),
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
                        polylines = {};
                      });
                    },
                    child: Text('Stop giving directions'),
                  ),
                ),
              ),
              Positioned(
                bottom:
                    60.0, // Adjust the offset to position the buttons as desired
                right: 20.0,
                child: Visibility(
                  visible: isDirections,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (!isLocked) {
                          isLocked = true;
                          zoom = 19.5;
                          tilt = 30.0;
                        } else {
                          isLocked = false;
                          zoom = 17.0;
                          tilt = 0.0;
                        }
                        polylines = {};
                      });
                    },
                    child: Text(isLocked ? "Unlock Camera" : "Lock Camera"),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  showOptionsDialog2(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Stack(
              children: [
                ModalBarrier(
                  dismissible: false,
                  color: Colors.transparent,
                ),
                AlertDialog(
                  title: Text('Select Options'),
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (!selectedDropdownItems.contains('Campus')) {
                              selectedDropdownItems.add('Campus');
                            } else {
                              selectedDropdownItems.remove('Campus');
                            }
                          });
                          print(selectedDropdownItems);
                          updateMarkers();
                        },
                        child: Row(
                          children: [
                            Icon(Icons.school,
                                color: selectedDropdownItems.contains('Campus')
                                    ? Colors.blue
                                    : Colors.grey),
                            SizedBox(width: 8.0),
                            Text(
                              'Campus',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                      color: selectedDropdownItems
                                              .contains('Campus')
                                          ? Colors.blue
                                          : Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.0),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (!selectedDropdownItems.contains('Buildings')) {
                              selectedDropdownItems.add('Buildings');
                            } else {
                              selectedDropdownItems.remove('Buildings');
                            }
                          });
                          print(selectedDropdownItems);
                          updateMarkers();
                        },
                        child: Row(
                          children: [
                            Icon(Icons.location_city,
                                color:
                                    selectedDropdownItems.contains('Buildings')
                                        ? Colors.blue
                                        : Colors.grey),
                            SizedBox(width: 8.0),
                            Text(
                              'Buildings',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                      color: selectedDropdownItems
                                              .contains('Buildings')
                                          ? Colors.blue
                                          : Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.0),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (!selectedDropdownItems
                                .contains('Restauration')) {
                              selectedDropdownItems.add('Restauration');
                            } else {
                              selectedDropdownItems.remove('Restauration');
                            }
                          });
                          print(selectedDropdownItems);
                          updateMarkers();
                        },
                        child: Row(
                          children: [
                            Icon(Icons.restaurant,
                                color: selectedDropdownItems
                                        .contains('Restauration')
                                    ? Colors.blue
                                    : Colors.grey),
                            SizedBox(width: 8.0),
                            Text(
                              'Restauration',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                      color: selectedDropdownItems
                                              .contains('Restauration')
                                          ? Colors.blue
                                          : Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.0),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (!selectedDropdownItems.contains('Parking')) {
                              selectedDropdownItems.add('Parking');
                            } else {
                              selectedDropdownItems.remove('Parking');
                            }
                          });
                          print(selectedDropdownItems);
                          updateMarkers();
                        },
                        child: Row(
                          children: [
                            Icon(Icons.local_parking,
                                color: selectedDropdownItems.contains('Parking')
                                    ? Colors.blue
                                    : Colors.grey),
                            SizedBox(width: 8.0),
                            Text(
                              'Parking',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                      color: selectedDropdownItems
                                              .contains('Parking')
                                          ? Colors.blue
                                          : Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.0),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (!selectedDropdownItems.contains('Gates')) {
                              selectedDropdownItems.add('Gates');
                            } else {
                              selectedDropdownItems.remove('Gates');
                            }
                          });
                          print(selectedDropdownItems);
                          updateMarkers();
                        },
                        child: Row(
                          children: [
                            Icon(Icons.sensor_door_outlined,
                                color: selectedDropdownItems.contains('Gates')
                                    ? Colors.blue
                                    : Colors.grey),
                            SizedBox(width: 8.0),
                            Text(
                              'Gates',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                      color: selectedDropdownItems
                                              .contains('Gates')
                                          ? Colors.blue
                                          : Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.0),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (!selectedDropdownItems.contains('Services')) {
                              selectedDropdownItems.add('Services');
                            } else {
                              selectedDropdownItems.remove('Services');
                            }
                          });
                          print(selectedDropdownItems);
                          updateMarkers();
                        },
                        child: Row(
                          children: [
                            Icon(Icons.support_agent,
                                color:
                                    selectedDropdownItems.contains('Services')
                                        ? Colors.blue
                                        : Colors.grey),
                            SizedBox(width: 8.0),
                            Text(
                              'Services',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                      color: selectedDropdownItems
                                              .contains('Services')
                                          ? Colors.blue
                                          : Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Done'),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showMarkerInfoWindow(MarkerId markerId, String name, String desc) {
    final Marker tappedMarker =
        markers.firstWhere((marker) => marker.markerId == markerId);
    final String title = name;
    final String snippet = desc;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title!),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(snippet!),
              if (!kIsWeb)
                ElevatedButton(
                  onPressed: () async {
                    if (isDirections) {
                      setState(() {
                        isDirections = false;
                      });
                      await Future.delayed(Duration(seconds: 1));
                    }
                    isDirections = true;
                    getDirections(tappedMarker.position.latitude,
                        tappedMarker.position.longitude);
                    Navigator.of(context).pop();
                  },
                  child: Text('Get Directions'),
                ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  void showMarkerInfoWindowMobile(MarkerId markerId, String name, String desc) {
    final Marker tappedMarker =
        markers.firstWhere((marker) => marker.markerId == markerId);
    final String title = name;
    final String snippet = desc;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Style.darkBlue,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: IconButton(
                  icon: Icon(Icons.minimize),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        title!,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  if (!kIsWeb)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (isDirections) {
                              setState(() {
                                isDirections = false;
                              });
                              await Future.delayed(Duration(seconds: 1));
                            }
                            isDirections = true;
                            getDirections(tappedMarker.position.latitude,
                                tappedMarker.position.longitude);
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.directions_walk, color: Colors.blue),
                          label: Text('Get Directions',
                              style: TextStyle(color: Colors.blue)),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white, // Background color
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(20), // Border radius
                            ),
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 18),
                  Padding(
                    padding: EdgeInsets.only(
                      left: snippet.length > 10 ? 8.0 : 2.0,
                    ),
                    child: Text(snippet!,
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void showMarkerInfoWindowMobile2(
      MarkerId markerId, String name, String desc) {
    final Marker tappedMarker =
        markers.firstWhere((marker) => marker.markerId == markerId);
    final String title = name;
    final String snippet = desc;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Style.darkBlue,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.3,
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Stack(
            children: [
              Positioned(
                child: IconButton(
                  icon: Icon(Icons.minimize),
                  onPressed: () {
                    Navigator.pop(context); // closes the modal
                  },
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 40), // Add extra space at top for close button
                  Text(
                    title!,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(snippet!,
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                  SizedBox(height: 20),
                  if (!kIsWeb)
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (isDirections) {
                          setState(() {
                            isDirections = false;
                          });
                          await Future.delayed(Duration(seconds: 1));
                        }
                        isDirections = true;
                        getDirections(tappedMarker.position.latitude,
                            tappedMarker.position.longitude);
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.directions_walk),
                      label: Text('Get Directions'),
                    ),
                ],
              ),
            ],
          ),
        );
      },
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
          if (!isDirections) {
            updateCurrentPositionMarker(currentLocation);
          }

          if (isFirst) {
            isFirst = false;
            distance = calculateDistance(
                currentLocation.latitude, currentLocation.longitude);
          }
        });
      }
    });
  }

  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  loadMarkersFromJson() async {
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

    final Uint8List buildings = await getImages('assets/icon/building.png', 50);
    final Uint8List gates = await getImages('assets/icon/gates.png', 50);
    final Uint8List parking = await getImages('assets/icon/Parking.png', 50);
    final Uint8List service = await getImages('assets/icon/service.png', 50);
    final Uint8List restaurant =
        await getImages('assets/icon/restaurant.png', 100);
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
          icon: BitmapDescriptor.fromBytes(buildings),
          position: latLng,
          onTap: () {
            kIsWeb
                ? showMarkerInfoWindow(MarkerId(name), name,
                    feature['properties']['description'] ?? '')
                : showMarkerInfoWindowMobile(MarkerId(name), name,
                    feature['properties']['description'] ?? '');
          },
        ),
        //icon: BitmapDescriptor.fromAssetImage(configuration, assetName),
        //onTap: getDirections(),
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
          icon: BitmapDescriptor.fromBytes(restaurant),
          infoWindow: InfoWindow(
            title: name,
            onTap: () {
              showMarkerInfoWindow(MarkerId(name), name,
                  feature['properties']['description'] ?? '');
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
          icon: BitmapDescriptor.fromBytes(parking),
          position: latLng,
          onTap: () {
            kIsWeb
                ? showMarkerInfoWindow(MarkerId(name), name,
                    feature['properties']['description'] ?? '')
                : showMarkerInfoWindowMobile(MarkerId(name), name,
                    feature['properties']['description'] ?? '');
          },
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
          icon: BitmapDescriptor.fromBytes(gates),
          onTap: () {
            kIsWeb
                ? showMarkerInfoWindow(MarkerId(name), name,
                    feature['properties']['description'] ?? '')
                : showMarkerInfoWindowMobile(MarkerId(name), name,
                    feature['properties']['description'] ?? '');
          },
        ),
      );
    }

    for (var feature in servicesData) {
      String name = feature['properties']['Name'];
      List<dynamic> coordinates = feature['geometry']['coordinates'];
      LatLng latLng = LatLng(coordinates[1], coordinates[0]);

      servMarkers.add(
        Marker(
            icon: BitmapDescriptor.fromBytes(service),
            markerId: MarkerId(name),
            position: latLng,
            onTap: () {
              kIsWeb
                  ? showMarkerInfoWindow(MarkerId(name), name,
                      feature['properties']['description'] ?? '')
                  : showMarkerInfoWindowMobile(MarkerId(name), name,
                      feature['properties']['description'] ?? '');
            }),
      );
    }

    setState(() {});
  }
}
