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
  Set<Marker> restmarkers = Set();
  Map<PolylineId, Polyline> polylines = {}; //polylines to show direction

  double distance = 0.0;

  List<LatLng> polylineCoordinates = []; // Set to store the route polyline
  List<String> dropdownItems = ['Edificio', 'Restauraçao', 'Item 3'];
  String selectedDropdownItem = 'Edificio';

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

          if (latitude == null || longitude == null) {
            return Center(child: Text('Location not found'));
          }

          // Build the dropdown widget
          Widget dropdownWidget = DropdownButton<String>(
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
          );

          // This is where we'll add the dropdown
          return Stack(
            children: <Widget>[
              GoogleMap(
                zoomGesturesEnabled: true,
                initialCameraPosition: CameraPosition(
                  target: LatLng(38.660999, -9.205094),
                  zoom: 17.0,
                ),
                markers: selectedDropdownItem == "Edificio"
                    ? markers
                    : selectedDropdownItem == "Restauraçao"
                        ? restmarkers
                        : Set(),
                polylines: Set<Polyline>.of(polylines.values),
                mapType: MapType.normal,
                onMapCreated: (controller) {
                  setState(() {
                    mapController = controller;
                  });
                },
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

  Future<void> myMap(AsyncSnapshot<DatabaseEvent> snapshot) async {
    final data = snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;

    final latitude = data?[widget.userId]?['latitude'];
    final longitude = data?[widget.userId]?['longitude'];

    if (latitude != null && longitude != null) {
      await _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(38.660999, -9.205094), zoom: 17),
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
    // Departements
    markers.add(
      Marker(
        markerId: MarkerId('ED1'),
        position: LatLng(38.661275, -9.205565),
        infoWindow: InfoWindow(
          title: 'Edifício 1',
          snippet: 'example',
        ),
        // Optional: Set a custom icon for the marker
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      ),
    );
    markers.add(
      Marker(
        markerId: MarkerId('ED2'),
        position: LatLng(38.661158, -9.203591),
        infoWindow: InfoWindow(
          title: 'Edifício 2',
          snippet: 'example',
        ),
        // Optional: Set a custom icon for the marker
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      ),
    );
    markers.add(
      Marker(
        markerId: MarkerId('ED3'),
        position: LatLng(38.663218, -9.207174),
        infoWindow: InfoWindow(
          title: 'Edifício 3',
          snippet: 'example',
        ),
        // Optional: Set a custom icon for the marker
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      ),
    );
    markers.add(
      Marker(
        markerId: MarkerId('ED4'),
        position: LatLng(38.662920, -9.207217),
        infoWindow: InfoWindow(
          title: 'Edifício 4',
          snippet: 'example',
        ),
        // Optional: Set a custom icon for the marker
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      ),
    );
    markers.add(
      Marker(
        markerId: MarkerId('ED5'),
        position: LatLng(38.663352, -9.206885),
        infoWindow: InfoWindow(
          title: 'Edifício 5',
          snippet: 'Auditório Caixa Geral de Depósitos',
        ),
        // Optional: Set a custom icon for the marker
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      ),
    );
    markers.add(
      Marker(
        markerId: MarkerId('ED7'),
        position: LatLng(38.660504, -9.205801),
        infoWindow: InfoWindow(
          title: 'Edifício 7',
          snippet: 'example',
        ),
        // Optional: Set a custom icon for the marker
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      ),
    );
    markers.add(
      Marker(
        markerId: MarkerId('ED8'),
        position: LatLng(38.660095, -9.206643),
        infoWindow: InfoWindow(
          title: 'Edifício 8',
          snippet: 'example',
        ),
        // Optional: Set a custom icon for the marker
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      ),
    );
    markers.add(
      Marker(
        markerId: MarkerId('ED9'),
        position: LatLng(38.660192, -9.207139),
        infoWindow: InfoWindow(
          title: 'Edifício 9',
          snippet: 'example',
        ),
        // Optional: Set a custom icon for the marker
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      ),
    );
    markers.add(
      Marker(
        markerId: MarkerId('ED10'),
        position: LatLng(38.660422, -9.204882),
        infoWindow: InfoWindow(
          title: 'Edifício 10',
          snippet: 'example',
        ),
        // Optional: Set a custom icon for the marker
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      ),
    );
    markers.add(
      Marker(
        markerId: MarkerId('ED6'),
        position: LatLng(38.662476, -9.201807),
        infoWindow: InfoWindow(
          title: 'Edifício 6',
          snippet: 'Madan Parque',
        ),
        // Optional: Set a custom icon for the marker
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      ),
    );
    markers.add(
      Marker(
        markerId: MarkerId('ED11'),
        position: LatLng(38.662951, -9.206532),
        infoWindow: InfoWindow(
          title: 'Edifício 11',
          snippet: 'Laboratório de e-Learning',
        ),
        // Optional: Set a custom icon for the marker
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      ),
    );
    markers.add(
      Marker(
        markerId: MarkerId('EDD'),
        position: LatLng(38.662263, -9.207646),
        infoWindow: InfoWindow(
          title: 'Edifício Departamental',
          snippet: 'example',
        ),
        // Optional: Set a custom icon for the marker
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      ),
    );
    markers.add(
      Marker(
        markerId: MarkerId('CEN'),
        position: LatLng(38.659442, -9.203411),
        infoWindow: InfoWindow(
          title: 'CENIMAT',
          snippet: '',
        ),
        // Optional: Set a custom icon for the marker
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      ),
    );
    markers.add(
      Marker(
        markerId: MarkerId('H1'),
        position: LatLng(38.661682, -9.206876),
        infoWindow: InfoWindow(
          title: 'Hangar 1',
          snippet: 'Associação de Estudantes & Bar "Tanto Faz"',
        ),
        // Optional: Set a custom icon for the marker
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      ),
    );
    markers.add(
      Marker(
        markerId: MarkerId('H2'),
        position: LatLng(38.661914, -9.206715),
        infoWindow: InfoWindow(
          title: 'Hangar 2',
          snippet: 'Secção de Economato',
        ),
        // Optional: Set a custom icon for the marker
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      ),
    );
    markers.add(
      Marker(
        markerId: MarkerId('H3'),
        position: LatLng(38.662086, -9.206559),
        infoWindow: InfoWindow(
          title: 'Hangar 3',
          snippet: 'Vicarte - Centro do Vidro e Cerâmica para as Artes',
        ),
        // Optional: Set a custom icon for the marker
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      ),
    );
    markers.add(
      Marker(
        markerId: MarkerId('CAN'),
        position: LatLng(38.661557, -9.204855),
        infoWindow: InfoWindow(
          title: 'Cantina',
          snippet: '',
        ),
        // Optional: Set a custom icon for the marker
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      ),
    );
    markers.add(
      Marker(
        markerId: MarkerId('UNI1'),
        position: LatLng(38.660133, -9.204044),
        infoWindow: InfoWindow(
          title: 'UNINOVA 1',
          snippet: '',
        ),
        // Optional: Set a custom icon for the marker
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      ),
    );
    markers.add(
      Marker(
        markerId: MarkerId('UNI2'),
        position: LatLng(38.659816, -9.203687),
        infoWindow: InfoWindow(
          title: 'UNINOVA 2',
          snippet: '',
        ),
        // Optional: Set a custom icon for the marker
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      ),
    );
    markers.add(
      Marker(
        markerId: MarkerId('CEA'),
        position: LatLng(38.662223, -9.206000),
        infoWindow: InfoWindow(
          title: 'CEA - Centro de Excelência do Ambiente',
          snippet: '',
        ),
        // Optional: Set a custom icon for the marker
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      ),
    );
    markers.add(
      Marker(
        markerId: MarkerId('BIB'),
        position: LatLng(38.662659, -9.205397),
        infoWindow: InfoWindow(
          title: 'Biblioteca',
          snippet: '',
        ),
        // Optional: Set a custom icon for the marker
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      ),
    );
    markers.add(
      Marker(
        markerId: MarkerId('CRE'),
        position: LatLng(38.662020, -9.204214),
        infoWindow: InfoWindow(
          title: 'Creche',
          snippet: '',
        ),
        // Optional: Set a custom icon for the marker
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      ),
    );
    //restauracao
    restmarkers.add(
      Marker(
        markerId: MarkerId('AL'),
        position: LatLng(38.661956, -9.207895),
        infoWindow: InfoWindow(
          title: 'Alquimia',
          snippet: '',
        ),
        // Optional: Set a custom icon for the marker
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      ),
    );
    restmarkers.add(
      Marker(
        markerId: MarkerId('AL'),
        position: LatLng(38.661956, -9.207895),
        infoWindow: InfoWindow(
          title: 'Alquimia',
          snippet: '',
        ),
        // Optional: Set a custom icon for the marker
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      ),
    );
    restmarkers.add(
      Marker(
        markerId: MarkerId('TTF'),
        position: LatLng(38.661610, -9.206827),
        infoWindow: InfoWindow(
          title: 'Tanto Faz Bar Academico',
          snippet: '',
        ),
        // Optional: Set a custom icon for the marker
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      ),
    );
    restmarkers.add(
      Marker(
        markerId: MarkerId('CDP'),
        position: LatLng(38.661738, -9.205498),
        infoWindow: InfoWindow(
          title: 'Casa Do Pessoal',
          snippet: '',
        ),
        // Optional: Set a custom icon for the marker
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      ),
    );
    /*restmarkers.add(
      Marker(
        markerId: MarkerId('MIN'),
        position: LatLng(38.661364, -9.205387),
        infoWindow: InfoWindow(
          title: 'MiniNova',
          snippet: '',
        ),
        // Optional: Set a custom icon for the marker
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      ),
    );*/
    restmarkers.add(
      Marker(
        markerId: MarkerId('BC'),
        position: LatLng(38.662623, -9.205166),
        infoWindow: InfoWindow(
          title: 'Bar C@mpus',
          snippet: '',
        ),
        // Optional: Set a custom icon for the marker
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      ),
    );
    restmarkers.add(
      Marker(
        markerId: MarkerId('MS'),
        position: LatLng(38.660143, -9.205479),
        infoWindow: InfoWindow(
          title: 'My Spot',
          snippet: '',
        ),
        // Optional: Set a custom icon for the marker
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      ),
    );
    restmarkers.add(
      Marker(
        markerId: MarkerId('BT'),
        position: LatLng(38.661311, -9.204934),
        infoWindow: InfoWindow(
          title: 'Bar "Tia"',
          snippet: '',
        ),
        // Optional: Set a custom icon for the marker
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      ),
    );
    restmarkers.add(
      Marker(
        markerId: MarkerId('CANR'),
        position: LatLng(38.661541, -9.204948),
        infoWindow: InfoWindow(
          title: 'Cantina',
          snippet: '',
        ),
        // Optional: Set a custom icon for the marker
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      ),
    );
    //nucleos que cringe
    // Set the state to update the map with the new markers
    setState(() {}); // Draw route between markers
  }
}
