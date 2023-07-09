import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:unilink2023/features/anomaly/Domain/Anomaly.dart';

import '../../application/loadLocations.dart';
import '../../constants.dart';
import '../userManagement/domain/User.dart';

class MyReportedAnomaliesTab extends StatefulWidget {
  User user;

  MyReportedAnomaliesTab({required this.user});

  @override
  _MyReportedAnomaliesTabState createState() => _MyReportedAnomaliesTabState();
}

class _MyReportedAnomaliesTabState extends State<MyReportedAnomaliesTab> {
  final anomalyRef = FirebaseDatabase.instance.ref().child("anomaly");
  List<Anomaly> anomaliesList = [];

  @override
  void initState() {
    super.initState();
    anomalyRef.onChildAdded.listen((event) {
      var anomaly = Anomaly.fromSnapshot(event.snapshot);
      if (anomaly.sender == widget.user.username) {
        setState(() {
          anomaliesList.add(anomaly);
        });
      }
    });

    anomalyRef.onChildRemoved.listen((event) {
      setState(() {
        anomaliesList
            .removeWhere((anomaly) => anomaly.anomalyId == event.snapshot.key);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      Row(
        children: [
          Text(
            '   You have reported ${anomaliesList.length} ${anomaliesList.length == 1 ? 'anomaly' : 'anomalies'}!',
            style: Theme.of(context).textTheme.titleMedium,
          )
        ],
      ),
      Expanded(
        // Wrap ListView.builder in an Expanded widget
        child: ListView.builder(
          itemCount: anomaliesList.length,
          itemBuilder: (context, index) {
            Color _statusColor = getStatusColor(anomaliesList[index].status);
            return Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: ListTile(
                  title: Row(
                    children: [
                      InkWell(
                        child: Text(
                          anomaliesList[index].title,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (anomaliesList[index].coordinates != "0") ...[
                        SizedBox(width: 10),
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    height: MediaQuery.of(context).size.height *
                                        0.8,
                                    child: Column(
                                      children: <Widget>[
                                        Expanded(
                                          child: GoogleMap(
                                            onMapCreated: (GoogleMapController
                                                controller) {},
                                            initialCameraPosition:
                                                CameraPosition(
                                              target: parseCoordinates(
                                                  anomaliesList[index]
                                                      .coordinates),
                                              zoom: 17,
                                            ),
                                            markers: {
                                              Marker(
                                                markerId:
                                                    MarkerId('anomalyMarker'),
                                                position: parseCoordinates(
                                                    anomaliesList[index]
                                                        .coordinates),
                                              ),
                                            },
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
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
                              },
                            );
                          },
                          child: Icon(Icons.directions,
                              size: 20, color: _statusColor),
                        ),
                      ]
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.query_stats_outlined,
                              size: 20, color: _statusColor),
                          SizedBox(width: 5),
                          Text(
                            'Status: ',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(fontSize: 14),
                          ),
                          Flexible(
                            child: Text(
                              anomaliesList[index].status,
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.description,
                              size: 20, color: _statusColor),
                          SizedBox(width: 5),
                          Text(
                            'Description: ',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(fontSize: 14),
                          ),
                          Flexible(
                            child: Text(
                              anomaliesList[index].description,
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      if (anomaliesList[index].coordinates != '0') ...[
                        Row(
                          children: [
                            Icon(Icons.place, size: 20, color: _statusColor),
                            SizedBox(width: 5),
                            Text(
                              'Location: ',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(fontSize: 14),
                            ),
                            FutureBuilder<String>(
                              future: getPlaceInLocations(
                                  anomaliesList[index].coordinates),
                              builder: (BuildContext context,
                                  AsyncSnapshot<String> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return SizedBox.shrink();
                                } else {
                                  if (snapshot.hasError)
                                    return Text('Error: ${snapshot.error}');
                                  else
                                    return snapshot.data == ""
                                        ? Text(
                                            "Custom Location",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        : Text(
                                            snapshot.data!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          );
                                }
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                      ],
                      Row(
                        children: [
                          Icon(Icons.hourglass_bottom,
                              size: 20, color: _statusColor),
                          SizedBox(width: 5),
                          Text(
                            'Reported Time: ',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(fontSize: 14),
                          ),
                          Flexible(
                            child: Text(
                              formatTimeInMillis(
                                  anomaliesList[index].timestamp),
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 300,
                          child: Divider(
                            thickness: 1,
                            color: _statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ]));
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Detected':
        return Colors.yellow;
      case 'Confirmed':
        return Colors.orange;
      case 'Rejected':
        return Colors.red;
      case 'In Progress':
        return Colors.blue;
      case 'Solved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String formatTimeInMillis(int timeInMillis) {
    String res = '';
    var date = DateTime.fromMillisecondsSinceEpoch(timeInMillis);
    var formatter = DateFormat('HH:mm');
    res += formatter.format(date);
    formatter = DateFormat('d/M/y');
    res += ' ' + formatter.format(date);
    return res;
  }

  LatLng parseCoordinates(String coordinates) {
    // Parse the coordinates string and return a LatLng object
    // This is just a placeholder, replace it with your actual logic
    double latitude = 0.0;
    double longitude = 0.0;
    // Split the coordinates string and convert to double values
    List<String> coords = coordinates.split(",");
    if (coords.length == 2) {
      latitude = double.tryParse(coords[0]) ?? 0.0;
      longitude = double.tryParse(coords[1]) ?? 0.0;
    }
    return LatLng(latitude, longitude);
  }
}
