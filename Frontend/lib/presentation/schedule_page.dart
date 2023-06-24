/*import 'dart:convert';
import 'package:flutter/material.dart';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  List<dynamic> schedule = [];

  @override
  void initState() {
    super.initState();
    // Load the schedule data
    loadSchedule();
  }

  Future<void> loadSchedule() async {
    // Replace this with the actual way you load your JSON data
    String jsonString = await DefaultAssetBundle.of(context)
        .loadString('assets/json/schedule.json');
    setState(() {
      schedule = jsonDecode(jsonString)['schedule'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: schedule.length,
      itemBuilder: (context, index) {
        return ExpansionTile(
          title: Text(schedule[index]['day']),
          children: schedule[index]['classes'].map<Widget>((classData) {
            return ListTile(
              title: Text(classData['name']),
              subtitle:
                  Text('${classData['startTime']} - ${classData['endTime']}'),
            );
          }).toList(),
        );
      },
    );
  }
}*/
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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
