import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<Set<Marker>> loadEdLocationsFromJson() async {
  Set<Marker> edMarkers = Set();

  String buildingsJson =
      await rootBundle.loadString('assets/json/map/Edificios.json');

  List<dynamic> buildingsData = jsonDecode(buildingsJson)['features'];

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
  return edMarkers;
}

Future<Set<Marker>> loadRestLocationsFromJson() async {
  Set<Marker> restMarkers = Set();
  String eatingSpacesJson =
      await rootBundle.loadString('assets/json/map/Espacos_de_refeicao.json');
  List<dynamic> eatingSpacesData = jsonDecode(eatingSpacesJson)['features'];
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
          snippet: feature['properties']['description'] ?? '',
        ),
      ),
    );
  }
  return restMarkers;
}

Future<Set<Marker>> loadParkLocationsFromJson() async {
  Set<Marker> parkMarkers = Set();
  String parkingLotsJson = await rootBundle
      .loadString('assets/json/map/Parques_de_estacionamento.json');
  List<dynamic> parkingLotsData = jsonDecode(parkingLotsJson)['features'];
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
          snippet: feature['properties']['description'] ?? '',
        ),
      ),
    );
  }
  return parkMarkers;
}

Future<Set<Marker>> loadPortLocationsFromJson() async {
  Set<Marker> portMarkers = Set();
  String gatesJson =
      await rootBundle.loadString('assets/json/map/Portarias.json');
  List<dynamic> gatesData = jsonDecode(gatesJson)['features'];
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
          snippet: feature['properties']['description'] ?? '',
        ),
      ),
    );
  }
  return portMarkers;
}

Future<Set<Marker>> loadServLocationsFromJson() async {
  Set<Marker> servMarkers = Set();
  String servicesJson =
      await rootBundle.loadString('assets/json/map/Servicos.json');
  List<dynamic> servicesData = jsonDecode(servicesJson)['features'];
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
          snippet: feature['properties']['description'] ?? '',
        ),
      ),
    );
  }
  return servMarkers;
}

Future<Set<Marker>> loadLocationsFromJson() async {
  Set<Marker> allMarkers = {};
  allMarkers.addAll(await loadEdLocationsFromJson());
  allMarkers.addAll(await loadRestLocationsFromJson());
  allMarkers.addAll(await loadParkLocationsFromJson());
  allMarkers.addAll(await loadPortLocationsFromJson());
  allMarkers.addAll(await loadServLocationsFromJson());
  return allMarkers;
}

Future<String> getPlaceInLocations(String location) async {
  String res = "";
  Set<Marker> allMarkers = await loadLocationsFromJson();
  allMarkers.forEach((element) {
    if ('${element.position.latitude},${element.position.longitude}' ==
        location) res = element.infoWindow.title!;
  });
  return res;
}
