import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:unilink2023/data/cache_factory_provider.dart';
import 'package:unilink2023/domain/Token.dart';
import 'package:unilink2023/features/BackOfficeHub/anomaliesBackOffice.dart';
import 'package:unilink2023/features/BackOfficeHub/eventsBackOffice.dart';
import 'package:unilink2023/features/BackOfficeHub/groupsBackOffice.dart';
import 'package:unilink2023/features/screen.dart';

import '../../constants.dart';
import 'package:http/http.dart' as http;

class BackOfficePage extends StatefulWidget {
  @override
  _BackOfficePageState createState() => _BackOfficePageState();
}

class _BackOfficePageState extends State<BackOfficePage> {
  late String selectedRole = 'SU';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 300, // adjust these values as needed
                height: 100,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).primaryColor, // button's fill color
                    foregroundColor: Colors.white,
                    elevation: 2,
                    padding: EdgeInsets.all(20),
                  ),
                  icon: Icon(Icons.manage_accounts),
                  label: Text('User Management'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('User Management'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .primaryColor, // button's fill color
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                ),
                                icon: Icon(Icons.person_add),
                                label: Text('Create User'),
                                onPressed: () {
                                  TextEditingController nameController =
                                      TextEditingController();
                                  TextEditingController usernameController =
                                      TextEditingController();
                                  TextEditingController emailController =
                                      TextEditingController();
                                  TextEditingController passwordController =
                                      TextEditingController();
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Create User'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              controller: nameController,
                                              decoration: InputDecoration(
                                                hintText: 'Name',
                                              ),
                                            ),
                                            TextField(
                                              controller: usernameController,
                                              decoration: InputDecoration(
                                                hintText: 'Username',
                                              ),
                                            ),
                                            TextField(
                                              controller: emailController,
                                              decoration: InputDecoration(
                                                hintText: 'Email',
                                              ),
                                            ),
                                            TextField(
                                              controller: passwordController,
                                              decoration: InputDecoration(
                                                hintText: 'Password',
                                              ),
                                              obscureText: true,
                                            ),
                                            _buildLocationField()
                                          ],
                                        ),
                                        actions: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              String name = nameController.text;
                                              String username =
                                                  usernameController.text;
                                              String email =
                                                  emailController.text;
                                              String password =
                                                  passwordController.text;
                                              String role = selectedRole;
                                              // Call the registerUser function with the entered data
                                              registerUser(
                                                  name,
                                                  username,
                                                  email,
                                                  password,
                                                  role,
                                                  _showErrorSnackbar);

                                              // Handle create user logic with the entered data
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Create'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .primaryColor, // button's fill color
                                  foregroundColor: Colors.white,

                                  elevation: 2,
                                ),
                                icon: Icon(Icons.person_remove),
                                label: Text('Delete User'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RemoveAccountPage(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                width: 300, // adjust these values as needed
                height: 100,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).primaryColor, // button's fill color
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.all(20),
                    elevation: 2,
                  ),
                  icon: Icon(Icons.groups),
                  label: Text('Group Management'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 300, // adjust these values as needed
                height: 100,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).primaryColor, // button's fill color
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.all(20),
                    elevation: 2,
                  ),
                  icon: Icon(Icons.edit_calendar),
                  label: Text('Event Management'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        String groupId = '';
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

                                final database =
                                    FirebaseDatabase.instance.ref();
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
                ),
              ),
              Container(
                width: 300, // adjust these values as needed
                height: 100,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).primaryColor, // button's fill color
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.all(20),
                    elevation: 2,
                  ),
                  icon: Icon(Icons.report),
                  label: Text('Anomalies'),
                  onPressed: () {
                    setState(() {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => AnomaliesPage()),
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationField() {
    return DropdownButton<String>(
      value: selectedRole,
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            selectedRole = newValue;
          });
        }
      },
      items: [
        DropdownMenuItem<String>(
          value: 'SU',
          child: Text('SU'),
        ),
        DropdownMenuItem<String>(
          value: 'BACKOFFICE',
          child: Text('BACKOFFICE'),
        ),
        DropdownMenuItem<String>(
          value: 'DIRECTOR',
          child: Text('DIRECTOR'),
        ),
        DropdownMenuItem<String>(
          value: 'PROF',
          child: Text('PROF'),
        ),
        DropdownMenuItem<String>(
          value: 'STUDENT',
          child: Text('STUDENT'),
        ),
      ],
    );
  }

  Future<void> registerUser(
    String displayName,
    String username,
    String email,
    String password,
    String role,
    void Function(String, bool) showErrorSnackbar,
  ) async {
    final url = kBaseUrl + 'rest/register/';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'displayName': displayName,
        'username': username,
        'email': email,
        'password': password,
        'confirmPwd': password,
        'role': role,
        'activityState': 'ACTIVE',
      }),
    );

    if (response.statusCode == 200) {
      showErrorSnackbar('Registration successful!.', false);
    } else {
      showErrorSnackbar('Failed to register user: ${response.body}', true);
    }
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
