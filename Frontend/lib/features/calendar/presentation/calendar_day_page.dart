import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unilink2023/features/calendar/application/event_utils.dart';
import '../../../application/loadLocations.dart';
import '../../../constants.dart';
import '../../../data/cache_factory_provider.dart';
import '../../navigation/main_screen_page.dart';
import '../domain/Event.dart';
import 'calendar_page.dart';

class DayCalendarPage extends StatefulWidget {
  final String username;
  final DateTime date;

  DayCalendarPage({required this.username, required this.date});

  @override
  _DayCalendarPageState createState() => _DayCalendarPageState();
}

class _DayCalendarPageState extends State<DayCalendarPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController startController = TextEditingController();
  final TextEditingController endController = TextEditingController();
  List<dynamic> schedule = [];
  Map<DateTime, List<Event>> events = {};
  DateFormat customFormat = DateFormat("yyyy-MM-dd HH:mm:ss.SSS'Z'");
  PlatformFile file = PlatformFile(name: "", size: 0);
  String selectLocationText = "Select Location";

  @override
  void initState() {

    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    loadSchedule();
    getUserEvents();

  }

  @override
  void dispose() {
    super.dispose();
    _tabController?.dispose();
    titleController.dispose();
    descriptionController.dispose();
    startController.dispose();
    endController.dispose();
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

            DateTime startDate = DateTime(
              currentEvent.startTime.year,
              currentEvent.startTime.month,
              currentEvent.startTime.day,
            );
            DateTime endDate = DateTime(
              currentEvent.endTime.year,
              currentEvent.endTime.month,
              currentEvent.endTime.day,
            );

            DateTime widgetDate = DateTime(
              widget.date.year,
              widget.date.month,
              widget.date.day,
            );

// Iterate through each day from the start date to the end date
            for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
              DateTime currentDate = startDate.add(Duration(days: i));

              // Compare current date with widget.date
              if (currentDate.year == widgetDate.year &&
                  currentDate.month == widgetDate.month &&
                  currentDate.day == widgetDate.day) {
                String formattedCurrentDateTime =
                    customFormat.format(currentDate);
                DateTime parsedCurrentDateTime =
                    customFormat.parse(formattedCurrentDateTime, true);

                if (events.containsKey(parsedCurrentDateTime)) {
                  events[parsedCurrentDateTime]!.add(currentEvent);
                } else {
                  events[parsedCurrentDateTime] = [currentEvent];
                }
              }
            }
          });
        }
      });
    }

    _getPersonalEvents();
    setState(() {});
  }

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      file = result.files.single;
    } else {
      print("picker canceled");
    }
  }

  void uploadSchedule() async {
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('Schedules/' + await cacheFactory.get('users', 'username'));

    await storageReference.putData(file.bytes!);
  }

  void _getPersonalEvents() async {
    DatabaseReference eventsRef = await FirebaseDatabase.instance
        .ref()
        .child('schedule')
        .child(widget.username);

    eventsRef.onChildAdded.listen((event) async {
      setState(() {
        Map<dynamic, dynamic> currEvent =
            event.snapshot.value as Map<dynamic, dynamic>;

        Event currentEvent = Event(
          type: parseEventType(currEvent["type"]),
          title: currEvent["title"],
          description: currEvent['description'],
          location: currEvent['location'],
          startTime: DateTime.parse(currEvent["startTime"]),
          endTime: DateTime.parse(currEvent["endTime"]),
        );

        // Update events array with the new event
        DateTime startDate = DateTime(
          currentEvent.startTime.year,
          currentEvent.startTime.month,
          currentEvent.startTime.day,
        );
        DateTime endDate = DateTime(
          currentEvent.endTime.year,
          currentEvent.endTime.month,
          currentEvent.endTime.day,
        );

        DateTime widgetDate = DateTime(
          widget.date.year,
          widget.date.month,
          widget.date.day,
        );

// Iterate through each day from the start date to the end date
        for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
          DateTime currentDate = startDate.add(Duration(days: i));

          // Compare current date with widget.date
          if (currentDate.year == widgetDate.year &&
              currentDate.month == widgetDate.month &&
              currentDate.day == widgetDate.day) {
            String formattedCurrentDateTime = customFormat.format(currentDate);
            DateTime parsedCurrentDateTime =
                customFormat.parse(formattedCurrentDateTime, true);

            if (events.containsKey(parsedCurrentDateTime)) {
              events[parsedCurrentDateTime]!.add(currentEvent);
            } else {
              events[parsedCurrentDateTime] = [currentEvent];
            }
          }
        }
      });
    });
    setState(() {

    });
  }

  Future<void> loadSchedule() async {
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('Schedules/' + await cacheFactory.get('users', 'username'));

    Uint8List? scheduleFile = await storageReference.getData();

    if (scheduleFile != null) {
      String jsonString = utf8.decode(scheduleFile);
      setState(() {
        schedule = jsonDecode(jsonString)['schedule'];
      });
    } else {
      print('Failed to download schedule file.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).secondaryHeaderColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        elevation: 0,
        title: Text(
          "${DateFormat('dd/MM/yyyy').format(widget.date)}",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        actions: <Widget>[
          IconButton(
            icon: Tooltip(
              message: "Go to Calendar",
              child: Icon(Icons.calendar_month_outlined,
                  color: Theme.of(context).secondaryHeaderColor),
            ), // set your preferred icon here
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MainScreen(index: 9, date: DateTime.now()),
                ),
              );
            },
          ),
        ],
      ),
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
                  icon: Icon(Icons.schedule, color: Style.lightBlue),
                ),
                Tab(
                  icon: Icon(Icons.person, color: Style.lightBlue),
                ),
                Tab(
                  icon: Icon(Icons.group, color: Style.lightBlue),
                ),
              ],
            ),
          ),
          Expanded(
            child: DefaultTabController(
              length: 3,
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
                                    "Schedule",
                                    context,
                                    false,
                                    MediaQuery.of(context).size.width,
                                  ),
                                  if(schedule.isEmpty)
                                    noEventWidget(false),
                                  ..._scheduleWidget(context),
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
                                    "Personal Events",
                                    context,
                                    false,
                                    MediaQuery.of(context).size.width,
                                  ),
                                  _personalEventsWidget(context),
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
                                  _groupEventsWidget(context),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }

    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<Widget> _scheduleWidget(BuildContext context) {
    return schedule.map<Widget>((daySchedule) {
      if (daySchedule['day'] == getDayOfWeek(widget.date)) {
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: daySchedule['classes'].length + 3,
          itemBuilder: (context, index) {
            if (index == 0) {
              return SizedBox(height: 20);
            } else if (index == 1) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '  Schedule',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              );
            } else if (index == 2) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 300,
                  child: Divider(
                    thickness: 1,
                    color: Style.lightBlue,
                  ),
                ),
              );
            } else {
              var classData = daySchedule['classes'][index - 3];
              return ListTile(
                title: Text(
                  classData['name'],
                ),
                subtitle: Text(
                  '${classData['startTime']} - ${classData['endTime']}',
                ),
              );
            }
          },
        );
      } else {
        return Container();
      }
    }).toList();
  }

  Widget _personalEventsWidget(BuildContext context) {
    List<Event> personalEvents = [];

    events[widget.date]?.forEach((event) {
      if (event.groupId == null) {
        personalEvents.add(event);
      }
    });

    return personalEvents.isEmpty ? noEventWidget(false) : ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: personalEvents.length,
      itemBuilder: (context, index) {
        return _buildEventTile(personalEvents[index], context);
      },
    );
  }

  Widget _groupEventsWidget(BuildContext context) {
    Map<String, List<Event>> groupEvents = {};
    events[widget.date]?.forEach((event) {
      if (event.groupId != null) {
        if (!groupEvents.containsKey(event.groupId)) {
          groupEvents[event.groupId!] = [];
        }
        groupEvents[event.groupId]!.add(event);
      }
    });

    return groupEvents.isEmpty ? noEventWidget(false) : ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: groupEvents.length,
      itemBuilder: (context, index) {
        String groupId = groupEvents.keys.elementAt(index);
        return Column(
          children: groupEvents[groupId]!
              .map((event) => _buildEventTile(event, context))
              .toList(),
        );
      },
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
                                        index: 10, location: event.location)));
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
                          child: Tooltip(
                            message: "View Group Chat",
                            child: Icon(Icons.chat,
                                size: 20, color: Style.lightBlue),
                          ),
                        ),
                      ],
                    ],
                  ))
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
                    Row(
                      children: [
                        Text(
                          'Group: ',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(fontSize: 14),
                        ),
                        Text(
                          event.groupId!,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
  noEventWidget(bool isGroupEvents) {
    return Center(
      child: Container(
        height:
        MediaQuery.of(context).size.height /
            2,
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {

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
}
