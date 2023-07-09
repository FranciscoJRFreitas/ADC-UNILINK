import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unilink2023/domain/Token.dart';

import '../../application/loadLocations.dart';
import '../../constants.dart';
import '../../data/cache_factory_provider.dart';
import '../../domain/ThemeNotifier.dart';
import '../calendar/domain/Event.dart';
import '../navigation/main_screen_page.dart';
import 'package:http/http.dart' as http;

class GroupEventsPage extends StatefulWidget {
  final String groupId;

  const GroupEventsPage({required this.groupId});

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
        title: Text(
          widget.groupId + " events",
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

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(top: 10),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 433,
          child: ListView.builder(
            itemCount: events.length,
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
                        color:
                            Provider.of<ThemeNotifier>(context).currentTheme ==
                                    kDarkTheme
                                ? Colors.white60
                                : Theme.of(context).primaryColor,
                        thickness: 1,
                      ),
                      Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                          child: ListTile(
                            title: Row(
                              children: [
                                InkWell(
                                  child: Text(
                                    event.title,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(width: 10),
                                if (event.location != "0") ...[
                                  SizedBox(width: 10),
                                  InkWell(
                                    onTap: () {
                                      // Handle click on location icon
                                      // Navigate to another page or perform desired action
                                    },
                                    child: Icon(
                                      Icons.directions,
                                      size: 20,
                                      color: Style.lightBlue,
                                    ),
                                  ),
                                ],
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
                                              .titleMedium!
                                              .copyWith(fontSize: 14),
                                        ),
                                        Text(
                                          _getEventTypeString(event.type),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
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
                                          .titleMedium!
                                          .copyWith(fontSize: 14),
                                    ),
                                    Flexible(
                                      child: Text(
                                        event.description,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
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
                                            .titleMedium!
                                            .copyWith(fontSize: 14),
                                      ),
                                      FutureBuilder<String>(
                                        future: getPlaceInLocations(
                                            event.location!),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<String> snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return SizedBox.shrink();
                                          } else {
                                            if (snapshot.hasError)
                                              return Text(
                                                  'Error: ${snapshot.error}');
                                            else
                                              return snapshot.data == ""
                                                  ? Text(
                                                      "Custom Location",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )
                                                  : Text(
                                                      snapshot.data!,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                                          .titleMedium!
                                          .copyWith(fontSize: 14),
                                    ),
                                    Flexible(
                                      child: Text(
                                        '${DateFormat('yyyy-MM-dd HH:mm').format(event.startTime)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
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
                                          .titleMedium!
                                          .copyWith(fontSize: 14),
                                    ),
                                    Flexible(
                                      child: Text(
                                        '${DateFormat('yyyy-MM-dd HH:mm').format(event.endTime)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
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
                            icon: Icon(Icons.delete, color: Colors.blue),
                            onPressed: () {
                              if (kIsWeb)
                                _removeEventPopUpDialogWeb(context, event.id!);
                              else
                                _removeEventPopUpDialogMobile(
                                    context, event.id!);
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
          ),
        ),
      ),
    );
  }

  _removeEventPopUpDialogWeb(BuildContext context, String eventId) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: ((context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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

  static String _getEventTypeString(EventType eventType) {
    switch (eventType) {
      case EventType.academic:
        return 'Academic';
      case EventType.entertainment:
        return 'Entertainment';
      case EventType.faire:
        return 'Faire';
      case EventType.athletics:
        return 'Athletics';
      case EventType.competition:
        return 'Competition';
      case EventType.party:
        return 'Party';
      case EventType.ceremony:
        return 'Ceremony';
      case EventType.conference:
        return 'Conference';
      case EventType.lecture:
        return 'Lecture';
      case EventType.meeting:
        return 'Meeting';
      case EventType.workshop:
        return 'Workshop';
      case EventType.exhibit:
        return 'Exhibit';
    }
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

  EventType _parseEventType(String? eventTypeString) {
    if (eventTypeString != null) {
      eventTypeString = eventTypeString.toLowerCase();

      switch (eventTypeString) {
        case 'academic':
          return EventType.academic;
        case 'entertainment':
          return EventType.entertainment;
        case 'faire':
          return EventType.faire;
        case 'athletics':
          return EventType.athletics;
        case 'competition':
          return EventType.competition;
        case 'party':
          return EventType.party;
        case 'ceremony':
          return EventType.ceremony;
        case 'conference':
          return EventType.conference;
        case 'lecture':
          return EventType.lecture;
        case 'meeting':
          return EventType.meeting;
        case 'workshop':
          return EventType.workshop;
        case 'exhibit':
          return EventType.exhibit;
      }
    }

    return EventType.academic;
  }
}
