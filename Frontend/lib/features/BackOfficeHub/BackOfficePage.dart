import 'package:flutter/material.dart';
import 'package:unilink2023/features/BackOfficeHub/anomaliesBackOffice.dart';

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
                setState(() {
                  _selectedButton = 'Group Management';
                });
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
                setState(() {
                  _selectedButton = 'Event Menagement';
                });
              },
              style: ElevatedButton.styleFrom(
                primary:
                    _selectedButton == 'Event Menagement' ? Colors.green : null,
              ),
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
              style: ElevatedButton.styleFrom(
                primary: _selectedButton == 'Anomalies' ? Colors.green : null,
              ),
              child: Text('Anomalies'),
            ),
          ],
        ),
      ),
    );
  }
}
