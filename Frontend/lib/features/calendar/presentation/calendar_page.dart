import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:unilink2023/features/calendar/domain/Event.dart';
import 'package:unilink2023/features/calendar/presentation/calendar_day_page.dart';
import 'package:unilink2023/widgets/LineComboBox.dart';
import 'package:unilink2023/widgets/LineDateTimeField.dart';
import 'package:unilink2023/widgets/LineTextField.dart';
import '../../../application/loadLocations.dart';
import '../../../constants.dart';
import '../../../data/cache_factory_provider.dart';
import '../../../widgets/LocationPopUp.dart';
import '../../chat/presentation/chat_info_page.dart';
import '../../navigation/main_screen_page.dart';
import 'event_details.dart';

class CalendarPage extends StatefulWidget {
  final String username;
  final DateTime date;

  CalendarPage({required this.username, required this.date});

  @override
  _CalendarPageState createState() => _CalendarPageState(date);
}

class _CalendarPageState extends State<CalendarPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController startController = TextEditingController();
  final TextEditingController endController = TextEditingController();
  List<EventType> eventTypes = EventType.values;
  List<dynamic> schedule = [];
  CalendarFormat format = CalendarFormat.week;
  DateFormat customFormat = DateFormat("yyyy-MM-dd HH:mm:ss.SSS'Z'");
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  _CalendarPageState(date) {
    selectedDay = DateTime(date.year, date.month, date.day);
    focusedDay = date;
  }

  Map<DateTime, List<Event>> events = {};
  String _selectedEventType = 'Academic';
  LatLng? _selectedLocation = null;
  String selectLocationText = "Select Location";
  PlatformFile file = PlatformFile(name: "", size: 0);

  @override
  void initState() {
    super.initState();
    String formattedSelectedDateTime = customFormat.format(selectedDay);
    selectedDay = customFormat.parse(formattedSelectedDateTime, true);
    loadSchedule();
    getUserEvents();
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

            for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
              DateTime currentDate = startDate.add(Duration(days: i));
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
        print("SNAPSHOT: " + event.snapshot.value.toString());
        Event currentEvent = Event(
          type: _parseEventType(currEvent["type"]),
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

        for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
          DateTime currentDate = startDate.add(Duration(days: i));
          String formattedCurrentDateTime = customFormat.format(currentDate);

          DateTime parsedCurrentDateTime =
              customFormat.parse(formattedCurrentDateTime, true);

          if (events.containsKey(parsedCurrentDateTime)) {
            events[parsedCurrentDateTime]!.add(currentEvent);
          } else {
            events[parsedCurrentDateTime] = [currentEvent];
          }
        }
      });
    });
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
    return kIsWeb ? _buildWebLayout() : _buildTableCalendarMobile(context);
  }

  Widget _buildWebLayout() {
    return Scaffold(
      body: format == CalendarFormat.month
          ? SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTableCalendarWeb(context),
                  _buildThreeColumns(),
                ],
              ),
            )
          : Column(
              children: [
                _buildTableCalendarWeb(context),
                Expanded(child: _buildThreeColumns()),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Create a Personal Event",
        onPressed: () {
          if (kIsWeb)
            _createEventPopUpDialogWeb(context);
          else
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

  Widget _buildThreeColumns() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            width: MediaQuery.of(context).size.width / 3 - 20.0,
            child: Column(
              children: [
                _buildSectionHeader("Schedule", context, false,
                    MediaQuery.of(context).size.width / 3 - 20.0),
                Container(
                  height: format == CalendarFormat.month
                      ? 200
                      : format == CalendarFormat.twoWeeks
                          ? MediaQuery.of(context).size.height * 0.57
                          : MediaQuery.of(context).size.height * 0.64,
                  child: SingleChildScrollView(
                    child: Column(
                      children: _scheduleWidget(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            width: MediaQuery.of(context).size.width / 3 - 20.0,
            child: Column(
              children: [
                _buildSectionHeader("Personal Events", context, false,
                    MediaQuery.of(context).size.width / 3 - 20.0),
                Container(
                  height: format == CalendarFormat.month
                      ? 200
                      : format == CalendarFormat.twoWeeks
                          ? MediaQuery.of(context).size.height * 0.57
                          : MediaQuery.of(context).size.height * 0.64,
                  child: SingleChildScrollView(
                    child: Column(children: [
                      _personalEventsWidget(context),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            width: MediaQuery.of(context).size.width / 3 - 20.0,
            child: Column(
              children: [
                _buildSectionHeader("Group Events", context, false,
                    MediaQuery.of(context).size.width / 3 - 20.0),
                Container(
                  height: format == CalendarFormat.month
                      ? 200
                      : format == CalendarFormat.twoWeeks
                          ? MediaQuery.of(context).size.height * 0.55
                          : MediaQuery.of(context).size.height * 0.62,
                  child: SingleChildScrollView(
                    child: Column(children: [
                      _groupEventsWidget(context),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableCalendarWeb(BuildContext context) {
    return TableCalendar(
      availableCalendarFormats: const {
        CalendarFormat.month: 'Week',
        CalendarFormat.twoWeeks: 'Month',
        CalendarFormat.week: '2 Weeks',
      },
      firstDay: DateTime(2000, 1, 1),
      lastDay: DateTime(2030, 1, 1),
      focusedDay: focusedDay,
      calendarFormat: format,
      onFormatChanged: (CalendarFormat _format) {
        setState(() {
          format = _format;
        });
      },
      onDaySelected: (DateTime selectDay, DateTime focusDay) {
        setState(() {
          selectedDay = selectDay;
          focusedDay = selectDay;
        });
      },
      headerStyle: HeaderStyle(
        formatButtonVisible:
            true, // hides the format button, which is not needed here
        titleCentered: true,
      ),
      calendarStyle: CalendarStyle(
        // Other style properties...
        selectedDecoration: BoxDecoration(
          color: Colors.blue, // change to your desired color
          shape: BoxShape.circle,
        ),
      ),
      selectedDayPredicate: (day) {
        return isSameDay(selectedDay, day);
      },
      eventLoader: (day) {
        return events[day] ?? [];
      },
    );
  }

  Widget _buildTableCalendarMobile(BuildContext context) {
    return Scaffold(
      body: TableCalendar(
        availableCalendarFormats: const {
          CalendarFormat.month: 'Week',
        },
        firstDay: DateTime(2000, 1, 1),
        lastDay: DateTime(2030, 1, 1),
        focusedDay: focusedDay,
        calendarFormat: CalendarFormat.month,
        onDaySelected: (DateTime selectDay, DateTime focusDay) {
          setState(() {
            selectedDay = selectDay;
            focusedDay = selectDay;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DayCalendarPage(username: widget.username, date: selectDay),
            ),
          );
        },
        headerStyle: HeaderStyle(
          formatButtonVisible:
              true, // hides the format button, which is not needed here
          titleCentered: true,
        ),
        calendarStyle: CalendarStyle(
          // Other style properties...
          selectedDecoration: BoxDecoration(
            color: Colors.blue, // change to your desired color
            shape: BoxShape.circle,
          ),
        ),
        selectedDayPredicate: (day) {
          return isSameDay(selectedDay, day);
        },
        eventLoader: (day) {
          return events[day] ?? [];
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Create a Personal Event",
        onPressed: () {
          if (kIsWeb)
            _createEventPopUpDialogWeb(context);
          else
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

  List<Widget> _scheduleWidget(BuildContext context) {
    return schedule.map<Widget>((daySchedule) {
      if (daySchedule['day'] == getDayOfWeek(selectedDay)) {
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
    events[selectedDay]?.forEach((event) {
      if (event.groupId == null) {
        personalEvents.add(event);
      }
    });

    return ListView.builder(
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
    events[selectedDay]?.forEach((event) {
      if (event.groupId != null) {
        if (!groupEvents.containsKey(event.groupId)) {
          groupEvents[event.groupId!] = [];
        }
        groupEvents[event.groupId]!.add(event);
      }
    });

    return ListView.builder(
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

  Widget buttonAddCalendar(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor, // button's fill color
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      icon: Icon(Icons.add),
      label: Text('Create Groups from a file'),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Create Groups'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    child: Text('Pick a file'),
                    onPressed: () {
                      pickFile();
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text('Create'),
                  onPressed: () {
                    uploadSchedule();
                    Navigator.of(context).pop();
                    // Process your file here
                  },
                ),
              ],
            );
          },
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

  _createEventPopUpDialogWeb(BuildContext context) {
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
                      print("CLOSING");
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
                    SizedBox(
                        height: 40), // Add extra space at top for close button
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
                                    type: _parseEventType(_selectedEventType),
                                    title: titleController.text,
                                    description: descriptionController.text,
                                    startTime:
                                        dateFormat.parse(startController.text),
                                    endTime:
                                        dateFormat.parse(endController.text),
                                    location: !isNull
                                        ? "${_selectedLocation!.latitude},${_selectedLocation!.longitude}"
                                        : '0'));
                                Navigator.of(context).pop();
                                titleController.clear();
                                descriptionController.clear();
                                startController.clear();
                                endController.clear();
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

  List<String> _formatDateTime(DateTime dateTime1, DateTime dateTime2) {
    if (dateTime1.day != dateTime2.day ||
        dateTime1.month != dateTime2.month ||
        dateTime1.year != dateTime2.year) {
      return [
        DateFormat('HH:mm of yyyy-MM-dd').format(dateTime1),
        DateFormat('HH:mm of yyyy-MM-dd').format(dateTime2)
      ];
    } else {
      return [
        DateFormat('HH:mm').format(dateTime1),
        DateFormat('HH:mm').format(dateTime2)
      ];
    }
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
}

String getDayOfWeek(DateTime date) {
  switch (date.weekday) {
    case 1:
      return 'Monday';
    case 2:
      return 'Tuesday';
    case 3:
      return 'Wednesday';
    case 4:
      return 'Thursday';
    case 5:
      return 'Friday';
    case 6:
      return 'Saturday';
    case 7:
      return 'Sunday';
    default:
      return '';
  }
}

String getEventTypeString(EventType eventType) {
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
