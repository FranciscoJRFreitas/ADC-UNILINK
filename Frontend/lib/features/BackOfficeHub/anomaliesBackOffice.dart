import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../application/loadLocations.dart';
import '../../constants.dart';
import '../../data/cache_factory_provider.dart';
import '../../domain/Token.dart';
import '../anomaly/Domain/Anomaly.dart';

class AnomaliesPage extends StatefulWidget {
  @override
  _AnomaliesPageState createState() => _AnomaliesPageState();
}

class _AnomaliesPageState extends State<AnomaliesPage>
    with TickerProviderStateMixin {
  List<Anomaly> _anomalies = [];
  List<Anomaly> _detectedAnomalies = [];
  List<Anomaly> _confirmedAnomalies = [];
  List<Anomaly> _rejectedAnomalies = [];
  List<Anomaly> _inProgressAnomalies = [];
  List<Anomaly> _solvedAnomalies = [];
  late DatabaseReference _anomaliesRef;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 6);
    _anomaliesRef = FirebaseDatabase.instance.ref('anomaly');

    _anomaliesRef.onChildAdded.listen((event) {
      var anomaly = Anomaly.fromSnapshot(event.snapshot);
      setState(() {
        _anomalies.add(anomaly);
        switch (anomaly.status) {
          case 'Detected':
            _detectedAnomalies.add(anomaly);
            break;
          case 'Confirmed':
            _confirmedAnomalies.add(anomaly);
            break;
          case 'Rejected':
            _rejectedAnomalies.add(anomaly);
            break;
          case 'In Progress':
            _inProgressAnomalies.add(anomaly);
            break;
          case 'Solved':
            _solvedAnomalies.add(anomaly);
            break;
        }
      });
    });

    _anomaliesRef.onChildRemoved.listen((event) {
      setState(() {
        _anomalies
            .removeWhere((anomaly) => anomaly.anomalyId == event.snapshot.key);
        _detectedAnomalies
            .removeWhere((anomaly) => anomaly.anomalyId == event.snapshot.key);
        _confirmedAnomalies
            .removeWhere((anomaly) => anomaly.anomalyId == event.snapshot.key);
        _rejectedAnomalies
            .removeWhere((anomaly) => anomaly.anomalyId == event.snapshot.key);
        _inProgressAnomalies
            .removeWhere((anomaly) => anomaly.anomalyId == event.snapshot.key);
        _solvedAnomalies
            .removeWhere((anomaly) => anomaly.anomalyId == event.snapshot.key);
      });
    });

    _anomaliesRef.onChildChanged.listen((event) {
      setState(() {
        var oldAnomaly = _anomalies
            .firstWhere((anomaly) => anomaly.anomalyId == event.snapshot.key);
        var newAnomaly = Anomaly.fromSnapshot(event.snapshot);

        _anomalies[_anomalies.indexOf(oldAnomaly)] = newAnomaly;

        updateAnomalyInList(_detectedAnomalies, oldAnomaly, newAnomaly);
        updateAnomalyInList(_confirmedAnomalies, oldAnomaly, newAnomaly);
        updateAnomalyInList(_rejectedAnomalies, oldAnomaly, newAnomaly);
        updateAnomalyInList(_inProgressAnomalies, oldAnomaly, newAnomaly);
        updateAnomalyInList(_solvedAnomalies, oldAnomaly, newAnomaly);
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void updateAnomalyInList(
      List<Anomaly> list, Anomaly oldAnomaly, Anomaly newAnomaly) {
    if (list.contains(oldAnomaly)) {
      list[list.indexOf(oldAnomaly)] = newAnomaly;
    } else if (newAnomaly.status == getAnomalyStatus(list)) {
      list.add(newAnomaly);
    }
  }

  String getAnomalyStatus(List<Anomaly> list) {
    if (list == _detectedAnomalies) return 'Detected';
    if (list == _confirmedAnomalies) return 'Confirmed';
    if (list == _rejectedAnomalies) return 'Rejected';
    if (list == _inProgressAnomalies) return 'In Progress';
    if (list == _solvedAnomalies) return 'Solved';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            color: Theme.of(context)
                .secondaryHeaderColor, // Customize color as per your need
          ),
          centerTitle: true,
          title: Text(
            'Anomalies Management',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          backgroundColor: Theme.of(context)
              .primaryColor, // Customize color as per your need
        ),
        body: Column(children: [
          PreferredSize(
            preferredSize: Size.fromHeight(80),
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: TabBar(
                labelColor: Theme.of(context).secondaryHeaderColor,
                indicatorColor: Style.darkBlue,
                tabs: <Widget>[
                  Tab(
                      icon: Icon(
                        Icons.list,
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                      text: "All"),
                  Tab(
                      icon: Icon(
                        Icons.call_received,
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                      text: "Detected"),
                  Tab(
                      icon: Icon(
                        Icons.verified_rounded,
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                      text: "Confirmed"),
                  Tab(
                      icon: Icon(
                        Icons.cancel,
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                      text: "Rejected"),
                  Tab(
                      icon: Icon(
                        Icons.pending_actions,
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                      text: "In Progress"),
                  Tab(
                      icon: Icon(
                        Icons.done_outline,
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                      text: "Solved"),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: <Widget>[
                buildAnomalyList(_anomalies),
                buildAnomalyList(_detectedAnomalies),
                buildAnomalyList(_confirmedAnomalies),
                buildAnomalyList(_rejectedAnomalies),
                buildAnomalyList(_inProgressAnomalies),
                buildAnomalyList(_solvedAnomalies),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget buildAnomalyList(List<Anomaly> anomalyList) {
    return Column(children: [
      Row(
        children: [
          Text(
            '   There ${anomalyList.length == 1 ? 'is ${anomalyList.length} anomaly' : 'are ${anomalyList.length} anomalies'}!',
            style: Theme.of(context).textTheme.titleMedium,
          )
        ],
      ),
      Expanded(
        // Wrap ListView.builder in an Expanded widget
        child: ListView.builder(
          itemCount: anomalyList.length,
          itemBuilder: (context, index) {
            Color _statusColor = getStatusColor(anomalyList[index].status);
            return Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: ListTile(
                  title: Row(
                    children: [
                      InkWell(
                        child: Text(
                          anomalyList[index].title,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (anomalyList[index].coordinates != "0") ...[
                        SizedBox(width: 10),
                        InkWell(
                          onTap: () {
                            // Handle click on clock icon
                            // Navigate to another page or perform desired action
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
                          Icon(Icons.person, size: 20, color: _statusColor),
                          SizedBox(width: 5),
                          Text(
                            'Reporting person: ',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(fontSize: 14),
                          ),
                          Flexible(
                            child: Text(
                              anomalyList[index].sender,
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
                              anomalyList[index].status,
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
                              anomalyList[index].description,
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      if (anomalyList[index].coordinates != '0') ...[
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
                                  anomalyList[index].coordinates),
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
                              formatTimeInMillis(anomalyList[index].timestamp),
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.change_history,
                              size: 20, color: _statusColor),
                          SizedBox(width: 5),
                          Text(
                            'Change Status: ',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(fontSize: 14),
                          ),
                          DropdownButton<String>(
                              value: anomalyList[index].status,
                              items: <String>[
                                'Detected',
                                'Confirmed',
                                'Rejected',
                                'In Progress',
                                'Solved',
                                'Delete'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null &&
                                    newValue != anomalyList[index].status) {
                                  if (newValue == 'Delete') {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          title: Text(
                                            'Confirm Delete',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          content: Text(
                                            'Are you sure you want to delete this anomaly?',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                // Proceed with deletion
                                                changeAnomalyStatus(
                                                  context,
                                                  anomalyList[index].anomalyId!,
                                                  anomalyList[index].status,
                                                  newValue,
                                                  _showErrorSnackbar,
                                                );
                                              },
                                              child: Text('Delete'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(
                                                    context); // Close the dialog
                                              },
                                              child: Text('Cancel'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    changeAnomalyStatus(
                                      context,
                                      anomalyList[index].anomalyId!,
                                      anomalyList[index].status,
                                      newValue,
                                      _showErrorSnackbar,
                                    );
                                  }
                                }
                              }),
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
    ]);
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

  Future<void> changeAnomalyStatus(
    BuildContext context,
    String anomalyId,
    String oldStatus,
    String status,
    void Function(String, bool) showErrorSnackbar,
  ) async {
    String statusUrl;
    switch (status) {
      case 'Detected':
        {
          statusUrl = "rest/anomaly/detect";
          break;
        }
      case 'Confirmed':
        {
          statusUrl = "rest/anomaly/confirm";
          break;
        }
      case 'Rejected':
        {
          statusUrl = "rest/anomaly/reject";
          break;
        }
      case 'In Progress':
        {
          statusUrl = "rest/anomaly/inProgress";
          break;
        }
      case 'Solved':
        {
          statusUrl = "rest/anomaly/resolve";
          break;
        }
      case 'Delete':
        {
          statusUrl = "rest/anomaly/delete";
          break;
        }
      default:
        {
          showErrorSnackbar("Invalid status provided", true);
          return;
        }
    }

    final url = kBaseUrl + statusUrl;
    final tokenID = await cacheFactory.get('users', 'token');
    final storedUsername = await cacheFactory.get('users', 'username');
    Token token = new Token(tokenID: tokenID, username: storedUsername);

    Completer<void> dialogCompleter = Completer<void>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // Start a timer of 10 seconds
        Future.delayed(Duration(seconds: 10)).then((_) {
          if (!dialogCompleter.isCompleted) {
            Navigator.of(context).pop();
            showErrorSnackbar(
                "An error occurred: Timeout. Please try again later...", true);
            dialogCompleter.complete();
          }
        });

        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                Text("Changing Anomaly Status..."),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      if (!dialogCompleter.isCompleted) {
        dialogCompleter.complete();
      }
    });

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${json.encode(token.toJson())}'
      },
      body: anomalyId,
    );

    if (response.statusCode == 200) {
      Navigator.of(context).pop();
      setState(() {
        var anomaly =
            _anomalies.firstWhere((anomaly) => anomaly.anomalyId == anomalyId);
        updateAnomalyStatusLists(oldStatus, status, anomaly);
      });
      dialogCompleter.complete();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Anomaly Status Changed'),
            content: Text('Anomaly status changed successfully.'),
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
    } else {
      Navigator.of(context).pop();
      showErrorSnackbar(
          'Failed to change anomaly status: ${response.body}', true);
    }
  }

  void updateAnomalyStatusLists(
    String oldStatus,
    String newStatus,
    Anomaly anomaly,
  ) {
    late List<Anomaly> oldStatusAnomalies;
    late List<Anomaly> newStatusAnomalies;

    // Determine old status list
    switch (oldStatus) {
      case 'Detected':
        oldStatusAnomalies = _detectedAnomalies;
        break;
      case 'Confirmed':
        oldStatusAnomalies = _confirmedAnomalies;
        break;
      case 'Rejected':
        oldStatusAnomalies = _rejectedAnomalies;
        break;
      case 'In Progress':
        oldStatusAnomalies = _inProgressAnomalies;
        break;
      case 'Solved':
        oldStatusAnomalies = _solvedAnomalies;
        break;
    }

    // Determine new status list
    switch (newStatus) {
      case 'Detected':
        newStatusAnomalies = _detectedAnomalies;
        break;
      case 'Confirmed':
        newStatusAnomalies = _confirmedAnomalies;
        break;
      case 'Rejected':
        newStatusAnomalies = _rejectedAnomalies;
        break;
      case 'In Progress':
        newStatusAnomalies = _inProgressAnomalies;
        break;
      case 'Solved':
        newStatusAnomalies = _solvedAnomalies;
        break;
    }

    oldStatusAnomalies.remove(anomaly);
    newStatusAnomalies.add(anomaly);
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
}
