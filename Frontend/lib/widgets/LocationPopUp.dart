import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../application/loadLocations.dart';

class EventLocationPopUp extends StatefulWidget {
  final BuildContext context;
  final LatLng? location;
  final bool isMapSelected;

  EventLocationPopUp({
    required this.context,
    required this.location,
    required this.isMapSelected,
  });

  @override
  _EventLocationPopUpState createState() => _EventLocationPopUpState();
}

class _EventLocationPopUpState extends State<EventLocationPopUp> {
  String? selectedPlace;
  LatLng? selectedLocation;
  late Set<Marker> edMarkers = Set();
  late Set<Marker> restMarkers = Set();
  late Set<Marker> parkMarkers = Set();
  late Set<Marker> portMarkers = Set();
  late Set<Marker> servMarkers = Set();

  @override
  void initState() {
    super.initState();
    loadMarkers();
    if (widget.isMapSelected) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showMapDialog());
    } else {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _showFCTPlaceDialog());
    }
  }

  loadMarkers() async {
    edMarkers = await loadEdLocationsFromJson();
    restMarkers = await loadRestLocationsFromJson();
    parkMarkers = await loadParkLocationsFromJson();
    portMarkers = await loadPortLocationsFromJson();
    servMarkers = await loadServLocationsFromJson();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  void _showFCTPlaceDialog() {
    //print(edMarkers);
    showDialog<LatLng>(
      context: widget.context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).canvasColor,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (selectedPlace != null) ...[
                    IconButton(
                      hoverColor: Theme.of(context).hoverColor.withOpacity(0.1),
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        setState(() {
                          selectedPlace = null;
                        });
                      },
                    ),
                    SizedBox(
                      width: 10,
                    )
                  ],
                  Text(
                    "Select a FCT Location",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontSize: 30),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: selectedPlace == null
                      ? [
                          ListTile(
                            title: Text(
                              'Buildings',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(fontSize: 20),
                            ),
                            onTap: () => setState(() {
                              selectedPlace = 'Building';
                            }),
                          ),
                          ListTile(
                            title: Text(
                              'Restaurants',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(fontSize: 20),
                            ),
                            onTap: () => setState(() {
                              selectedPlace = 'Restaurant';
                            }),
                          ),
                          ListTile(
                            title: Text(
                              'Parking Lots',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(fontSize: 20),
                            ),
                            onTap: () => setState(() {
                              selectedPlace = 'Park';
                            }),
                          ),
                          ListTile(
                            title: Text(
                              'Gates',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(fontSize: 20),
                            ),
                            onTap: () => setState(() {
                              selectedPlace = 'Port';
                            }),
                          ),
                          ListTile(
                            title: Text(
                              'Services',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(fontSize: 20),
                            ),
                            onTap: () => setState(() {
                              selectedPlace = 'Service';
                            }),
                          ),
                        ]
                      : getMarkersForPlace(selectedPlace!)
                          .map((marker) => ListTile(
                              title: Text(
                                marker.infoWindow.title!,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(fontSize: 20),
                              ),
                              onTap: () => {
                                    setState(() {
                                      selectedLocation = marker.position;
                                    }),
                                    Navigator.of(context).pop(selectedLocation),
                                    Navigator.of(context).pop(selectedLocation),
                                  }))
                          .toList(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Cancel',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).secondaryHeaderColor),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Set<Marker> getMarkersForPlace(String place) {
    switch (place) {
      case 'Building':
        return edMarkers;
      case 'Restaurant':
        return restMarkers;
      case 'Park':
        return parkMarkers;
      case 'Port':
        return portMarkers;
      case 'Service':
        return servMarkers;
      default:
        return {};
    }
  }

  void _showMapDialog() {
    LatLng? preLocation;
    Set<Marker> _markers = {};
    GoogleMapController? mapController;
    showDialog(
      context: widget.context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            content: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: GoogleMap(
                      onMapCreated: (GoogleMapController controller) {
                        mapController = controller;
                      },
                      initialCameraPosition: CameraPosition(
                        target: LatLng(38.660999, -9.205094),
                        zoom: 17,
                      ),
                      onTap: (LatLng location) {
                        setState(() {
                          preLocation = location;
                          _markers.clear();
                          _markers.add(Marker(
                            markerId: MarkerId(preLocation.toString()),
                            position: preLocation!,
                          ));
                        });
                        if (mapController != null) {
                          mapController!.animateCamera(
                            CameraUpdate.newLatLng(preLocation!),
                          );
                        }
                      },
                      markers: _markers,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (preLocation != null)
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedLocation = preLocation;
                            });
                            Navigator.of(context).pop(selectedLocation);
                            Navigator.of(context).pop(selectedLocation);
                          },
                          child: Text('Select Location'),
                        ),
                      ElevatedButton(
                        onPressed: () {
                          selectedLocation = null;
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        child: Text('Close'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
