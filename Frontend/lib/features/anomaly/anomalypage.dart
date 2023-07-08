import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:unilink2023/data/cache_factory_provider.dart';
import 'package:http/http.dart' as http;

import '../../constants.dart';
import '../../domain/Token.dart';

class ReportAnomalyPage extends StatefulWidget {
  @override
  State<ReportAnomalyPage> createState() => ReportAnomalyPageState();
}

class ReportAnomalyPageState extends State<ReportAnomalyPage> {
  final TextEditingController anomalytitleController = TextEditingController();
  final TextEditingController anomalyController = TextEditingController();
  LatLng? selectedLocation = null;

  void sendAnomaly(BuildContext context) {
    final anomalytitle = anomalytitleController.text;
    final anomalydesc = anomalyController.text;
    if (anomalydesc.isEmpty || anomalytitle.isEmpty) {
      _showErrorSnackbar('Fill out the obrigatory fields', true);
    }
    String coordinates = selectedLocation != null
        ? "${selectedLocation!.latitude},${selectedLocation!.longitude}"
        : "No locations specified";
    sendAnomalytoServer(
        context, anomalytitle, anomalydesc, coordinates, _showErrorSnackbar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: anomalytitleController,
              decoration: InputDecoration(
                labelText: 'Anomaly Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: anomalyController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Anomaly Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Open the popup map here
                    _openMapPopup(context);
                  },
                  child: Text(selectedLocation == null
                      ? 'Select Location'
                      : 'Reselect Location'),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () => sendAnomaly(context),
                  child: Text('Send'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openMapPopup(BuildContext context) {
    Set<Marker> _markers = {}; // Declare markers set
    LatLng? preLocation;
    GoogleMapController? mapController;

    showDialog(
      context: context,
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
                          if (mapController != null) {
                            mapController!.animateCamera(
                              CameraUpdate.newLatLng(preLocation!),
                            );
                          }
                        });
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
                          },
                          child: Text('Select Location'),
                        ),
                      ElevatedButton(
                        onPressed: () {
                          selectedLocation = null;
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

  void _showErrorSnackbar(String message, bool Error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Error ? Colors.red : Colors.blue.shade900,
      ),
    );
  }

  Future<void> sendAnomalytoServer(
    BuildContext context,
    String title,
    String description,
    String coord,
    void Function(String, bool) showErrorSnackbar,
  ) async {
    final url = kBaseUrl + "rest/anomaly/send";
    final tokenID = await cacheFactory.get('users', 'token');
    final storedUsername = await cacheFactory.get('users', 'username');
    Token token = new Token(tokenID: tokenID, username: storedUsername);

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${json.encode(token.toJson())}'
      },
      body: jsonEncode(
          {'title': title, 'description': description, 'coordinates': coord}),
    );
    if (response.statusCode == 200) {
      showErrorSnackbar('Sent Anomaly successfully!', false);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Anomaly Reported'),
            content: Text('Thank you for reporting the anomaly.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      anomalyController.clear();
    } else {
      showErrorSnackbar('Failed to send Anomaly: ${response.body}', true);
    }
  }
}
