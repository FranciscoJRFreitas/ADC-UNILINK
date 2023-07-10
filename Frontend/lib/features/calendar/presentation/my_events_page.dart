import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:unilink2023/application/loadLocations.dart';
import 'package:unilink2023/constants.dart';
import 'package:unilink2023/features/calendar/domain/Event.dart';
import 'package:unilink2023/features/calendar/presentation/event_details.dart';
import 'package:unilink2023/features/navigation/main_screen_page.dart';
import 'package:unilink2023/widgets/LineComboBox.dart';
import 'package:unilink2023/widgets/LineDateTimeField.dart';
import 'package:unilink2023/widgets/LineTextField.dart';
import 'package:unilink2023/widgets/LocationPopUp.dart';

class MyEventsPage extends StatefulWidget {
  final String username;

  MyEventsPage({required this.username});

  @override
  _MyEventsPageState createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage>
    with SingleTickerProviderStateMixin {
  late List<Event> personalEvents = [];
  late List<Event> personalFilteredEvents = [];
  late List<Event> groupEvents = [];
  late DatabaseReference myEventsRef;
  List<EventType> eventTypes = EventType.values;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController startController = TextEditingController();
  final TextEditingController endController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  String _selectedEventType = 'Academic';
  LatLng? _selectedLocation = null;
  String selectLocationText = "Select Location";
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    myEventsRef = FirebaseDatabase.instance
        .ref()
        .child('schedule')
        .child(widget.username);
    getEvents();
    getUserEvents();
    _tabController = TabController(length: 2, vsync: this);
  }

  void dispose() {
    super.dispose();
    _tabController?.dispose();
  }

  void getEvents() {
    myEventsRef.onChildAdded.listen((event) {
      Event ev = Event.fromSnapshot(event.snapshot);
      setState(() {
        personalEvents.add(ev);
        personalEvents.sort((a, b) => a.startTime.compareTo(b.startTime));
      });
    });

    myEventsRef.onChildRemoved.listen((event) {
      String eventId = event.snapshot.key as String;

      setState(() {
        personalEvents.removeWhere((event) => event.id == eventId);
        personalEvents.sort((a, b) => a.startTime.compareTo(b.startTime));
      });
    });

    myEventsRef.onChildChanged.listen((event) {
      String eventId = event.snapshot.key as String;

      setState(() {
        Event ev = Event.fromSnapshot(event.snapshot);
        personalEvents.removeWhere((element) => element.id == eventId);
        personalEvents.add(ev);
        personalEvents.sort((a, b) => a.startTime.compareTo(b.startTime));
      });
    });
  }

  void getUserEvents() async {
    List<String> groups = [];
    DatabaseReference chatRef = await FirebaseDatabase.instance
        .ref()
        .child('chat')
        .child(widget.username)
        .child('Groups');

    await chatRef.once().then((event) {
      Map<dynamic, dynamic> newgroup =
          event.snapshot.value as Map<dynamic, dynamic>;
      newgroup.forEach((key, value) {
        setState(() {
          groups.add(key);
        });
      });
    });

    for (String groupId in groups) {
      DatabaseReference eventsRef =
          await FirebaseDatabase.instance.ref().child('events').child(groupId);

      await eventsRef.once().then((userDataSnapshot) {
        if (userDataSnapshot.snapshot.value != null) {
          Map<dynamic, dynamic> newevents =
              userDataSnapshot.snapshot.value as Map<dynamic, dynamic>;

          newevents.forEach((key, value) {
            Map<dynamic, dynamic> currEvent = value as Map<dynamic, dynamic>;
            Event currentEvent = Event(
                type: _parseEventType(currEvent["type"]),
                title: currEvent["title"],
                description: currEvent['description'],
                location: currEvent['location'],
                groupId: groupId,
                startTime: DateTime.parse(currEvent["startTime"]),
                endTime: DateTime.parse(currEvent["endTime"]));

            groupEvents.add(currentEvent);
          });
          groupEvents.sort((a, b) => a.startTime.compareTo(b.startTime));
        }
      });
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return kIsWeb ? _buildWebLayout(context) : _buildMobileLayout(context);
  }

  Widget _buildWebLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width / 2 - 0.5,
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                _buildSectionHeader("Personal Events", context, false,
                    MediaQuery.of(context).size.width / 2 - 0.5),
                personalEvents.isEmpty
                    ? Expanded(child: noEventWidget())
                    : Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: TextField(
                                  controller: searchController,
                                  onChanged: (query) {
                                    filterGroups(query);
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Search',
                                    labelStyle: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .secondaryHeaderColor),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: Theme.of(context)
                                          .secondaryHeaderColor,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                              ),
                              _eventsWidget(context),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),
          Container(
              width: MediaQuery.of(context).size.width / 2 - 0.5,
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  _buildSectionHeader("Group Events", context, false,
                      MediaQuery.of(context).size.width / 2 - 0.5),
                  groupEvents.isEmpty
                      ? Expanded(child: noEventWidget())
                      : Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: TextField(
                                    controller: searchController,
                                    onChanged: (query) {
                                      filterGroups(query);
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Search',
                                      labelStyle: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor),
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                  ),
                                ),
                                _groupEventWidget(context),
                              ],
                            ),
                          ),
                        ),
                ],
              )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _createEventPopUpDialog(context);
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
        elevation: 6,
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            child: TabBar(
              controller: _tabController,
              dividerColor: Style.lightBlue,
              indicatorColor: Style.lightBlue,
              labelStyle: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Theme.of(context).secondaryHeaderColor),
              labelColor: Theme.of(context).secondaryHeaderColor,
              overlayColor: MaterialStateProperty.all(
                Theme.of(context)
                    .scaffoldBackgroundColor
                    .withRed(Theme.of(context).scaffoldBackgroundColor.red - 20)
                    .withBlue(
                        Theme.of(context).scaffoldBackgroundColor.blue - 20)
                    .withGreen(
                        Theme.of(context).scaffoldBackgroundColor.green - 20),
              ),
              tabs: [
                Tab(
                  icon: Icon(Icons.event, color: Style.lightBlue),
                ),
                Tab(
                  icon: Icon(Icons.event_note_outlined, color: Style.lightBlue),
                ),
              ],
            ),
          ),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Builder(
                builder: (BuildContext context) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  _buildSectionHeader(
                                    "Personal Events",
                                    context,
                                    false,
                                    MediaQuery.of(context).size.width,
                                  ),
                                  if (personalEvents.isEmpty)
                                    Container(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              2,
                                      child: Center(child: noEventWidget()),
                                    )
                                  else
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: TextField(
                                        controller: searchController,
                                        onChanged: (query) {
                                          filterGroups(query);
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'Search',
                                          labelStyle: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .secondaryHeaderColor),
                                          prefixIcon: Icon(
                                            Icons.search,
                                            color: Theme.of(context)
                                                .secondaryHeaderColor,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  _eventsWidget(context),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  _buildSectionHeader(
                                    "Group Events",
                                    context,
                                    false,
                                    MediaQuery.of(context).size.width,
                                  ),
                                  if (groupEvents.isEmpty)
                                    Container(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              2,
                                      child: Center(child: noEventWidget()),
                                    )
                                  else
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: TextField(
                                        controller: searchController,
                                        onChanged: (query) {
                                          filterGroups(query);
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'Search',
                                          labelStyle: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor),
                                          prefixIcon: Icon(
                                            Icons.search,
                                            color: Theme.of(context)
                                                .secondaryHeaderColor,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(10.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                    _groupEventWidget(context),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Your members code here
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _createEventPopUpDialog(context);
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
        elevation: 6,
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _groupEventWidget(BuildContext context) {
    return Column(
      children: [
        ...groupEvents.map((event) => _buildEventTile(event, context)).toList(),
      ],
    );
  }

  Widget _eventsWidget(BuildContext context) {
    return Column(
      children: [
        ...personalEvents
            .map((event) => _buildEventTile(event, context))
            .toList(),
      ],
    );
  }

  Widget _buildSectionHeader(String groupId, BuildContext context,
      bool hasChatRedirect, double? size) {
    return Column(
      children: [
        SizedBox(height: 20),
        Row(
          children: [
            if (hasChatRedirect)
              Row(
                children: [
                  Text(
                    "  '$groupId' Events",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Tooltip(
                    message: 'Go to $groupId',
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MainScreen(
                                index: 6,
                                selectedGroup: groupId,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.chat,
                            color: Theme.of(context).secondaryHeaderColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            if (!hasChatRedirect)
              Text(
                '  $groupId',
                style: Theme.of(context).textTheme.titleMedium,
              ),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            width: size,
            child: Divider(
              thickness: 1,
              color: Style.lightBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventTile(Event event, BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: ListTile(
          title: Row(
            children: [
              getDateIcon(event, context),
              SizedBox(width: 10),
              InkWell(
                child: Text(
                  event.title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (event.location != "0") ...[
                SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MainScreen(
                                index: 10, location: event.location)));
                  },
                  child:
                      Icon(Icons.directions, size: 20, color: Style.lightBlue),
                ),
              ],
              if (event.groupId != null) ...[
                SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainScreen(
                          index: 6,
                          selectedGroup: event.groupId,
                        ),
                      ),
                    );
                  },
                  child: Icon(Icons.chat, size: 20, color: Style.lightBlue),
                ),
              ] else ...[
                SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return EventDetailsPage(event: event);
                        });
                  },
                  child: Icon(Icons.edit, size: 20, color: Style.lightBlue),
                ),
                SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    _removeEventPopUpDialogWeb(context, event);
                  },
                  child: Icon(Icons.delete_forever,
                      size: 20, color: Style.lightBlue),
                ),
              ],
              // SizedBox(width: 30),
              // getDateIcon(event, context),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.type_specimen, size: 20, color: Style.lightBlue),
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
                        style: Theme.of(context).textTheme.bodyMedium,
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
                  Icon(Icons.description, size: 20, color: Style.lightBlue),
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
                      style: Theme.of(context).textTheme.bodyMedium,
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
                    Icon(Icons.place, size: 20, color: Style.lightBlue),
                    SizedBox(width: 5),
                    Text(
                      'Location: ',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
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
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : Text(
                                    snapshot.data!,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
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
                  Icon(Icons.schedule, size: 20, color: Style.lightBlue),
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
                  Icon(Icons.schedule, size: 20, color: Style.lightBlue),
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
                      style: Theme.of(context).textTheme.bodyMedium,
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
    );
  }

  Widget getDateIcon(Event event, BuildContext context) {
    DateTime currentDate = DateTime.now();
    DateTime startDate = event.startTime;
    DateTime endDate = event.endTime;

    int prev = currentDate.difference(startDate).inMilliseconds;
    int after = endDate.difference(currentDate).inMilliseconds;

    return prev > 0
        ? after > 0
            ? Tooltip(
                message: 'Ongoing Event',
                child: MouseRegion(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.hourglass_top,
                      color: Colors.yellow,
                    ),
                  ),
                ),
              )
            : Tooltip(
                message: 'Past Event',
                child: MouseRegion(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                    ),
                  ),
                ),
              )
        : Tooltip(
            message: 'Upcoming Event',
            child: MouseRegion(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.more_time, color: Colors.blueGrey)),
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

  noEventWidget() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  _createEventPopUpDialog(context);
                },
                child: Icon(
                  Icons.hourglass_empty,
                  color: Colors.grey[700],
                  size: 75,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "You don´t have any events scheduled!",
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  _createEventPopUpDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: ((context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).canvasColor,
              title: const Text(
                "Add an event",
                textAlign: TextAlign.left,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LineComboBox(
                    selectedValue: _selectedEventType,
                    items:
                        eventTypes.map((e) => _getEventTypeString(e)).toList(),
                    icon: Icons.type_specimen,
                    onChanged: (dynamic newValue) {
                      setState(() {
                        _selectedEventType = newValue;
                      });
                    },
                  ),
                  LineTextField(
                    icon: Icons.title,
                    lableText: 'Title *',
                    controller: titleController,
                    title: "",
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  LineTextField(
                    icon: Icons.description,
                    lableText: "Description",
                    controller: descriptionController,
                    title: "",
                  ),
                  LineComboBox(
                    deleteIcon: Icons.clear,
                    onPressed: () {
                      setState(() {
                        selectLocationText = "Select Location";
                        _selectedLocation = null;
                      });
                    },
                    selectedValue: selectLocationText,
                    items: [selectLocationText, "From FCT place", "From maps"],
                    icon: Icons.place,
                    onChanged: (newValue) async {
                      if (newValue == "From FCT place" ||
                          newValue == "From maps") {
                        LatLng? selectedLocation = await showDialog<LatLng>(
                          context: context,
                          builder: (context) => EventLocationPopUp(
                            context: context,
                            isMapSelected: newValue == "From maps",
                            location: _selectedLocation,
                          ),
                        );
                        if (selectedLocation != null) {
                          setState(() {
                            selectLocationText = "1 Location Selected";
                            _selectedLocation = selectedLocation;
                          });
                        }
                      }
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  LineDateTimeField(
                    icon: Icons.schedule,
                    controller: startController,
                    hintText: "Start Time *",
                    firstDate: DateTime.now().subtract(Duration(days: 30)),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  LineDateTimeField(
                    icon: Icons.schedule,
                    controller: endController,
                    hintText: "End Time *",
                    firstDate: DateTime.now().subtract(Duration(days: 30)),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    {
                      DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');
                      bool isNull = _selectedLocation == null;
                      _createPersonalEvent(Event(
                          creator: widget.username,
                          type: _parseEventType(_selectedEventType),
                          title: titleController.text,
                          description: descriptionController.text,
                          startTime: dateFormat.parse(startController.text),
                          endTime: dateFormat.parse(endController.text),
                          location: !isNull
                              ? "${_selectedLocation!.latitude},${_selectedLocation!.longitude}"
                              : '0'));
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor),
                  child: const Text("CREATE"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    titleController.clear();
                    descriptionController.clear();
                    startController.clear();
                    endController.clear();
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor),
                  child: const Text("CANCEL"),
                ),
              ],
            );
          }));
        });
  }

  void _createPersonalEvent(Event event) {
    DatabaseReference eventsRef = FirebaseDatabase.instance
        .ref()
        .child('schedule')
        .child(widget.username)
        .push();

    // Generate a new ID for the event
    String? eventId = eventsRef.key;
    Map<String, dynamic> eventMap = event.toJson();
    eventMap.addAll({'id': eventId});

    // Add the event to the database
    eventsRef.set(eventMap).then((_) {
      titleController.clear();
      descriptionController.clear();
      startController.clear();
      endController.clear();
      _selectedLocation = null;
      _showErrorSnackbar('Personal event added successfully!', false);
    }).catchError((error) {
      _showErrorSnackbar(
          'There was an error while adding this personal event!', true);
    });
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

  _removeEventPopUpDialogWeb(BuildContext context, Event e) {
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
                        deleteEvent(e);
                        Future.delayed(Duration(milliseconds: 100), () {
                          Navigator.pop(context);
                        });
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

  void deleteEvent(Event e) async {
    DatabaseReference eventsRef = FirebaseDatabase.instance
        .ref()
        .child('schedule')
        .child(widget.username)
        .child(e.id!);
    await eventsRef.remove();
  }

  void filterGroups(String query) {
    setState(() {
      if (query.isEmpty) {
        personalFilteredEvents =
            personalEvents; // Reset to all groups if query is empty
      } else {
        personalFilteredEvents = personalEvents.where((event) {
          final title = event.title.toLowerCase();
          final description = event.description.toLowerCase();
          final searchLower = query.toLowerCase();

          return query.isNotEmpty &&
              (isMatch(title, searchLower) ||
                  isMatch(description, searchLower) ||
                  title.contains(searchLower) ||
                  description.contains(searchLower));
        }).toList();
      }
    });
  }

  /*Levenshtein algorithm*/
  bool isMatch(String text, String query) {
    if (text == query) {
      return true; // Exact match
    }

    if ((text.length - query.length).abs() > 2) {
      return false; // Length difference exceeds tolerance
    }

    for (int i = 0; i < text.length; i++) {
      int differences = levenshteinDistance(text.substring(i), query);
      if (differences <= 2) {
        return true; // Match found within tolerance
      }
    }

    return false; // No match found
  }

  int levenshteinDistance(String text, String query) {
    if (text.isEmpty) {
      return query.length;
    }
    if (query.isEmpty) {
      return text.length;
    }

    List<int> previousRow = List<int>.filled(query.length + 1, 0);
    List<int> currentRow = List<int>.filled(query.length + 1, 0);

    for (int i = 0; i <= query.length; i++) {
      previousRow[i] = i;
    }

    for (int i = 0; i < text.length; i++) {
      currentRow[0] = i + 1;

      for (int j = 0; j < query.length; j++) {
        int insertions = previousRow[j + 1] + 1;
        int deletions = currentRow[j] + 1;
        int substitutions = previousRow[j] + (text[i] != query[j] ? 1 : 0);

        currentRow[j + 1] = min(insertions, min(deletions, substitutions));
      }

      List<int> tempRow = previousRow;
      previousRow = currentRow;
      currentRow = tempRow;
    }

    return previousRow[query.length];
  }
}
