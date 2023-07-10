import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:unilink2023/data/cache_factory_provider.dart';
import 'package:unilink2023/domain/Token.dart';
import 'package:unilink2023/features/BackOfficeHub/anomaliesBackOffice.dart';
import 'package:unilink2023/features/BackOfficeHub/eventsBackOffice.dart';
import 'package:unilink2023/features/BackOfficeHub/groupsBackOffice.dart';

import '../../constants.dart';
import 'package:http/http.dart' as http;

import '../userManagement/presentation/userAuth/remove_account_page.dart';

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
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('User Management'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              TextEditingController nameController =
                                  TextEditingController();
                              TextEditingController usernameController =
                                  TextEditingController();
                              TextEditingController emailController =
                                  TextEditingController();
                              TextEditingController passwordController =
                                  TextEditingController();
                              String selectedRole = 'SU';

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
                                        DropdownButton<String>(
                                          value: selectedRole,
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              setState(() {
                                                selectedRole = newValue;
                                              });
                                            }
                                          },
                                          items: <String>[
                                            'SU',
                                            'BACKOFFICE',
                                            'DIRECTOR',
                                            'PROF',
                                            'STUDENT'
                                          ].map<DropdownMenuItem<String>>(
                                            (String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            },
                                          ).toList(),
                                        ),
                                        // Add other fields here
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
                                          String email = emailController.text;
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
                            child: Text('Create User'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RemoveAccountPage(),
                                ),
                              );
                            },
                            child: Text('Delete User'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
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

  Future<void> removeAccount(
    BuildContext context,
    String password,
    String targetUsername,
  ) async {
    final url =
        kBaseUrl + 'rest/remove/?targetUsername=$targetUsername&pwd=$password';

    final tokenID = await cacheFactory.get('users', 'token');
    final storedUsername = await cacheFactory.get('users', 'username');

    Token token = new Token(tokenID: tokenID, username: storedUsername);

    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${json.encode(token.toJson())}',
      },
    );

    if (response.statusCode == 200) {
      FirebaseStorage.instance
          .ref()
          .child('ProfilePictures/$targetUsername')
          .delete()
          .onError((error, stackTrace) => null);

      _showErrorSnackbar('Removed successfully!', false);
    } else {
      _showErrorSnackbar(
          'Failed to remove the account: ${response.body}', true);
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
