import 'dart:convert';
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
}
