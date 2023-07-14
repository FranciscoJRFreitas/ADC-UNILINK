import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:unilink2023/application/loadLocations.dart';
import 'package:unilink2023/constants.dart';
import 'package:unilink2023/features/calendar/application/event_utils.dart';
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
  late List<Event> groupFilteredEvents = [];

  late DatabaseReference myEventsRef;
  List<EventType> eventTypes = EventType.values;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController startController = TextEditingController();
  final TextEditingController endController = TextEditingController();
  final TextEditingController searchPersonalController =
      TextEditingController();
  final TextEditingController searchGroupsController = TextEditingController();

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

  @override
  void dispose() {
    super.dispose();
    _tabController?.dispose();
    searchPersonalController.dispose();
    searchGroupsController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    startController.dispose();
    endController.dispose();
  }

  void getEvents() {
    myEventsRef.onChildAdded.listen((event) {
      Event ev = Event.fromSnapshot(event.snapshot);
      setState(() {
        personalEvents.add(ev);
        personalFilteredEvents.add(ev);
      });
    });

    myEventsRef.onChildRemoved.listen((event) {
      String eventId = event.snapshot.key as String;

      setState(() {
        personalFilteredEvents.removeWhere((element) => element.id == eventId);
        personalEvents.removeWhere((event) => event.id == eventId);
      });
    });

    myEventsRef.onChildChanged.listen((event) {
      String eventId = event.snapshot.key as String;

      setState(() {
        Event ev = Event.fromSnapshot(event.snapshot);
        personalEvents.removeWhere((element) => element.id == eventId);
        personalFilteredEvents.removeWhere((element) => element.id == eventId);
        personalFilteredEvents.add(ev);
        personalEvents.add(ev);
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
                type: parseEventType(currEvent["type"]),
                title: currEvent["title"],
                description: currEvent['description'],
                location: currEvent['location'],
                groupId: groupId,
                startTime: DateTime.parse(currEvent["startTime"]),
                endTime: DateTime.parse(currEvent["endTime"]));

            groupEvents.add(currentEvent);
            groupFilteredEvents.add(currentEvent);
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
    personalFilteredEvents.sort((a, b) => a.startTime.compareTo(b.startTime));
    groupFilteredEvents.sort((a, b) => a.startTime.compareTo(b.startTime));
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
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchPersonalController,
                    onChanged: (query) {
                      filterGroups(query);
                    },
                    decoration: InputDecoration(
                      labelText: 'Search',
                      hintText:
                          'You can search for titles, types and descriptions!',
                      hintStyle: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(
                              color: Theme.of(context).secondaryHeaderColor),
                      labelStyle: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(
                              color: Theme.of(context).secondaryHeaderColor),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                personalFilteredEvents.isEmpty
                    ? Expanded(
                        child: searchPersonalController.text.trim().isEmpty
                            ? noEventWidget(false)
                            : noSearchResult())
                    : Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
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
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: TextField(
                      controller: searchGroupsController,
                      onChanged: (query) {
                        filterGroupsEvents(query);
                      },
                      decoration: InputDecoration(
                        labelText: 'Search',
                        hintText:
                            'You can search for titles, groups, types and descriptions!',
                        hintStyle: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(
                                color: Theme.of(context).secondaryHeaderColor),
                        labelStyle: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(
                                color: Theme.of(context).secondaryHeaderColor),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Theme.of(context).secondaryHeaderColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  groupEvents.isEmpty
                      ? Expanded(
                          child: searchGroupsController.text.trim().isEmpty
                              ? noEventWidget(true)
                              : noSearchResult())
                      : Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
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
        tooltip: "Create a Personal Event",
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
    personalFilteredEvents.sort((a, b) => a.startTime.compareTo(b.startTime));
    groupFilteredEvents.sort((a, b) => a.startTime.compareTo(b.startTime));
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
                                  if (personalFilteredEvents.isEmpty) ...[
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: TextField(
                                        controller: searchPersonalController,
                                        onChanged: (query) {
                                          filterGroups(query);
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'Search',
                                          hintText:
                                              'You can search for titles, types and descriptions!',
                                          hintStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!,
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
                                    Container(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              2,
                                      child: Center(
                                          child: searchPersonalController.text
                                                  .trim()
                                                  .isEmpty
                                              ? noEventWidget(false)
                                              : noSearchResult()),
                                    )
                                  ] else
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: TextField(
                                        controller: searchPersonalController,
                                        onChanged: (query) {
                                          filterGroups(query);
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'Search',
                                          hintText:
                                              'You can search for titles, types and descriptions!',
                                          hintStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!,
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
                                  if (groupEvents.isEmpty) ...[
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: TextField(
                                        controller: searchGroupsController,
                                        onChanged: (query) {
                                          filterGroupsEvents(query);
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'Search',
                                          hintText:
                                              'You can search for titles, groups, types and descriptions!',
                                          hintStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!,
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
                                    Container(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              2,
                                      child: Center(
                                          child: searchGroupsController.text
                                                  .trim()
                                                  .isEmpty
                                              ? noEventWidget(true)
                                              : noSearchResult()),
                                    )
                                  ] else
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: TextField(
                                        controller: searchGroupsController,
                                        onChanged: (query) {
                                          filterGroupsEvents(query);
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'Search',
                                          hintText:
                                              'You can search for titles, groups, types and descriptions!',
                                          hintStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!,
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
        tooltip: "Create a Personal Event",
        onPressed: () {
          _createEventPopUpDialogMobile(context);
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

  noSearchResult() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              color: Colors.grey[700],
              size: 75,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "There were no search results...",
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  Widget _groupEventWidget(BuildContext context) {
    return Column(
      children: [
        if (groupFilteredEvents.isNotEmpty) ...[
          ...groupFilteredEvents
              .map((event) => _buildEventTile(event, context))
              .toList(),
        ],
        if (groupFilteredEvents.isEmpty)
          Center(
            child: searchGroupsController.text.trim().isEmpty
                ? Column()
                : noSearchResult(),
          ),
      ],
    );
  }

  Widget _eventsWidget(BuildContext context) {
    return Column(
      children: [
        ...personalFilteredEvents
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
                          child: Tooltip(
                            message: "Views Group Chat",
                            child: Icon(
                              Icons.chat,
                              color: Theme.of(context).secondaryHeaderColor,
                            ),
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
          title: Column(
            children: [
              Row(
                children: [
                  getDateIcon(event, context),
                  InkWell(
                    child: Text(
                      event.title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (event.location != "0") ...[
                          SizedBox(width: 10),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MainScreen(
                                    index: 10,
                                    location: event.location,
                                  ),
                                ),
                              );
                            },
                            child: Tooltip(
                              message: "View in Maps",
                              child: Icon(Icons.directions,
                                  size: 20, color: Style.lightBlue),
                            ),
                          ),
                        ],
                        SizedBox(width: 10),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MainScreen(index: 15),
                              ),
                            );
                          },
                          child: Tooltip(
                            message: "View in My Events",
                            child: Icon(Icons.event_note_rounded,
                                size: 20, color: Style.lightBlue),
                          ),
                        ),
                        if (event.groupId != null) ...[
                          SizedBox(width: 10),
                          FutureBuilder<String>(
                            future: fetchGroupDisplayName(event.groupId!),
                            builder: (BuildContext context,
                                AsyncSnapshot<String> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return SizedBox.shrink();
                              }
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }
                              if (snapshot.data != null) {
                                return InkWell(
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
                                  child: Tooltip(
                                    message: "View Group Chat",
                                    child: Icon(Icons.chat,
                                        size: 20, color: Style.lightBlue),
                                  ),
                                );
                              }
                              return SizedBox.shrink();
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                color: Style.lightBlue,
                thickness: 1,
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (event.groupId != null) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.group, size: 20, color: Style.lightBlue),
                    SizedBox(width: 5),
                    FutureBuilder<String>(
                      future: fetchGroupDisplayName(event.groupId!),
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        if (snapshot.data != null) {
                          return Row(
                            children: [
                              Text(
                                'Group: ',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(fontSize: 14),
                              ),
                              Text(
                                snapshot.data!,
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ],
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
                        getEventTypeString(event.type),
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
                        }
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        return Text(
                          snapshot.data ?? "Custom Location",
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
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

  Future<String> fetchGroupDisplayName(String groupId) async {
    DatabaseReference groupRef =
        FirebaseDatabase.instance.ref().child('groups').child(groupId);
    DataSnapshot snapshot = await groupRef
        .child('DisplayName')
        .once()
        .then((event) => event.snapshot);
    if (snapshot.value != null) {
      return snapshot.value.toString();
    } else {
      return 'Group Display Name not found';
    }
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

  noEventWidget(bool isGroupEvents) {
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
                  if (!isGroupEvents) _createEventPopUpDialog(context);
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
              "You don't have any events scheduled!",
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
                        eventTypes.map((e) => getEventTypeString(e)).toList(),
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
                    DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');
                    bool isNull = _selectedLocation == null;
                    _createPersonalEvent(Event(
                        creator: widget.username,
                        type: parseEventType(_selectedEventType),
                        title: titleController.text.trim(),
                        description: descriptionController.text.trim(),
                        startTime: dateFormat.parse(startController.text),
                        endTime: dateFormat.parse(endController.text),
                        location: !isNull
                            ? "${_selectedLocation!.latitude},${_selectedLocation!.longitude}"
                            : '0'));
                    Navigator.of(context).pop();
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
                    _selectedLocation = null;
                    selectLocationText = "Select Location";
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
          final type = getEventTypeString(event.type).toLowerCase();
          final searchLower = query.toLowerCase();

          return query.isNotEmpty &&
              (isMatch(title, searchLower) ||
                  isMatch(description, searchLower) ||
                  isMatch(type, searchLower) ||
                  title.contains(searchLower) ||
                  description.contains(searchLower) ||
                  type.contains(searchLower));
        }).toList();
      }
    });
  }

  void filterGroupsEvents(String query) {
    setState(() {
      if (query.isEmpty) {
        groupFilteredEvents =
            groupEvents; // Reset to all groups if query is empty
      } else {
        groupFilteredEvents = groupEvents.where((event) {
          final title = event.title.toLowerCase();
          final description = event.description.toLowerCase();
          final type = getEventTypeString(event.type);
          final groupId = event.groupId!;
          final searchLower = query.toLowerCase();

          return query.isNotEmpty &&
              (isMatch(title, searchLower) ||
                  isMatch(description, searchLower) ||
                  isMatch(type, searchLower) ||
                  isMatch(groupId, searchLower) ||
                  title.contains(searchLower) ||
                  description.contains(searchLower) ||
                  type.contains(searchLower) ||
                  groupId.contains(searchLower));
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

  void _createEventPopUpDialogMobile(BuildContext context) {
    LatLng? _selectedLocation = null;
    String selectLocationText = "Select Location";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Style.darkBlue,
      builder: (context) => StatefulBuilder(
        builder: ((context, setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SingleChildScrollView(
              child: Stack(children: [
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                      titleController.clear();
                      descriptionController.clear();
                      startController.clear();
                      endController.clear();
                    },
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 40),
                    // Add extra space at top for close button
                    const Text(
                      "Add an event",
                      textAlign: TextAlign.left,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LineComboBox(
                          selectedValue: _selectedEventType,
                          items: eventTypes
                              .map((e) => getEventTypeString(e))
                              .toList(),
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
                          items: [
                            selectLocationText,
                            "From FCT place",
                            "From maps"
                          ],
                          icon: Icons.place,
                          onChanged: (newValue) async {
                            if (newValue == "From FCT place" ||
                                newValue == "From maps") {
                              LatLng? selectedLocation =
                                  await showDialog<LatLng>(
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
                          firstDate:
                              DateTime.now().subtract(Duration(days: 30)),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        LineDateTimeField(
                          icon: Icons.schedule,
                          controller: endController,
                          hintText: "End Time *",
                          firstDate:
                              DateTime.now().subtract(Duration(days: 30)),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                DateFormat dateFormat =
                                    DateFormat('yyyy-MM-dd HH:mm');
                                bool isNull = _selectedLocation == null;
                                _createPersonalEvent(Event(
                                    creator: widget.username,
                                    type: parseEventType(_selectedEventType),
                                    title: titleController.text.trim(),
                                    description:
                                        descriptionController.text.trim(),
                                    startTime:
                                        dateFormat.parse(startController.text),
                                    endTime:
                                        dateFormat.parse(endController.text),
                                    location: !isNull
                                        ? "${_selectedLocation!.latitude},${_selectedLocation!.longitude}"
                                        : '0'));
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black87),
                              child: const Text("CREATE"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ]),
            ),
          );
        }),
      ),
    ).then((value) {
      // This code will run when the modal is dismissed
      titleController.clear();
      descriptionController.clear();
      startController.clear();
      endController.clear();
    });
  }
}
