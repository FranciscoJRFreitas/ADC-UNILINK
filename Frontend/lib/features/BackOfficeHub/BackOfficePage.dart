import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unilink2023/data/cache_factory_provider.dart';
import 'package:unilink2023/domain/Token.dart';
import 'package:unilink2023/features/BackOfficeHub/anomaliesBackOffice.dart';
import 'package:unilink2023/features/BackOfficeHub/eventsBackOffice.dart';
import 'package:unilink2023/features/BackOfficeHub/groupsBackOffice.dart';
import 'package:unilink2023/features/screen.dart';

import '../../constants.dart';
import 'package:http/http.dart' as http;

import '../../widgets/LineComboBox.dart';
import '../../widgets/LineText.dart';
import '../../widgets/LineTextField.dart';

class BackOfficePage extends StatefulWidget {
  @override
  _BackOfficePageState createState() => _BackOfficePageState();
}

class _BackOfficePageState extends State<BackOfficePage> {
  late String selectedRole = 'SU';

  Widget userManagement(BuildContext context){
    return AlertDialog(
      title: Text('User Management',  style: TextStyle(fontSize: 25),),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor:
              Theme.of(context).primaryColor,
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
                  return StatefulBuilder(
                    // Add this
                    builder: (BuildContext context,
                        StateSetter setState) {
                      // Add this
                      return AlertDialog(
                        title: Text('Create User',  style: TextStyle(fontSize: 30)),
                        content: SingleChildScrollView(
                          child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            LineTextField(
                              controller: nameController,
                              title: 'Display Name',
                            ),
                            LineTextField(
                              controller: usernameController,
                              title: 'Username',
                            ),
                            LineTextField(
                              controller: emailController,
                              title: 'Email',
                            ),
                            LineTextField(
                              controller: passwordController,
                              title: 'Password',
                              obscure: true,
                            ),
                            LineComboBox(
                              selectedValue: selectedRole,
                              items: [
                                'SU',
                                'BACKOFFICE',
                                'DIRECTOR',
                                'PROF',
                                'STUDENT'
                              ],
                              icon: Icons.category,
                              onChanged: (newValue) {
                                setState(() {
                                  selectedRole = newValue!;
                                });
                              },
                            ),
                          ],
                          )),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              String name =
                                  nameController.text;
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
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'),
                          ),
                        ],
                      );
                    },
                  ); // Close StatefulBuilder
                },
              );
            },
          ),
          SizedBox(height: 10,),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor:
              Theme.of(context).primaryColor,
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
  }

  Widget eventManagement(BuildContext context,){
    TextEditingController groupId = TextEditingController();
    return AlertDialog(
      title: Text('Enter Group ID', style: TextStyle(fontSize: 30)),
      contentPadding: EdgeInsets.fromLTRB(24, 2, 24, 0),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "to view the group's events",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          LineTextField(
            controller: groupId,
            title: 'Group ID',
          ),
          SizedBox(height: 20),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          child: Text('OK'),
          onPressed: () async {
            Navigator.of(context).pop();

            final database =
            FirebaseDatabase.instance.ref();
            DatabaseEvent snapshot = await database
                .child('events')
                .child(groupId.text)
                .once();

            if (snapshot.snapshot.value != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      GroupEventsPage(groupId: groupId.text),
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
        ElevatedButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget webLayout(BuildContext context) {
    return Column(
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
                      return userManagement(context);
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
                      return eventManagement(context);
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
    );
  }

  Widget mobileLayout(BuildContext context){
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
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
                      return userManagement(context);
                    },
                  );
                },
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
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
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
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
                      return eventManagement(context);
                    },
                  );
                },
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
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
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: kIsWeb ? webLayout(context) : mobileLayout(context)
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
