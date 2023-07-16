import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unilink2023/domain/Token.dart';
import 'package:unilink2023/features/calendar/application/event_utils.dart';
import 'package:unilink2023/features/map/MapPage.dart';
import 'package:unilink2023/features/map/application/map_utils.dart';

import '../../application/loadLocations.dart';
import '../../constants.dart';
import '../../data/cache_factory_provider.dart';
import '../../domain/ThemeNotifier.dart';
import '../calendar/domain/Event.dart';
import '../navigation/main_screen_page.dart';
import 'package:http/http.dart' as http;

class GroupEventsPage extends StatefulWidget {
  final String groupId;
  final String displayname;

  const GroupEventsPage({required this.groupId, required this.displayname});

  @override
  _GroupEventsPageState createState() => _GroupEventsPageState();
}

class _GroupEventsPageState extends State<GroupEventsPage> {
  List<Event> events = []; // Replace with your event list

  @override
  void initState() {
    super.initState();
    getEvents();
  }

  void getEvents() async {
    DatabaseReference eventsRef =
        FirebaseDatabase.instance.ref().child('events').child(widget.groupId);

    eventsRef.onChildAdded.listen((event) {
      setState(() {
        String? id = event.snapshot.key; // Here is how you get the key
        Event currentEvent = id != null
            ? Event.fromSnapshotId(id, event.snapshot)
            : Event.fromSnapshot(event.snapshot);
        events.add(currentEvent);
      });
    });

    eventsRef.onChildRemoved.listen((event) {
      String eventId = event.snapshot.key as String;

      setState(() {
        events.removeWhere((event) => event.id == eventId);
      });
    });
    print(events);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          widget.displayname + " events",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: buildEventList(), // Add this line to display the event list
    );
  }

  Widget buildEventList() {
    if (events.isEmpty) {
      return Center(
        child: Text('No events available.'),
      );
    }

    return ListView.builder(
      itemCount: events.length,
      padding: EdgeInsets.only(top: 10),
      itemBuilder: (context, index) {
        Event event = events[index];
        return Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              // Handle event onTap
            },
            child: Stack(
              children: <Widget>[
                Divider(
                  color: Provider.of<ThemeNotifier>(context).currentTheme ==
                          kDarkTheme
                      ? Colors.white60
                      : Theme.of(context).primaryColor,
                  thickness: 1,
                ),
                Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    child: ListTile(
                      title: Row(
                        children: [
                          InkWell(
                            child: Text(
                              event.title,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(width: 10),
                          if (events[index].location != "0") ...[
                            SizedBox(width: 10),
                            InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.8,
                                        child: Column(
                                          children: <Widget>[
                                            Expanded(
                                              child: GoogleMap(
                                                onMapCreated:
                                                    (GoogleMapController
                                                        controller) {},
                                                initialCameraPosition:
                                                    CameraPosition(
                                                  target: parseCoordinates(
                                                      events[index].location!),
                                                  zoom: 17,
                                                ),
                                                markers: {
                                                  Marker(
                                                    markerId: MarkerId(
                                                        'anomalyMarker'),
                                                    position: parseCoordinates(
                                                        events[index]
                                                            .location!),
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
                              child: Tooltip(
                                message: "View in Maps",
                                child: Icon(Icons.directions),
                              ),
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
                              Icon(
                                Icons.type_specimen,
                                size: 20,
                                color: Style.lightBlue,
                              ),
                              SizedBox(width: 5),
                              Row(
                                children: [
                                  Text(
                                    'Type: ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6!
                                        .copyWith(fontSize: 14),
                                  ),
                                  Text(
                                    getEventTypeString(event.type),
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.description,
                                size: 20,
                                color: Style.lightBlue,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Description: ',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .copyWith(fontSize: 14),
                              ),
                              Flexible(
                                child: Text(
                                  event.description,
                                  style: Theme.of(context).textTheme.bodyText1,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          if (event.location != '0') ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.place,
                                  size: 20,
                                  color: Style.lightBlue,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Location: ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .copyWith(fontSize: 14),
                                ),
                                FutureBuilder<String>(
                                  future: getPlaceInLocations(event.location!),
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
                                                    .bodyText1,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : Text(
                                                snapshot.data!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1,
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
                              Icon(
                                Icons.schedule,
                                size: 20,
                                color: Style.lightBlue,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Start: ',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .copyWith(fontSize: 14),
                              ),
                              Flexible(
                                child: Text(
                                  '${DateFormat('yyyy-MM-dd HH:mm').format(event.startTime)}',
                                  style: Theme.of(context).textTheme.bodyText1,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 20,
                                color: Style.lightBlue,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'End: ',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .copyWith(fontSize: 14),
                              ),
                              Flexible(
                                child: Text(
                                  '${DateFormat('yyyy-MM-dd HH:mm').format(event.endTime)}',
                                  style: Theme.of(context).textTheme.bodyText1,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 15,
                  right: 10,
                  child: Container(
                    width: 24,
                    height: 24,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Tooltip(
                        message: "Remove Event",
                        child: Icon(Icons.delete, color: Colors.blue),
                      ),
                      onPressed: () {
                        if (kIsWeb)
                          _removeEventPopUpDialogWeb(context, event.id!);
                        else
                          _removeEventPopUpDialogMobile(context, event.id!);
                      },
                    ),
                  ),
                ),
                Divider(
                  color: Colors.black87,
                  thickness: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _removeEventPopUpDialogWeb(BuildContext context, String eventId) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: ((context, setState) {
            return AlertDialog(
              backgroundColor: Colors.black,
              title: const Text(
                "Remove an event",
                textAlign: TextAlign.left,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Are you sure you want remove this event? This action is irreversible.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  )
                ],
              ),
              actions: [
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        {
                          removeEvent(context, eventId, widget.groupId,
                              _showErrorSnackbar);
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).primaryColor),
                      child: const Text("CONFIRM"),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).primaryColor),
                      child: const Text("CANCEL"),
                    ),
                  ],
                ),
              ],
            );
          }));
        });
  }

  void _removeEventPopUpDialogMobile(BuildContext context, String eventId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Style.darkBlue,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: ((context, setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.3,
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: Icon(Icons.close),
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
                    const Text(
                      "Remove an event",
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                          "Are you sure you want remove this event? This action is irreversible.",
                          style: Theme.of(context).textTheme.bodyLarge!),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        removeEvent(context, eventId, widget.groupId,
                            _showErrorSnackbar);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87),
                      child: const Text("CONFIRM"),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
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

  Future<void> removeEvent(
    BuildContext context,
    String eventId,
    String groupId,
    void Function(String, bool) showErrorSnackbar,
  ) async {
    final url =
        kBaseUrl + "rest/events/delete?eventID=$eventId&groupID=$groupId";
    final tokenID = await cacheFactory.get('users', 'token');
    final storedUsername = await cacheFactory.get('users', 'username');
    Token token = new Token(tokenID: tokenID, username: storedUsername);

    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${json.encode(token.toJson())}'
      },
    );

    if (response.statusCode == 200) {
      showErrorSnackbar('Removed successfully!', false);
    } else {
      showErrorSnackbar('Failed to remove the event: ${response.body}', true);
    }
  }
}
