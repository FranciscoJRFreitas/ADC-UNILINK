/*import 'package:flutter/material.dart';
import 'dart:html';
import 'dart:ui' as ui;
import 'package:google_maps/google_maps.dart';

import '../domain/LocationData.dart';

List<Marker> getMap(List<LocationData> locations, String htmlId) {
  //ignore: undefined_prefixed_name
  ui.platformViewRegistry.registerViewFactory(htmlId, (int viewId) {
    final mapOptions = MapOptions()
      ..zoom = 17
      ..tilt = 90
      ..center = locations[0].position;

    final elem = DivElement()
      ..id = htmlId
      ..style.width = "100%"
      ..style.height = "100%"
      ..style.border = "none";

    final map = GMap(elem, mapOptions);
    final markers = <Marker>[];

    for (var i = 0; i < locations.length; i++) {
      markers.add(Marker(MarkerOptions()
        ..position = locations[i].position
        ..map = map
        ..title = locations[i].name));
    }

    return markers;
  });

  // Returning HtmlElementView won't work here since it's just a view,
  // but we need to return the list of markers.
  // You will need to create the HtmlElementView separately.
  // return HtmlElementView(
  //   viewType: htmlId,
  // );
}
*/