import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:unilink2023/features/BackOfficeHub/anomaliesBackOffice.dart';
import 'package:unilink2023/features/BackOfficeHub/eventsBackOffice.dart';
import 'package:unilink2023/features/BackOfficeHub/groupsBackOffice.dart';

class BackOfficePage extends StatefulWidget {
  @override
  _BackOfficePageState createState() => _BackOfficePageState();
}

class _BackOfficePageState extends State<BackOfficePage> {
  String _selectedButton = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedButton = 'User Management';
                });
              },
              style: ElevatedButton.styleFrom(
                primary:
                    _selectedButton == 'User Management' ? Colors.green : null,
              ),
              child: Text('User Management'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                primary:
                    _selectedButton == 'Group Management' ? Colors.green : null,
              ),
              child: Text('Group Management'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    String groupId =
                        ''; // Variable to store the entered group ID

                    return AlertDialog(
                      title: Text('Enter Group ID'),
                      content: TextField(
                        onChanged: (value) {
                          groupId = value;
                        },
                        decoration: InputDecoration(
                          hintText: 'Group ID',
                        ),
                      ),
                      actions: <Widget>[
                        ElevatedButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        ElevatedButton(
                          child: Text('OK'),
                          onPressed: () async {
                            Navigator.of(context).pop();

                            final database = FirebaseDatabase.instance.ref();
                            DatabaseEvent snapshot = await database
                                .child('events')
                                .child(groupId)
                                .once();

                            if (snapshot.snapshot.value != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      GroupEventsPage(groupId: groupId),
                                ),
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('No Events Found'),
                                    content: Text(
                                        'There are no events available for the entered group ID.'),
                                    actions: <Widget>[
                                      ElevatedButton(
                                        child: Text('OK'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Event Management'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => AnomaliesPage()),
                  );
                });
              },
              child: Text('Anomalies'),
            ),
          ],
        ),
      ),
    );
  }
}
