import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:unilink2023/features/calendar/domain/Event.dart';
import 'package:unilink2023/widgets/LineDateTimeField.dart';
import 'package:unilink2023/widgets/LineTextField.dart';
import 'package:unilink2023/widgets/my_text_field.dart';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  List<dynamic> schedule = [];
  CalendarFormat format = CalendarFormat.week;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadSchedule();
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
            firstDay: DateTime.utc(2022, 6, 19),
            lastDay: DateTime.utc(2024, 6, 23),
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newEvent = await showDialog<Event>(
            context: context,
            builder: (BuildContext context) {
              TextEditingController titleController = TextEditingController();
              TextEditingController descriptionController =
                  TextEditingController();
              TextEditingController startDateController =
                  TextEditingController();
              TextEditingController endDateController = TextEditingController();
              DateTime startTime = DateTime.now();
              DateTime endTime = DateTime.now().add(Duration(hours: 1));

              return AlertDialog(
                backgroundColor: Theme.of(context).canvasColor,
                title: Text('New Event',
                    style: Theme.of(context).textTheme.titleMedium),
                content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LineTextField(
                            icon: Icons.title,
                            controller: titleController,
                            lableText: 'Title',
                          ),
                          SizedBox(height: 5,),
                          LineTextField(
                            icon: Icons.description,
                            controller: descriptionController,
                            lableText: 'Description',
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          LineDateTimeField(
                              icon: Icons.schedule,
                              controller: startDateController,
                              hintText: 'Start',
                              firstDate:
                                  DateTime.now().subtract(Duration(days: 365)),
                              lastDate:
                                  DateTime.now().add(Duration(days: 365))),
                          SizedBox(
                            height: 8,
                          ),
                          LineDateTimeField(
                              icon: Icons.schedule,
                              controller: endDateController,
                              hintText: 'Start',
                              firstDate:
                                  DateTime.now().subtract(Duration(days: 365)),
                              lastDate: DateTime.now().add(Duration(days: 365)))
                        ],
                      ),
                    );
                  },
                ),
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColor),
                    child: Text('SAVE', ),
                    onPressed: () {
                      Navigator.of(context).pop(
                        Event(
                          type: EventType.academic, //add controller
                          title: titleController.text,
                          description: descriptionController.text,
                          startTime: startTime,
                          endTime: endTime,
                          location: "",
                        ),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text(
                      'CANCEL',
                    ),
                    style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColor),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
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
}
