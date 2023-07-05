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
        print(userDataSnapshot.snapshot.value);
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
    setState(() {});
  }

  EventType _parseEventType(String? eventTypeString) {
    if (eventTypeString != null) {
      eventTypeString = eventTypeString.toLowerCase();
      print(eventTypeString);

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
      body: Column(
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
                print(selectedDay);
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
                children: daySchedule['classes'].map<Widget>((classData) {
                  return ListTile(
                    title: Text(
                      classData['name'],
                    ),
                    subtitle: Text(
                        '${classData['startTime']} - ${classData['endTime']}'),
                  );
                }).toList(),
              );
            } else {
              return Container();
            }
          }).toList(),
          ...events[selectedDay]?.map<Widget>((event) {
                return ListTile(
                  title: Text(
                    '${event.title} from ${event.groupId} group',
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
                            '${DateFormat('HH:mm').format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}'),
                      ]),
                );
              }).toList() ??
              [],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newEvent = await showDialog<Event>(
            context: context,
            builder: (BuildContext context) {
              String _selectedEventType = 'Academic';
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
                        _createPersonalEvent();
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
            // Save the new event using your chosen method
            // Then update the state to refresh the calendar
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
      ),
    );
  }

  _createPersonalEvent() {

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
