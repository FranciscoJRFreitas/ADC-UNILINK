import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:unilink2023/domain/Event.dart';
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
            firstDay: DateTime.utc(2022, 6, 19), // assuming it's a Monday
            lastDay: DateTime.utc(2024, 6, 23), // assuming it's a Friday
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
                    title: Text(classData['name']),
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
              DateTime startTime = DateTime.now();
              DateTime endTime = DateTime.now().add(Duration(hours: 1));

              return AlertDialog(
                backgroundColor: Theme.of(context).primaryColor,
                title: Text('New Event',
                    style: Theme.of(context).textTheme.titleMedium),
                content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MyTextField(
                            controller: titleController,
                            small: true,
                            hintText: 'Title Event',
                            inputType: TextInputType.text,
                          ),
                          MyTextField(
                            controller: descriptionController,
                            small: true,
                            hintText: 'Description',
                            inputType: TextInputType.text,
                          ),
                          TextButton(
                            onPressed: () async {
                              final selectedDate = await showDatePicker(
                                context: context,
                                initialDate: startTime,
                                firstDate: DateTime.now()
                                    .subtract(Duration(days: 365)),
                                lastDate:
                                    DateTime.now().add(Duration(days: 365)),
                              );
                              if (selectedDate != null) {
                                final selectedTime = await showTimePicker(
                                  context: context,
                                  initialTime:
                                      TimeOfDay.fromDateTime(startTime),
                                );
                                if (selectedTime != null) {
                                  setState(() {
                                    startTime = DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      selectedDate.day,
                                      selectedTime.hour,
                                      selectedTime.minute,
                                    );
                                  });
                                }
                              }
                            },
                            child: Text(
                              'Start Time: ${DateFormat('yyyy-MM-dd – kk:mm').format(startTime)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final selectedDate = await showDatePicker(
                                context: context,
                                initialDate: endTime,
                                firstDate: DateTime.now()
                                    .subtract(Duration(days: 365)),
                                lastDate:
                                    DateTime.now().add(Duration(days: 365)),
                              );
                              if (selectedDate != null) {
                                final selectedTime = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(endTime),
                                );
                                if (selectedTime != null) {
                                  setState(() {
                                    endTime = DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      selectedDate.day,
                                      selectedTime.hour,
                                      selectedTime.minute,
                                    );
                                  });
                                }
                              }
                            },
                            child: Text(
                              'End Time: ${DateFormat('yyyy-MM-dd – kk:mm').format(endTime)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                actions: [
                  TextButton(
                    child: Text(
                      'Cancel',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('Save',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: Colors.white)),
                    onPressed: () {
                      Navigator.of(context).pop(
                        Event(
                          title: titleController.text,
                          description: descriptionController.text,
                          startTime: startTime,
                          endTime: endTime,
                        ),
                      );
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
        child: Icon(Icons.add),
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
