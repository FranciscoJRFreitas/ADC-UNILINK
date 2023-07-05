import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:unilink2023/features/calendar/domain/Event.dart';
import 'package:unilink2023/widgets/LineComboBox.dart';
import 'package:unilink2023/widgets/LineDateTimeField.dart';
import 'package:unilink2023/widgets/LineTextField.dart';

import '../../../constants.dart';

class SchedulePage extends StatefulWidget {
  final String username;

  SchedulePage({required this.username});

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  List<dynamic> schedule = [];
  CalendarFormat format = CalendarFormat.week;
  //DateTime selectedDay = DateTime.now();
  DateFormat customFormat = DateFormat("yyyy-MM-dd HH:mm:ss.SSS'Z'");
  DateTime selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  DateTime focusedDay = DateTime.now();
  Map<DateTime, List<Event>> events = {};
  String _selectedEventType = 'Academic';

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

        if(userDataSnapshot.snapshot.value != null) {
          Map<dynamic, dynamic> newevents = userDataSnapshot.snapshot
              .value as Map<dynamic, dynamic>;

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

            for (int i = 0; i <= endDate
                .difference(startDate)
                .inDays; i++) {
              DateTime currentDate = startDate.add(Duration(days: i));
              String formattedCurrentDateTime = customFormat.format(
                  currentDate);

              DateTime parsedCurrentDateTime =
              customFormat.parse(formattedCurrentDateTime, true);

              if (events.containsKey(parsedCurrentDateTime)) {
                events[parsedCurrentDateTime]!.add(currentEvent);
              } else {
                events[parsedCurrentDateTime] = [currentEvent];
              }
            }
          });
        }});
    }

    _getPersonalEvents();
    setState(() {});
  }

   void _getPersonalEvents() async {

    DatabaseReference eventsRef = await FirebaseDatabase.instance
        .ref()
        .child('schedule')
        .child(widget.username);

     eventsRef.onChildAdded.listen((event) async {
       setState(() {
      Map<dynamic, dynamic> currEvent = event.snapshot.value as Map<dynamic, dynamic>;
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

        DateTime parsedCurrentDateTime = customFormat.parse(formattedCurrentDateTime, true);

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
    String jsonString = await DefaultAssetBundle.of(context)
        .loadString('assets/json/schedule.json');
    setState(() {
      schedule = jsonDecode(jsonString)['schedule'];
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
              availableCalendarFormats: const {
                CalendarFormat.month: 'Week',
                CalendarFormat.twoWeeks: 'Month',
                CalendarFormat.week: '2 Weeks',
              },
              firstDay: DateTime(2022, 6, 19),
              lastDay: DateTime(2024, 6, 23),
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
            ),
            ...schedule.map<Widget>((daySchedule) {
              if (daySchedule['day'] == getDayOfWeek(selectedDay)) {
                return Column(
                  children: [
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '  Schedule',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 300, // Set the desired width for the divider
                        child: Divider(
                          thickness: 1,
                          color: Style.lightBlue,
                        ),
                      ),
                    ),
                    ...daySchedule['classes'].map<Widget>((classData) {
                      return ListTile(
                        title: Text(
                          classData['name'],
                        ),
                        subtitle: Text(
                          '${classData['startTime']} - ${classData['endTime']}',
                        ),
                      );
                    }).toList(),
                  ],
                );
              } else {
                return Container();
              }
            }).toList(),

            eventsWidget(context),
          ],
        ),
      ),
      floatingActionButton: addButton(context),
    );
  }

  Widget addButton(BuildContext context){
    return FloatingActionButton(
      onPressed: () async {
        final newEvent = await showDialog<Event>(
          context: context,
          builder: (BuildContext context) {

            final TextEditingController titleController =
            TextEditingController();
            final TextEditingController descriptionController =
            TextEditingController();
            final TextEditingController startController =
            TextEditingController();
            final TextEditingController endController =
            TextEditingController();
            final TextEditingController locationController =
            TextEditingController();
            List<EventType> eventTypes = EventType.values;

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
                    items: eventTypes
                        .map((e) => _getEventTypeString(e))
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
                    lableText: 'Title',
                    controller: titleController,
                    title: "",
                  ),
                  LineTextField(
                    icon: Icons.description,
                    lableText: "Description",
                    controller: descriptionController,
                    title: "",
                  ),
                  LineTextField(
                    //Text for now (add Dropdown for Buildings)
                    icon: Icons.place,
                    lableText: "Location",
                    controller: locationController,
                    title: "",
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  LineDateTimeField(
                    icon: Icons.schedule,
                    controller: startController,
                    hintText: "Start Time",
                    firstDate: DateTime.now().subtract(Duration(days: 30)),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  LineDateTimeField(
                    icon: Icons.schedule,
                    controller: endController,
                    hintText: "End Time",
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
                      _createPersonalEvent(Event(creator: widget.username, type: _parseEventType(_selectedEventType), title: titleController.text, description: descriptionController.text,
                          startTime: dateFormat.parse(startController.text), endTime: dateFormat.parse(endController.text), location: locationController.text));
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
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor),
                  child: const Text("CANCEL"),
                ),
              ],
            );
          },
        );

        if (newEvent != null) {

          setState(() {
            // This is where you'd actually add the new event to your event list
            // For now I'll just print it
            print('Added new event: $newEvent');
          });
        }
      },
      child: const Icon(
        Icons.add,
        color: Colors.white,
        size: 30,
      ),
      elevation: 6,
      backgroundColor: Theme.of(context).primaryColor,
    );
  }

  Widget eventsWidget(BuildContext context){
    if (events[selectedDay]?.isNotEmpty == true) {
      return Column(
        children: [
          SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '  Events',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 300, // Set the desired width for the divider
              child: Divider(
                thickness: 1,
                color: Style.lightBlue,
              ),
            ),
          ),
          ...?events[selectedDay]?.map<Widget>((event) {
            return ListTile(
              title: Text(
                event.groupId != null
                    ? '${event.title} from ${event.groupId} group'
                    : event.title,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Type: ${_getEventTypeString(event.type)}',
                  ),
                  Text(
                    'Location: ${event.location ?? 'N/A'}',
                  ),
                  Text(
                    'Description: ${event.description}',
                  ),
                  Text(
                    '${_formatDateTime(event.startTime, event.endTime)[0]} - ${_formatDateTime(event.startTime, event.endTime)[1]}',
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      );
    } else {
      return Container(); // Empty container if there are no events
    }

  }

  List<String> _formatDateTime(DateTime dateTime1, DateTime dateTime2) {
    if (dateTime1.day != dateTime2.day || dateTime1.month != dateTime2.month || dateTime1.year != dateTime2.year) {
      return [DateFormat('HH:mm of yyyy-MM-dd').format(dateTime1), DateFormat('HH:mm of yyyy-MM-dd').format(dateTime2)];
    } else {
      return [DateFormat('HH:mm').format(dateTime1), DateFormat('HH:mm').format(dateTime2)];
    }
  }

  void _createPersonalEvent(Event event) {

    DatabaseReference eventsRef =
    FirebaseDatabase.instance.ref().child('schedule').child(widget.username).push();

    // Generate a new ID for the event
    String? eventId = eventsRef.key;

    // Add the event to the database
    eventsRef.set(event.toJson()).then((_) {
        print('Event added successfully with ID: $eventId');
      }).catchError((error) {
        print('Failed to add event: $error');
      });
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
}
